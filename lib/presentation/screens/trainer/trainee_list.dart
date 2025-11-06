import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/data/repos/trainer_profile_repo.dart';
import 'package:eatmehv2/data/services/trainer_profile_service.dart';
import 'package:eatmehv2/presentation/widgets/trainee_chat_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TraineeList extends StatefulWidget {
  const TraineeList({super.key});

  @override
  State<TraineeList> createState() => _TraineeListState();
}

class _TraineeListState extends State<TraineeList> {
  final trainerProfileRepo = TrainerProfileRepo(TrainerProfileService());
  bool _loading = true;
  List<Map<String, dynamic>> _trainees = [];
  String? currentUserUid;

  @override
  void initState() {
    super.initState();
    _loadTrainees();
  }

  Future<void> _loadTrainees() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      return;
    }

    currentUserUid = authState.user.uid;

    final trainerProfile = await trainerProfileRepo.getTrainerProfile(
      currentUserUid!,
    );

    if (trainerProfile == null || trainerProfile.trainees.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    final trainees = await trainerProfileRepo.getTraineesDetails(
      trainerProfile.trainees,
      currentUserUid!,
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
                  return TraineeChatPreview(
                    currentUserUid: currentUserUid!,
                    traineeUid: trainee['uid'],
                    traineeName: trainee['name'],
                    traineeImage: trainee['image'],
                  );
                },
              ),
    );
  }
}
