import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddAssignmentScreen extends StatefulWidget {
  @override
  _AddAssignmentScreenState createState() => _AddAssignmentScreenState();
}

class _AddAssignmentScreenState extends State<AddAssignmentScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  String? selectedClass;
  String? selectedSubject;
  String? selectedSection;
  DateTime? selectedDeadline;

  // Class, Subject, and Section options
  final List<String> classOptions = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10'
  ];
  final List<String> subjectOptions = [
    'Hindi',
    'Maths',
    'Science',
    'Social',
    'English'
  ];
  final List<String> sectionOptions = ['A', 'B', 'C', 'D'];

  Future<void> _saveAssignment() async {
    if (selectedClass == null ||
        selectedSubject == null ||
        selectedSection == null ||
        selectedDeadline == null ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    // Create a unique document ID using class and section
    String documentId = '$selectedClass$selectedSection';

    // Add a new assignment to the specific subject sub-collection
    await FirebaseFirestore.instance
        .collection('assignments')
        .doc(documentId) // Store all assignments for the class-section pair
        .collection(
            selectedSubject!) // Use the selected subject as the sub-collection name
        .add({
      'class': selectedClass,
      'subject': selectedSubject,
      'section': selectedSection,
      'deadline': selectedDeadline?.toIso8601String(),
      'description': _descriptionController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Assignment added successfully!')),
    );
    _clearForm();
  }

  void _clearForm() {
    setState(() {
      selectedClass = null;
      selectedSubject = null;
      selectedSection = null;
      selectedDeadline = null;
      _descriptionController.clear();
    });
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != selectedDeadline) {
      setState(() {
        selectedDeadline = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Assignment')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedClass,
              hint: Text('Select Class'),
              onChanged: (value) => setState(() => selectedClass = value),
              items: classOptions.map((className) {
                return DropdownMenuItem<String>(
                  value: className,
                  child: Text('Class $className'),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedSubject,
              hint: Text('Select Subject'),
              onChanged: (value) => setState(() => selectedSubject = value),
              items: subjectOptions.map((subject) {
                return DropdownMenuItem<String>(
                  value: subject,
                  child: Text(subject),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedSection,
              hint: Text('Select Section'),
              onChanged: (value) => setState(() => selectedSection = value),
              items: sectionOptions.map((section) {
                return DropdownMenuItem<String>(
                  value: section,
                  child: Text('Section $section'),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text(selectedDeadline == null
                  ? 'Select Deadline'
                  : 'Deadline: ${selectedDeadline!.toLocal().toString().split(' ')[0]}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDeadline(context),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveAssignment,
              child: Text('Save Assignment'),
            ),
          ],
        ),
      ),
    );
  }
}
