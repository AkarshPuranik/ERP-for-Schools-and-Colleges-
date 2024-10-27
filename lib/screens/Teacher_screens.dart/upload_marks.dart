import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadMarksScreen extends StatefulWidget {
  const UploadMarksScreen({Key? key}) : super(key: key);

  @override
  _UploadMarksScreenState createState() => _UploadMarksScreenState();
}

class _UploadMarksScreenState extends State<UploadMarksScreen> {
  final TextEditingController _enrollmentController = TextEditingController();
  final TextEditingController _mathsController = TextEditingController();
  final TextEditingController _englishController = TextEditingController();
  final TextEditingController _scienceController = TextEditingController();
  final TextEditingController _historyController = TextEditingController();
  String _selectedTestType = 'Half-Yearly';

  final List<String> _testTypes = ['Half-Yearly', 'Weekly', 'Monthly'];

  Future<void> _uploadMarks() async {
    final enrollmentNumber = _enrollmentController.text;
    final mathsMarks = int.tryParse(_mathsController.text) ?? 0;
    final englishMarks = int.tryParse(_englishController.text) ?? 0;
    final scienceMarks = int.tryParse(_scienceController.text) ?? 0;
    final historyMarks = int.tryParse(_historyController.text) ?? 0;

    if (enrollmentNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter enrollment number')));
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('marks')
          .doc(enrollmentNumber)
          .set({
        'enrollmentNumber': enrollmentNumber,
        'testType': _selectedTestType,
        'subjects': {
          'Maths': mathsMarks,
          'English': englishMarks,
          'Science': scienceMarks,
          'History': historyMarks,
        },
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Marks uploaded successfully')));

      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading marks: $e')));
    }
  }

  void _clearForm() {
    _enrollmentController.clear();
    _mathsController.clear();
    _englishController.clear();
    _scienceController.clear();
    _historyController.clear();
    setState(() {
      _selectedTestType = 'Half-Yearly';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Marks')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _enrollmentController,
              decoration: const InputDecoration(
                labelText: 'Enrollment Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedTestType,
              items: _testTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTestType = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Test Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _buildSubjectField('Maths', _mathsController),
            _buildSubjectField('English', _englishController),
            _buildSubjectField('Science', _scienceController),
            _buildSubjectField('History', _historyController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadMarks,
              child: const Text('Upload Marks'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectField(String subject, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: '$subject Marks',
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
