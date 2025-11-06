import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/data/services/trainer_profile_service.dart';
import 'package:flutter/material.dart';
import 'package:eatmehv2/presentation/screens/trainer/trainer_chat_room.dart';
import 'package:eatmehv2/presentation/widgets/custom_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TraineeList extends StatefulWidget {
  const TraineeList({super.key});

  @override
  State<TraineeList> createState() => _TraineeListState();
}

class _TraineeListState extends State<TraineeList> {
  final trainerService = TrainerProfileService();
  bool _loading = true;
  List<Map<String, dynamic>> _trainees = [];

  @override
  void initState() {
    super.initState();
    _loadTrainees();
  }

  Future<void> _loadTrainees() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to apply.')),
      );
      return;
    }
    final userUid = authState.user.uid;

    final trainerProfile = await trainerService.getTrainerProfile(userUid);
    // print('Trainer profile: ${trainerProfile?.toMap()}');

    if (trainerProfile == null || trainerProfile.trainees.isEmpty) {
      // print('No trainees found.');
      setState(() => _loading = false);
      return;
    }

    final trainees = await trainerService.getTraineesDetails(
      trainerProfile.trainees,
    );

    setState(() {
      _trainees = trainees;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trainee List')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _trainees.isEmpty
              ? const Center(child: Text('No trainees yet.'))
              : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                itemCount: _trainees.length,
                itemBuilder: (context, index) {
                  final trainee = _trainees[index];
                  return CustomList(
                    value: trainee['name'] ?? 'No Name',
                    actionIcons: [
                      ListActionIcon(
                        icon: Icons.wechat,
                        tooltip: 'Message trainee',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => TrainerChatRoom(
                                    receiverUid: trainee['uid'],
                                    receiverName: trainee['name'],
                                    receiverImage: trainee['image'],
                                  ),
                            ),
                          );
                        },
                      ),
                    ],
                    onFieldTap: () {},
                  );
                },
              ),
    );
  }
}
