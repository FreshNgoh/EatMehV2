import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/data/models/notification/notification_model.dart';
import 'package:eatmehv2/data/repos/notification_repo.dart';
import 'package:eatmehv2/data/repos/trainer_profile_repo.dart';
import 'package:eatmehv2/data/services/notification_service.dart';
import 'package:eatmehv2/data/services/trainer_profile_service.dart';
import 'package:eatmehv2/presentation/screens/user/profile_screen.dart';
import 'package:eatmehv2/presentation/widgets/custom_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Trainer List'),
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
              ? const Center(child: Text("No trainers available"))
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
                    onProfileTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  ProfileScreen(userUid: trainer['uid']),
                        ),
                      );
                    },
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
                            title: "New trainee request",
                            message: 'A user has requested to be your trainee.',
                            type: 'trainer_request',
                            status: 'pending',
                            createdAt: Timestamp.now(),
                          );
                          await notificationRepo.sendNotification(request);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Trainer request sent to ${trainer['name']}',
                              ),
                            ),
                          );
                        },
                        tooltip: 'Request Trainer',
                      ),
                    ],
                  );
                },
              ),
    );
  }
}
