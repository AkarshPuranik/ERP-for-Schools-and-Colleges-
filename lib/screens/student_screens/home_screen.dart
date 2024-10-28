import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:page_animation_transition/animations/bottom_to_top_faded_transition.dart';
import 'package:page_animation_transition/animations/fade_animation_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:school_erp/screens/ask_doubt_screen.dart';
import 'package:school_erp/screens/assignment_screen.dart';
import 'package:school_erp/screens/attendance/attendance_screen.dart';
import 'package:school_erp/screens/events/events_screen.dart';
import 'package:school_erp/screens/fees_due_screen.dart';
import 'package:school_erp/screens/student_screens/settings_screen.dart';
import 'package:school_erp/screens/student_screens/view_marks.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../model/user_model.dart';
import '../../reusable_widgets/home_screen_cards/master_card.dart';
import '../../reusable_widgets/home_screen_cards/small_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = '';
  String enrollmentNumber = '';
  String classyear = '';
  String _profileImageUrl = '';
  String _feesDue = '';
  String _section = '';
  double _overallAttendancePercentage =
      0.0; // New variable to store overall percentage

  @override
  void initState() {
    super.initState();
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
        _profileImageUrl = userData['profileImageUrl'];
        username = userData['name'];
        enrollmentNumber = userData['enrollmentNumber'];
        classyear = userData['class'];
        _section = userData['section'];
      });
      await _fetchFeesDue(enrollmentNumber);
      await _fetchOverallAttendance(
          enrollmentNumber); // Fetch overall attendance percentage
    }
  }

  Future<void> _fetchOverallAttendance(String enrollmentNumber) async {
    final subjects = ['Hindi', 'Math', 'Science', 'Social', 'English'];
    int totalClasses = 0;
    int attendedClasses = 0;

    for (String subject in subjects) {
      final attendanceCollection = FirebaseFirestore.instance
          .collection('attendance')
          .doc(enrollmentNumber)
          .collection(subject);

      final attendanceDocs = await attendanceCollection.get();

      print(
          'Subject: $subject, Documents Count: ${attendanceDocs.docs.length}'); // Debugging line

      totalClasses += attendanceDocs.docs.length;
      attendedClasses +=
          attendanceDocs.docs.where((doc) => doc['status'] == 'Present').length;
    }

    print(
        'Total Classes: $totalClasses, Attended Classes: $attendedClasses'); // Debugging line

    setState(() {
      _overallAttendancePercentage =
          totalClasses > 0 ? (attendedClasses / totalClasses) * 100 : 0.0;
    });
  }

  Future<void> _fetchFeesDue(String enrollmentNumber) async {
    final feeDocRef =
        FirebaseFirestore.instance.collection('fees').doc(enrollmentNumber);

    final feeDoc = await feeDocRef.get();

    if (feeDoc.exists) {
      final feeData = feeDoc.data() as Map<String, dynamic>;
      final amount = feeData['amount'];
      final status = feeData['status']; // Fetch the status value

      setState(() {
        if (status == 'Paid') {
          _feesDue = "No due's"; // Set to "No due's" if status is paid
        } else if (status == 'Unpaid') {
          _feesDue = amount.toString(); // Convert to string to display in UI
        }
      });
    } else {
      // Show "No data found" if no data is found
      setState(() {
        _feesDue = "No data found";
      });
      print("No fees data found for enrollment number: $enrollmentNumber");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7292CF),
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset(
              "assets/Star_Background.png",
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, top: 50.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hi, $username",
                              style: const TextStyle(
                                fontSize: 30.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "$enrollmentNumber",
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14.0, vertical: 6.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Text(
                                "Class: $classyear$_section",
                                style: const TextStyle(
                                  color: Color(0xFF6184C7),
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        ZoomTapAnimation(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                  PageAnimationTransition(
                                      page: const SettingsScreen(),
                                      pageAnimationType:
                                          FadeAnimationTransition()));
                            },
                            child: ZoomIn(
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: _profileImageUrl.isNotEmpty
                                    ? NetworkImage(_profileImageUrl)
                                    : null,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 30.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ZoomTapAnimation(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                      PageAnimationTransition(
                                          page: AttendanceScreen(
                                              enrollmentNumber:
                                                  enrollmentNumber),
                                          pageAnimationType:
                                              FadeAnimationTransition()));
                                },
                                child: BounceInLeft(
                                  child: HomeScreenMasterCard(
                                    attendancepercentage:
                                        '${_overallAttendancePercentage.toStringAsFixed(2)}%', // Display overall percentage
                                    attendance: true,
                                    tooltext: 'Check out your attendance here ',
                                  ),
                                ),
                              ),
                            ),
                            BounceInRight(
                              child: ZoomTapAnimation(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        PageAnimationTransition(
                                            page: const FeesDueScreen(),
                                            pageAnimationType:
                                                FadeAnimationTransition()));
                                  },
                                  child: HomeScreenMasterCard(
                                    feespending: '₹$_feesDue/-',
                                    tooltext: 'Check your fee due here',
                                    attendance: false,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        Wrap(
                          runAlignment: WrapAlignment.spaceBetween,
                          alignment: WrapAlignment.spaceBetween,
                          runSpacing: 20.0,
                          spacing: 20.0,
                          children: [
                            BounceInDown(
                              child: ZoomTapAnimation(
                                child: HomeScreenSmallCard(
                                  tooltext:
                                      'Check out your marks by tapping the button',
                                  icon: Icons.collections_bookmark_rounded,
                                  buttonText: "Marks",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ViewMarksScreen(
                                            enrollmentNumber:
                                                enrollmentNumber), // Navigate to the marks screen
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            BounceInDown(
                              child: ZoomTapAnimation(
                                child: HomeScreenSmallCard(
                                    tooltext: 'Submit your assignments',
                                    icon: Icons.assignment,
                                    buttonText: "Assignments",
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AssignmentScreen(),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                            BounceInDown(
                              child: ZoomTapAnimation(
                                child: HomeScreenSmallCard(
                                  tooltext: 'Have any doubt? Ask here!',
                                  icon: Icons.question_answer,
                                  buttonText: "Ask Doubt",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const AskDoubtScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            BounceInDown(
                              child: ZoomTapAnimation(
                                child: HomeScreenSmallCard(
                                  tooltext: 'Stay updated with events',
                                  icon: Icons.event,
                                  buttonText: "Events",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const EventDisplayPage(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
