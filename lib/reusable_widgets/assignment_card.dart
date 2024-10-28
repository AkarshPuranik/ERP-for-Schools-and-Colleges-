import 'package:flutter/material.dart';

class AssignmentCard extends StatelessWidget {
  final String description;
  final String subject;
  final String deadline;
  final VoidCallback onTapSubmit;

  const AssignmentCard({
    super.key,
    required this.description,
    required this.subject,
    required this.deadline,
    required this.onTapSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(subject),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: $description'),
            Text('Deadline: $deadline'),
          ],
        ),
        onTap: onTapSubmit,
      ),
    );
  }
}
