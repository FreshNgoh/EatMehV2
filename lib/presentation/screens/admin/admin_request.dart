//
// request_screen.dart (Final)
//
import 'package:flutter/material.dart';
// Adjust these paths
import 'package:eatmehv2/data/models/trainer/trainer_application.dart';
import 'package:eatmehv2/data/repos/trainer_application_repo.dart';
import 'package:eatmehv2/data/services/trainer_application_service.dart';
import 'admin_request_details.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  // Use your repository and service
  final TrainerApplicationRepository _repository =
      TrainerApplicationRepository(TrainerApplicationService());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trainer Request',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      // Use StreamBuilder to get live data from your repository
      body: StreamBuilder<List<TrainerApplication>>(
        stream: _repository.getPendingApplications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No pending applications.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final applications = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80.0),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application = applications[index];
              return RequestListItem(
                application: application, // Use your model
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminRequestDetailsScreen(
                        application: application, // Pass your model
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// --- List Item Widget (Updated) ---
class RequestListItem extends StatelessWidget {
  final TrainerApplication application; // Use your model
  final VoidCallback onTap;

  const RequestListItem({
    super.key,
    required this.application,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey[200],
        child: Icon(Icons.person, color: Colors.grey[600]),
      ),
      title: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Text(
          application.name, // Use data from your model
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      subtitle: Text(
        "Specialization: ${application.specialization}", // Use data from your model
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }
}