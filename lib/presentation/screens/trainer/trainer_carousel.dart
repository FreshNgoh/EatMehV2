import 'package:eatmehv2/presentation/widgets/custom_button.dart';
import 'package:eatmehv2/presentation/screens/trainer/trainer_instruction.dart';
import 'package:eatmehv2/presentation/screens/trainer/trainer_list.dart';
import 'package:flutter/material.dart';

class CarouselApp extends StatelessWidget {
  const CarouselApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          surface: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: Scaffold(body: const Carousel()),
    );
  }
}

class Carousel extends StatefulWidget {
  const Carousel({super.key});

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  final CarouselController controller = CarouselController(initialItem: 1);
  bool applyForTrainer = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height;

    return ListView(
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: height / 2),
          child: CarouselView.weighted(
            controller: controller,
            itemSnapping: true,
            flexWeights: const <int>[1, 7, 1],
            children:
                ImageInfo.values.map((ImageInfo image) {
                  return HeroLayoutCard(imageInfo: image);
                }).toList(),
          ),
        ),
        const SizedBox(height: 40),
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
                applyForTrainer ? "Application Submitted" : "Apply as Trainer",
            onPressed:
                applyForTrainer
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
            backgroundColor:
                applyForTrainer ? Colors.green.shade600 : Colors.white,
            textColor: applyForTrainer ? Colors.white : Colors.green.shade600,
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

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
