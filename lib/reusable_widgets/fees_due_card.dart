import 'package:flutter/material.dart';

class FeesDueCard extends StatelessWidget {
  final String description;
  final String status;
  final String receiptNo;
  final String paymentDate;
  final String paymentMode;
  final String amount;
  final VoidCallback onTapPay;
  final VoidCallback? onTapDownload; // Make onTapDownload optional

  const FeesDueCard({
    Key? key,
    required this.description,
    required this.status,
    required this.receiptNo,
    required this.paymentDate,
    required this.paymentMode,
    required this.amount,
    required this.onTapPay,
    this.onTapDownload, // Not required anymore
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Receipt No: $receiptNo",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("Description: $description"),
            Text("Payment Date: $paymentDate"),
            Text("Payment Mode: $paymentMode"),
            Text("Amount: $amount", style: TextStyle(color: Colors.green)),
            Text("Status: $status",
                style: TextStyle(
                    color: status == "Paid" ? Colors.green : Colors.red)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: onTapPay,
                  icon: const Icon(Icons.payment),
                  label: const Text("Pay Now"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Background color
                  ),
                ),
                if (onTapDownload != null) // Show Download button only if onTapDownload is not null
                  ElevatedButton.icon(
                    onPressed: onTapDownload,
                    icon: const Icon(Icons.download),
                    label: const Text("Download"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Background color
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
