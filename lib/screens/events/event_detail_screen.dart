import 'package:flutter/material.dart';
import 'package:school_erp/screens/events/event.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              "${event.date.toLocal()}".split(' ')[0],
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              event.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            if (event.mediaUrls != null && event.mediaUrls!.isNotEmpty)
              Column(
                children: event.mediaUrls!.map((url) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: url.endsWith('.jpg') || url.endsWith('.png')
                        ? Image.network(
                      url,
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.broken_image, size: 50),
                        );
                      },
                    )
                        : ListTile(
                      leading: const Icon(Icons.insert_drive_file),
                      title: Text(url.split('/').last),
                      onTap: () {
                        // Add logic here to handle PDFs or other file types
                      },
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
