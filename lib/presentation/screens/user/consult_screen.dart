import 'package:eatmehv2/presentation/screens/trainer/trainee_list.dart';
import 'package:eatmehv2/presentation/screens/trainer/trainer_carousel.dart';
import 'package:flutter/material.dart';

class ConsultScreen extends StatefulWidget {
  const ConsultScreen({super.key});

  @override
  State<ConsultScreen> createState() => _ConsultScreenState();
}

class _ConsultScreenState extends State<ConsultScreen> {
  bool isTrainer = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isTrainer ? const TraineeList() : const Center(child: CarouselApp()),
    );
  }
}
