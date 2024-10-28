import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AttendanceScreen extends StatelessWidget {
  final String enrollmentNumber;

  const AttendanceScreen({Key? key, required this.enrollmentNumber})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Records'),
      ),
      body: FutureBuilder<Map<String, AttendanceData>>(
        future: _fetchAllAttendance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No attendance records found.'));
          }

          final attendanceData = snapshot.data!;
          return ListView(
            children: attendanceData.entries.map((entry) {
              final subject = entry.key;
              final data = entry.value;

              return ExpansionTile(
                title: Text(subject),
                children: [
                  // Smaller Pie chart for attendance percentage
                  Container(
                    height: 150, // Decreased height
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: data.percentage,
                            color: Colors.green,
                            title: '${data.percentage.toStringAsFixed(1)}%',
                            radius: 50, // Smaller radius
                          ),
                          PieChartSectionData(
                            value: 100 - data.percentage,
                            color: Colors.red,
                            title:
                                '${(100 - data.percentage).toStringAsFixed(1)}%',
                            radius: 50, // Smaller radius
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Attendance records list
                  ...data.records.map((record) {
                    return ListTile(
                      title: Text('Date: ${record['date']}'),
                      subtitle: Text('Status: ${record['status']}'),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // Fetch all attendance records for the given enrollment number
  Future<Map<String, AttendanceData>> _fetchAllAttendance() async {
    final subjects = ['Hindi', 'Maths', 'Science', 'Social', 'English'];
    Map<String, AttendanceData> allAttendance = {};

    for (String subject in subjects) {
      try {
        // Access the correct document for the enrollment number and subject
        final attendanceCollection = FirebaseFirestore.instance
            .collection('attendance')
            .doc(enrollmentNumber)
            .collection(subject);

        final attendanceDocs = await attendanceCollection.get();

        // Prepare to calculate attendance percentage
        int totalClasses = attendanceDocs.docs.length;
        int attendedClasses = 0;

        // Map the documents to the required format
        List<Map<String, String>> records = attendanceDocs.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status']?.toString() ?? 'Absent';
          if (status.toLowerCase() == 'present') {
            attendedClasses++;
          }
          return {
            'date': doc.id, // Use the document ID as the date
            'status': status,
          };
        }).toList();

        // Calculate the attendance percentage
        double percentage =
            totalClasses > 0 ? (attendedClasses / totalClasses) * 100 : 0.0;

        // Store the data in the map
        allAttendance[subject] = AttendanceData(records, percentage);
      } catch (e) {
        print('Error fetching attendance for $subject: $e');
        allAttendance[subject] =
            AttendanceData([], 0.0); // Ensure the subject key exists
      }
    }
    return allAttendance;
  }
}

class AttendanceData {
  final List<Map<String, String>> records;
  final double percentage;

  AttendanceData(this.records, this.percentage);
}
