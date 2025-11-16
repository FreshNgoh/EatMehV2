import 'package:flutter/material.dart';
import 'package:eatmehv2/data/models/trainer/trainer_application.dart';
import 'package:eatmehv2/data/repos/trainer_application_repo.dart';
import 'package:eatmehv2/data/services/trainer_application_service.dart';
import 'admin_request_details.dart';
import 'package:eatmehv2/core/localization/app_localizations.dart';

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
    final loc = context.loc; // Get localization object

    return Scaffold(
      // Use StreamBuilder to get live data from your repository
      body: StreamBuilder<List<TrainerApplication>>(
        stream: _repository.getPendingApplications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // --- UPDATED ---
            return Center(child: Text(loc.adminRequestErrorLoad(snapshot.error.toString())));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                // --- UPDATED ---
                loc.adminRequestNoPending,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
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
                application: application, 
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
  final TrainerApplication application; 
  final VoidCallback onTap;

  const RequestListItem({
    super.key,
    required this.application,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // --- ADDED ---
    final loc = context.loc; // Get localization object

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
        // --- UPDATED ---
        "${loc.adminRequestSpecPrefix}${application.specialization}",
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }
}