import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddAssignmentPage extends StatefulWidget {
  @override
  _AddAssignmentPageState createState() => _AddAssignmentPageState();
}

class _AddAssignmentPageState extends State<AddAssignmentPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController teacherNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Selected values for dropdowns
  String? selectedClass;
  String? selectedSection;
  String? selectedSubject;
  DateTime? selectedDeadline;

  // Lists for dropdown options
  List<String> classList = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
  List<String> sectionList = ['A', 'B', 'C', 'D'];
  List<String> subjectList = ['Math', 'Science', 'English', 'Social', 'Hindi'];

  // Save assignment data to Firestore
  Future<void> saveAssignment() async {
    if (_formKey.currentState!.validate() && selectedDeadline != null) {
      String teacherName = teacherNameController.text;
      String className = selectedClass!;
      String section = selectedSection!;
      String subject = selectedSubject!;
      String description = descriptionController.text;
      String deadline = selectedDeadline!.toIso8601String();

      try {
        // Create the class-section document if it doesn't exist and set teacher name
        DocumentReference classSectionDoc = FirebaseFirestore.instance
            .collection('assignments')
            .doc('$className$section'); // e.g., '7C'

        await classSectionDoc.set({
          'teacherName': teacherName,
        }, SetOptions(merge: true));

        // Add assignment details to the specific subject collection
        await classSectionDoc.collection(subject).add({
          'subject': subject,
          'deadline': deadline,
          'description': description,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Clear fields after saving
        teacherNameController.clear();
        descriptionController.clear();
        setState(() {
          selectedClass = null;
          selectedSection = null;
          selectedSubject = null;
          selectedDeadline = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Assignment saved successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving assignment: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields and select a date')),
      );
    }
  }

  // Show Date Picker
  Future<void> pickDeadlineDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDeadline = pickedDate;
      });
    }
  }

  @override
  void dispose() {
    teacherNameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Assignment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Teacher Name Field
                TextFormField(
                  controller: teacherNameController,
                  decoration: InputDecoration(
                    labelText: 'Teacher Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the teacher\'s name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),

                // Class Dropdown
                DropdownButtonFormField<String>(
                  value: selectedClass,
                  items: classList.map((className) {
                    return DropdownMenuItem(
                      value: className,
                      child: Text(className),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Class'),
                  onChanged: (value) {
                    setState(() {
                      selectedClass = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a class' : null,
                ),
                SizedBox(height: 16.0),

                // Section Dropdown
                DropdownButtonFormField<String>(
                  value: selectedSection,
                  items: sectionList.map((section) {
                    return DropdownMenuItem(
                      value: section,
                      child: Text(section),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Section'),
                  onChanged: (value) {
                    setState(() {
                      selectedSection = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a section' : null,
                ),
                SizedBox(height: 16.0),

                // Subject Dropdown
                DropdownButtonFormField<String>(
                  value: selectedSubject,
                  items: subjectList.map((subject) {
                    return DropdownMenuItem(
                      value: subject,
                      child: Text(subject),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Subject'),
                  onChanged: (value) {
                    setState(() {
                      selectedSubject = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a subject' : null,
                ),
                SizedBox(height: 16.0),

                // Deadline Picker
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedDeadline != null
                            ? 'Deadline: ${selectedDeadline!.toLocal().toString().split(' ')[0]}'
                            : 'Select Deadline',
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: pickDeadlineDate,
                    ),
                  ],
                ),
                SizedBox(height: 16.0),

                // Description Field
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.0),

                // Submit Button
                ElevatedButton(
                  onPressed: saveAssignment,
                  child: Text('Save Assignment'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
