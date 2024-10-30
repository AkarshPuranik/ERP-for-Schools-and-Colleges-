import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_erp/reusable_widgets/assignment_card.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({super.key});

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  String _classyear = '';
  String _section = '';
  Map<String, List<Map<String, dynamic>>> subjectAssignments = {};
  bool _isLoading = true; // Track loading state

  Future<void> _fetchUserProfile() async {
    try {
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('profile_history')
          .doc(FirebaseAuth.instance.currentUser!.uid);

      final userDoc = await userDocRef.get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        setState(() {
          _classyear = userData['class'];
          _section = userData['section'];
        });

        await _fetchAssignments();
      } else {
        print("User profile does not exist.");
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }

  Future<void> _fetchAssignments() async {
    try {
      final assignmentsDocRef = FirebaseFirestore.instance
          .collection('assignments')
          .doc('$_classyear$_section');

      final assignmentsDoc = await assignmentsDocRef.get();

      if (assignmentsDoc.exists) {
        print("Document found for class-section: $_classyear$_section");

        // Define subjects to fetch
        final subjectsCollection = [
          'Hindi',
          'Maths',
          'Science',
          'Social',
          'English'
        ];

        for (String subject in subjectsCollection) {
          final subjectRef = assignmentsDocRef.collection(subject);
          final subjectDocs = await subjectRef.get();

          // Debugging output
          print("Fetching data from subject: $subject");
          print("Documents found: ${subjectDocs.docs.length}");

          if (subjectDocs.docs.isNotEmpty) {
            subjectAssignments[subject] = subjectDocs.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
          } else {
            subjectAssignments[subject] = [];
            print("No documents found for subject: $subject");
          }
        }
      } else {
        print("No document found for class-section: $_classyear$_section");
      }

      setState(() {
        _isLoading = false; // Stop loading after fetching
      });
    } catch (e) {
      print("Error fetching assignments: $e");
      setState(() {
        _isLoading = false; // Ensure loading indicator is hidden even on error
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assignments of $_classyear$_section'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: subjectAssignments.keys.map((subject) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  subject,
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                                Icon(Icons.assignment, color: Colors.blue),
                              ],
                            ),
                            SizedBox(height: 10),
                            Divider(),
                            ...subjectAssignments[subject]!.isEmpty
                                ? [Text('No assignments found for $subject.')]
                                : subjectAssignments[subject]!
                                    .map((assignment) {
                                    return AssignmentCard(
                                      description:
                                          assignment['description'] ?? 'N/A',
                                      subject: subject,
                                      deadline: assignment['deadline'] ?? 'N/A',
                                      onTapSubmit: () {
                                        // Add any specific action for the assignment card if needed
                                      },
                                    );
                                  }).toList(),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }
}
