import 'package:flutter/material.dart';
import 'admin_request_details.dart'; // <-- 1. ADD THIS IMPORT

// --- Data Model (Reused from UserScreen concept) ---

/// Represents a request profile in the list.
class Request {
  final String name;
  final String description;

  const Request({
    required this.name,
    required this.description,
  });
}

// --- Sample Data ---

final List<Request> sampleRequests = [
  // ... your sample data remains the same ...
  const Request(name: 'John Doe', description: 'Requesting personal training'),
  const Request(name: 'Jane Smith', description: 'Interested in group fitness'),
  const Request(name: 'Mike Ross', description: 'Looking for a cardio coach'),
  const Request(name: 'Rachel Zane', description: 'Seeking nutritional guidance'),
  const Request(name: 'Harvey Specter', description: 'Advanced weight lifting'),
  const Request(name: 'Donna Paulsen', description: 'Yoga and flexibility class'),
  const Request(name: 'Louis Litt', description: 'Marathon training plan'),
  const Request(name: 'Jessica Pearson', description: 'Corporate wellness inquiry'),
  const Request(name: 'Katrina Bennett', description: 'Pilates instructor needed'),
];

// --- Main Screen Widget ---

class RequestScreen extends StatelessWidget {
  const RequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. App Bar
      appBar: AppBar(
        title: const Text(
          'Trainer Request',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),

      // 2. Body: Request List
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80.0),
        itemCount: sampleRequests.length,
        itemBuilder: (context, index) {
          final request = sampleRequests[index];
          return RequestListItem(
            request: request,
            onTap: () {
              // --- 2. MODIFY THIS ---
              // Old SnackBar code removed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AdminRequestDetailsScreen(request: request),
                ),
              );
              // --- END OF MODIFICATION ---
            },
          );
        },
      ),

      // 3. Bottom Navigation Bar (Assuming this is part of the application structure)
    );
  }
}

// --- Custom List Item Widget ---
// (This widget remains exactly the same)

class RequestListItem extends StatelessWidget {
  final Request request;
  final VoidCallback onTap;

  const RequestListItem({
    super.key,
    required this.request,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      // Placeholder Profile Icon (Circle Avatar)
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey[200],
        child: Icon(Icons.person, color: Colors.grey[600]),
      ),
      // Name and Description Text
      title: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Text(
          request.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      subtitle: Text(
        request.description,
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }
}