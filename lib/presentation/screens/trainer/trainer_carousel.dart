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
import 'package:eatmehv2/presentation/screens/user/user_goals.dart';
import 'package:eatmehv2/presentation/widgets/custom_action_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  Future<String> _getApplicationStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    final trainerAppRepo = TrainerApplicationRepository(
      TrainerApplicationService(),
    );
    final trainerProfileRepo = TrainerProfileRepo(TrainerProfileService());
    final status = await trainerAppRepo.fetchApplicationStatus(user!.uid);

    if (status == 'approved') {
      final existingProfile = await trainerProfileRepo.getTrainerProfile(
        user.uid,
      );
      final data = await trainerAppRepo.getTrainerApplicationData(user.uid);
      final certifications = data?['certifications'] as List<String>;
      final yearsOfExperience = data?['yearsOfExperience'] as String;

      if (existingProfile == null) {
        final profile = TrainerProfile(
          certifications: certifications,
          rating: 0.0,
          yearsOfExperience: yearsOfExperience,
          trainees: [],
        );

        await trainerProfileRepo.createTrainerProfile(user.uid, profile);
      }
    }
    return status;
  }

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
  final authState = context.read<AuthBloc>().state as Authenticated;
  final currentUserUid = authState.user.uid;
  final userRepo = UserRepository();

  final userModel = await userRepo.getUser(currentUserUid);

  final bool hasSetGoals = userModel?.goalType != null;

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
  int _currentPage = 0;
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Header Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      'Transform Your Life',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Choose your path to a healthier you',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Carousel Section
              SizedBox(
                height: 320,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index % ImageInfo.values.length;
                    });
                  },
                  itemCount: 1000, // Infinite scroll
                  itemBuilder: (context, index) {
                    final actualIndex = index % ImageInfo.values.length;
                    final imageInfo = ImageInfo.values[actualIndex];
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double value = 1.0;
                        if (_pageController.position.haveDimensions) {
                          value = _pageController.page! - index;
                          value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                        }
                        return Center(
                          child: SizedBox(
                            height: Curves.easeOut.transform(value) * 320,
                            child: child,
                          ),
                        );
                      },
                      child: HeroLayoutCard(imageInfo: imageInfo),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Page Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  ImageInfo.values.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          _currentPage == index
                              ? Colors.green.shade600
                              : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Action Cards Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Trainer Card
                    CustomActionCard(
                      context: context,
                      title: 'Become a Trainer',
                      subtitle: 'Share your expertise and inspire others',
                      icon: Icons.fitness_center,
                      gradient: LinearGradient(
                        colors: [Colors.green.shade600, Colors.green.shade400],
                      ),
                      isPending: widget.applicationStatus == 'pending',
                      onTap:
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
                    ),

                    const SizedBox(height: 16),

                    // Trainee Card
                    if (widget.applicationStatus != 'pending')
                      CustomActionCard(
                        context: context,
                        title:
                            widget.hasTrainer
                                ? 'Chat with Trainer'
                                : 'Get a Trainer',
                        subtitle:
                            widget.hasTrainer
                                ? 'Continue your fitness journey'
                                : 'Find an expert to guide you',
                        icon:
                            widget.hasTrainer
                                ? Icons.chat_bubble
                                : Icons.person_search,
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade600, Colors.blue.shade400],
                        ),
                        isOutlined: true,
                        onTap:
                            widget.hasTrainer
                                ? () => _navigateToTrainerChat(context)
                                : () => _navigateBasedOnGoal(context),
                      ),

                    const SizedBox(height: 32),

                    // Features Section
                    _buildFeaturesSection(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why Choose Us?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade900,
          ),
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(
          icon: Icons.verified_user,
          title: 'Certified Trainers',
          subtitle: 'Work with verified fitness professionals',
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.track_changes,
          title: 'Track Progress',
          subtitle: 'Monitor your journey with detailed analytics',
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.people,
          title: 'Community Support',
          subtitle: 'Join a community of fitness enthusiasts',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HeroLayoutCard extends StatelessWidget {
  const HeroLayoutCard({super.key, required this.imageInfo});

  final ImageInfo imageInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image with gradient overlay
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/images/default_face.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'Success Story',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    imageInfo.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '5.0',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
