import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/data/models/notification/notification_model.dart';
import 'package:eatmehv2/data/repos/notification_repo.dart';
import 'package:eatmehv2/data/repos/trainer_profile_repo.dart';
import 'package:eatmehv2/data/services/notification_service.dart';
import 'package:eatmehv2/data/services/trainer_profile_service.dart';
import 'package:eatmehv2/presentation/screens/trainer/trainer_chat_room.dart';
import 'package:eatmehv2/presentation/widgets/custom_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- ADD THIS IMPORT ---
// (Adjust the path to your app_localizations.dart file)
import 'package:eatmehv2/core/localization/app_localizations.dart';

class TrainerList extends StatefulWidget {
  const TrainerList({super.key});

  @override
  State<TrainerList> createState() => _TrainerListState();
}

class _TrainerListState extends State<TrainerList> {
  final trainerProfileRepo = TrainerProfileRepo(TrainerProfileService());
  final notificationRepo = NotificationRepo(NotificationService());

  bool isLoading = true;
  List<Map<String, dynamic>> trainers = [];

  @override
  void initState() {
    super.initState();
    fetchTrainers();
  }

  Future<void> fetchTrainers() async {
    final result = await trainerProfileRepo.getAllTrainers();
    // print('Trainer profile: $result');
    setState(() {
      trainers = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- ADDED ---
    final loc = context.loc; // Get localization object

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // --- UPDATED ---
        title: Text(loc.trainerListTitle),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : trainers.isEmpty
                  // --- UPDATED ---
                  ? Center(child: Text(loc.trainerListNoTrainers))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 30,
                      ),
                      itemCount: trainers.length,
                      itemBuilder: (context, index) {
                        final trainer = trainers[index];
                        return CustomList(
                          profile: CircleAvatar(
                            backgroundImage: AssetImage(
                              'assets/images/default_face.jpeg',
                            ),
                          ),
                          value: trainer['name'],
                          actionIcons: [
                            ListActionIcon(
                              icon: Icons.add,
                              onPressed: () async {
                                final authState =
                                    context.read<AuthBloc>().state as Authenticated;
                                final currentUser = authState.user.uid;

                                final request = NotificationModel(
                                  senderUid: currentUser,
                                  receiverUid: trainer['uid'],
                                  // --- UPDATED ---
                                  title: loc.trainerListRequestTitle,
                                  message: loc.trainerListRequestMessage,
                                  type: 'trainer_request',
                                  status: 'pending',
                                  createdAt: Timestamp.now(),
                                );
                                await notificationRepo.sendNotification(request);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    // --- UPDATED ---
                                    content: Text(
                                      loc.trainerListRequestSent(trainer['name']),
                                    ),
                                  ),
                                );
                              },
                              // --- UPDATED ---
                              tooltip: loc.trainerListRequestTooltip,
                            ),
                          ],
                          onFieldTap: () {
                            // ... (your navigation logic)
                          },
                        );
                      },
                    ),
    );
  }
}