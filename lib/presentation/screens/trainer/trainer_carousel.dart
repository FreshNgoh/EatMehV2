import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/data/models/trainer/trainer_profile_model.dart';
import 'package:eatmehv2/data/repos/trainer_application_repo.dart';
import 'package:eatmehv2/data/repos/trainer_profile_repo.dart';
import 'package:eatmehv2/data/repos/user_repo.dart';
import 'package:eatmehv2/data/services/trainer_application_service.dart';
import 'package:eatmehv2/data/services/trainer_profile_service.dart';
import 'package:eatmehv2/presentation/screens/trainer/trainee_list.dart';
import 'package:eatmehv2/presentation/screens/trainer/trainer_chat_room.dart';
import 'package:eatmehv2/presentation/screens/trainer/trainer_instruction.dart';
import 'package:eatmehv2/presentation/screens/trainer/trainer_list.dart';
import 'package:eatmehv2/presentation/screens/user/onBoarding/user_goals.dart';
import 'package:eatmehv2/presentation/widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarouselApp extends StatefulWidget {
  const CarouselApp({super.key});

  @override
  State<CarouselApp> createState() => _CarouselAppState();
}

class _CarouselAppState extends State<CarouselApp> {
  late Future<String> _statusFuture;
  final userRepo = UserRepository();
  bool hasTrainer = false;
  bool isCheckingTrainer = true;

  @override
  void initState() {
    super.initState();
    _statusFuture = _getApplicationStatus();
    checkCurrentTrainer();
  }

  // check if apply as trainer
  Future<String> _getApplicationStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'none';

    final trainerAppRepo = TrainerApplicationRepository(
      TrainerApplicationService(),
    );
    final trainerProfileRepo = TrainerProfileRepo(TrainerProfileService());
    final status = await trainerAppRepo.fetchApplicationStatus(user.uid);

    // If approved, ensure trainer profile exists
    if (status == 'approved') {
      final existingProfile = await trainerProfileRepo.getTrainerProfile(
        user.uid,
      );

      if (existingProfile == null) {
        final profile = TrainerProfile(
          certifications: [],
          rating: 5.0,
          yearsOfExperience: "",
          trainees: [],
        );

        await trainerProfileRepo.createTrainerProfile(user.uid, profile);
      }
    }
    return status;
  }

  // check have trainer
  Future<void> checkCurrentTrainer() async {
    final authState = context.read<AuthBloc>().state as Authenticated;
    final currentUserUid = authState.user.uid;
    final currentTrainer = await userRepo.getCurrentTrainer(currentUserUid);

    setState(() {
      hasTrainer = currentTrainer != null;
      isCheckingTrainer = false;
    });
  }

  Future<void> _refreshStatus() async {
    final newStatus = await _getApplicationStatus();
    setState(() {
      _statusFuture = Future.value(newStatus);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isCheckingTrainer) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return FutureBuilder<String>(
      future: _statusFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Something went wrong.')),
          );
        }

        final status = snapshot.data ?? 'none';

        if (status == 'approved') {
          return const TraineeList();
        } else {
          return Carousel(
            applicationStatus: status,
            hasTrainer: hasTrainer,
            onRefresh: _refreshStatus,
          );
        }
      },
    );
  }
}

class Carousel extends StatefulWidget {
  final String applicationStatus;
  final Future<void> Function() onRefresh;
  final bool hasTrainer;

  const Carousel({
    super.key,
    required this.applicationStatus,
    required this.onRefresh,
    this.hasTrainer = false,
  });

  @override
  State<Carousel> createState() => _CarouselState();
}

Future<void> _navigateBasedOnGoal(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final user = FirebaseAuth.instance.currentUser;
  bool hasSetGoals = false;

  if (user != null) {
    hasSetGoals = prefs.getBool('hasSetGoals_${user.uid}') ?? false;
  }

  if (hasSetGoals) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TrainerList()),
    );
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserGoals()),
    );
  }
}

class _CarouselState extends State<Carousel> {
  final userRepo = UserRepository();

  Future<void> _navigateToTrainerChat(BuildContext context) async {
    final authState = context.read<AuthBloc>().state as Authenticated;
    final currentUserUid = authState.user.uid;
    final trainer = await userRepo.getCurrentTrainer(currentUserUid);

    if (trainer != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => TrainerChatRoom(
                receiverUid: trainer.uid,
                receiverName: trainer.username,
                receiverImage: trainer.imageUrl ?? '',
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 30),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: height / 2),
            child: CarouselView.weighted(
              itemSnapping: true,
              flexWeights: const <int>[1, 7, 1],
              children:
                  ImageInfo.values
                      .map(
                        (ImageInfo image) => HeroLayoutCard(imageInfo: image),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Text(
                  "Ready to start your healthy journey?",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Choose to guide others as a trainer, or connect with one to reach your goals.",
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Apply Trainer Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: CustomButton(
              text:
                  widget.applicationStatus == 'pending'
                      ? "Application Pending"
                      : "Apply as Trainer",
              onPressed:
                  widget.applicationStatus == 'pending'
                      ? null
                      : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TrainerInstruction(),
                          ),
                        );

                        if (result == 'submitted') {
                          await widget.onRefresh();
                        }
                      },
              backgroundColor: Colors.green.shade600,
              textColor: Colors.white,
            ),
          ),
          const SizedBox(height: 25),

          // Request Trainer Button
          if (widget.applicationStatus != 'pending')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: CustomButton(
                text:
                    widget.hasTrainer
                        ? "Chat with Your Trainer"
                        : "Request For Trainer",
                onPressed:
                    widget.hasTrainer
                        ? () => _navigateToTrainerChat(context)
                        : () => _navigateBasedOnGoal(context),
                backgroundColor: Colors.white,
                textColor: Colors.green.shade600,
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// HERO LAYOUT
class HeroLayoutCard extends StatelessWidget {
  const HeroLayoutCard({super.key, required this.imageInfo});

  final ImageInfo imageInfo;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return Stack(
      alignment: AlignmentDirectional.bottomStart,
      children: <Widget>[
        ClipRect(
          child: OverflowBox(
            maxWidth: width * 7 / 8,
            minWidth: width * 7 / 8,
            child: Image(
              fit: BoxFit.cover,
              image: AssetImage('assets/images/default_face.jpeg'),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                imageInfo.title,
                overflow: TextOverflow.clip,
                softWrap: false,
                style: Theme.of(
                  context,
                ).textTheme.headlineLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }
}

enum ImageInfo {
  image0('Micky', 'content_based_color_scheme_1.png'),
  image1('Nancy', 'content_based_color_scheme_2.png'),
  image2('Adeline', 'content_based_color_scheme_3.png'),
  image3('Handsome', 'content_based_color_scheme_4.png'),
  image4('Haha', 'content_based_color_scheme_5.png'),
  image5('Rainy', 'content_based_color_scheme_6.png');

  const ImageInfo(this.title, this.url);
  final String title;
  final String url;
}
