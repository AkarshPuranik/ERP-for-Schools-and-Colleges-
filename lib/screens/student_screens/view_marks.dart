import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewMarksScreen extends StatefulWidget {
  final String enrollmentNumber; // Accept enrollment number

  const ViewMarksScreen({Key? key, required this.enrollmentNumber}) : super(key: key);

  @override
  _ViewMarksScreenState createState() => _ViewMarksScreenState();
}

class _ViewMarksScreenState extends State<ViewMarksScreen> {
  List<Map<String, dynamic>> _marksDataList = []; // Change to a List to keep all marks

  @override
  void initState() {
    super.initState();
    _fetchMarks(); // Fetch marks directly on initialization
  }

  Future<void> _fetchMarks() async {
    try {
      final documentSnapshot = await FirebaseFirestore.instance
          .collection('marks')
          .doc(widget.enrollmentNumber) // Use the passed enrollment number
          .get();

      if (documentSnapshot.exists) {
        final marksData = documentSnapshot.data() as Map<String, dynamic>;

        // Check if the marks for this enrollment number already exist
        if (!_marksDataList.any((marks) => marks['enrollmentNumber'] == marksData['enrollmentNumber'])) {
          setState(() {
            _marksDataList.add(marksData); // Append new marks data to the list
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('No marks found for this enrollment number')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching marks: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Marks')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            if (_marksDataList.isNotEmpty) _buildMarksDisplay(),
            if (_marksDataList.isEmpty)
              const Center(
                child: CircularProgressIndicator(), // Loading indicator
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarksDisplay() {
    return Expanded(
      child: ListView.builder(
        itemCount: _marksDataList.length,
        itemBuilder: (context, index) {
          final marksData = _marksDataList[index];
          final subjects = marksData['subjects'] as Map<String, dynamic>;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Marks for ${marksData['enrollmentNumber']}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Test Type: ${marksData['testType']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...subjects.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
