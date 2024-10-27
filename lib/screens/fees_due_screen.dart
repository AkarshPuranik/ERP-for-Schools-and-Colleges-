import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:school_erp/model/user_model.dart';
import 'package:school_erp/reusable_widgets/fees_due_card.dart';
import 'dart:ui' as ui;

class FeesDueScreen extends StatefulWidget {
  const FeesDueScreen({super.key});

  @override
  State<FeesDueScreen> createState() => _FeesDueScreenState();
}

class _FeesDueScreenState extends State<FeesDueScreen> {
  Box<UserModel> userBox = Hive.box<UserModel>('users');
  late Razorpay _razorpay;
  String username = '';
  String enrollmentNumber = '';
  String classyear = '';
  List<Map<String, dynamic>> feesDueList = []; // Store all fees here
  final GlobalKey _screenshotKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('profile_history')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    final userDoc = await userDocRef.get();

    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;

      setState(() {
        username = userData['name'];
        enrollmentNumber = userData['enrollmentNumber'];
        classyear = userData['class'];
      });

      await _fetchFeeCollection(); // Fetch fees after user profile
    }
  }

  Future<void> _fetchFeeCollection() async {
    final feesCollectionRef = FirebaseFirestore.instance
        .collection('fees')
        .doc(enrollmentNumber);

    final feesDoc = await feesCollectionRef.get();

    if (feesDoc.exists) {
      final feesData = feesDoc.data() as Map<String, dynamic>;

      // Add the new fee data to the existing list
      setState(() {
        feesDueList.add(feesData); // Append new fees data
      });
    } else {
      debugPrint("No document found for enrollmentNumber: $enrollmentNumber");
    }
  }

  Future<void> _onRefresh() async {
    await _fetchFeeCollection(); // Fetch the fee collection again
  }

  Future<void> _captureScreenshot() async {
    try {
      RenderRepaintBoundary boundary = _screenshotKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData byteData = (await image.toByteData(format: ui.ImageByteFormat.png))!;
      final pngBytes = byteData.buffer.asUint8List();

      if (await Permission.storage.request().isGranted) {
        final directory = await getExternalStorageDirectory();
        final path = "${directory!.path}/fees_payment_screenshot.png";
        final file = File(path);
        await file.writeAsBytes(pngBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Screenshot saved at $path")),
        );
        OpenFile.open(path);
      }
    } catch (e) {
      debugPrint("Screenshot capture failed: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint("PaymentId: ${response.paymentId} \n OrderId: ${response.orderId}");

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Payment Successful"),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      showCloseIcon: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    ));

    // Update the fee status to "Paid" in Firestore
    try {
      await FirebaseFirestore.instance
          .collection('fees')
          .doc(enrollmentNumber)
          .update({'status': 'Paid'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fee status updated to Paid.")),
      );
      await _fetchFeeCollection(); // Refresh fees due list after payment
    } catch (e) {
      debugPrint("Failed to update fee status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update fee status.")),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("Payment Error Response: ${response.message}");

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Payment Failed"),
      showCloseIcon: true,
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    ));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(response.walletName!),
      backgroundColor: Colors.green,
      showCloseIcon: true,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    ));
  }

  Future<void> openCheckout() async {
    final feeDoc = await FirebaseFirestore.instance
        .collection('fees')
        .doc(enrollmentNumber)
        .get();

    if (feeDoc.exists) {
      final feeData = feeDoc.data() as Map<String, dynamic>;

      debugPrint("Fetched amount from Firestore: ${feeData['amount']}");

      int amountInRupees;
      if (feeData['amount'] is int) {
        amountInRupees = feeData['amount'];
      } else if (feeData['amount'] is double) {
        amountInRupees = feeData['amount'].round();
      } else {
        debugPrint("Unsupported amount type. Received: ${feeData['amount']}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid amount format in Firestore.")),
        );
        return;
      }

      int amountInPaise = amountInRupees * 100;
      debugPrint("Converted amount in paise for Razorpay: $amountInPaise");

      if (amountInPaise <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid amount specified for payment.")),
        );
        return;
      }

      var options = {
        "key": "rzp_test_wFEIWe7sxtp71p",
        "amount": amountInPaise,
        "name": "School ERP",
        "description": "Fee Payment",
        "prefill": {
          "contact": userBox.get("user")?.contactNumber?.split(" ")[1] ?? "0000000000",
          "email": userBox.get("user")?.email ?? "example@example.com",
        },
        "theme": {
          "color": "#528FF0"
        }
      };

      _razorpay.open(options);
    } else {
      debugPrint("No fee document found for enrollment number: $enrollmentNumber");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No fee record found for this enrollment.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7292CF),
      body: SafeArea(
        child: RepaintBoundary(
          key: _screenshotKey,
          child: Stack(
            children: [
              Image.asset(
                "assets/Star_Background.png",
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(top: 20.0, left: 20.0, bottom: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.chevron_left, size: 30, color: Colors.white),
                          SizedBox(width: 5.0),
                          Text("Fees Due", style: TextStyle(fontSize: 18.0, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Name: $username",
                          style: const TextStyle(fontSize: 22.0, color: Colors.white),
                        ),
                        Text(
                          "Enrollment Number: $enrollmentNumber",
                          style: const TextStyle(fontSize: 16.0, color: Colors.white),
                        ),
                        const SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: SingleChildScrollView(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.only(top: 30.0),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20.0),
                              topLeft: Radius.circular(20.0),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: feesDueList.map((fee) {
                                return FeesDueCard(
                                  description: fee['description'] ?? 'N/A',
                                  status: fee['status'] ?? 'N/A',
                                  receiptNo: fee['receipt_no'] ?? "#N/A",
                                  paymentDate: fee['payment_date'] ?? "N/A",
                                  paymentMode: fee['payment_mode'] ?? "N/A",
                                  amount: "₹${fee['amount'] ?? '0'}",
                                  onTapPay: () {
                                    openCheckout();
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
