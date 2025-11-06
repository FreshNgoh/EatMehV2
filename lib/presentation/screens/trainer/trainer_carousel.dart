import 'package:eatmehv2/data/models/trainer/trainer_profile_model.dart';
import 'package:eatmehv2/data/services/trainer_application_service.dart';
import 'package:eatmehv2/data/services/trainer_profile_service.dart';
import 'package:eatmehv2/presentation/screens/trainer/trainee_list.dart';
import 'package:eatmehv2/presentation/screens/trainer/trainer_instruction.dart';
import 'package:eatmehv2/presentation/screens/trainer/trainer_list.dart';
import 'package:eatmehv2/presentation/widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CarouselApp extends StatelessWidget {
  const CarouselApp({super.key});

  Future<String> _getApplicationStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'none';

    final trainerService = TrainerApplicationService();
    final trainerProfileService = TrainerProfileService();
    final status = await trainerService.getApplicationStatus(user.uid);

    // If approved, ensure trainer profile exists
    if (status == 'approved') {
      final existingProfile = await trainerProfileService.getTrainerProfile(
        user.uid,
      );

      if (existingProfile == null) {
        // Create a default TrainerProfile
        // also need to set the role -> trainer ***
        final profile = TrainerProfile(
          certifications: [],
          rating: 5.0,
          yearsOfExperience: "",
          trainees: [],
        );

        await trainerProfileService.createTrainerProfile(user.uid, profile);
      }
    }
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getApplicationStatus(),
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
          return Carousel(applicationStatus: status);
        }
      },
    );
  }
}

class Carousel extends StatefulWidget {
  final String applicationStatus;
  const Carousel({super.key, required this.applicationStatus});

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  final CarouselController controller = CarouselController(initialItem: 1);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
              controller: controller,
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
                      : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TrainerInstruction(),
                          ),
                        );
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
                text: "Request For Trainer",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TrainerList()),
                  );
                },
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
