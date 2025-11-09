import 'package:eatmehv2/presentation/widgets/custom_button.dart';
import 'package:eatmehv2/presentation/screens/trainer/trainer_form.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class TrainerInstruction extends StatefulWidget {
  const TrainerInstruction({super.key});

  @override
  State<TrainerInstruction> createState() => _TrainerInstructionState();
}

class _TrainerInstructionState extends State<TrainerInstruction> {
  final PageController controller = PageController();
  int currentPage = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _moveNextPage() async {
    if (currentPage < 2) {
      controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TrainerForm()),
      );

      if (result == 'submitted') {
        Navigator.pop(context, 'submitted');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Trainer Instruction'),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          SmoothPageIndicator(
            controller: controller,
            count: 3,
            effect: const SlideEffect(
              spacing: 8.0,
              radius: 5.0,
              dotWidth: 15.0,
              dotHeight: 8.0,
              paintStyle: PaintingStyle.stroke,
              strokeWidth: 1.5,
              dotColor: Colors.grey,
              activeDotColor: Colors.green,
            ),
          ),
          Expanded(
            child: PageView(
              controller: controller,
              onPageChanged: (index) => setState(() => currentPage = index),
              children: [
                _buildInstruction(
                  image: 'assets/images/default_face.jpeg',
                  text:
                      'Welcome to Trainer Mode! Help users achieve their goals.',
                ),
                _buildInstruction(
                  image: 'assets/images/default_face.jpeg',
                  text:
                      'Instruction 1: Set personalized diet goals for each trainee.',
                ),
                _buildInstruction(
                  image: 'assets/images/default_face.jpeg',
                  text:
                      'Instruction 2: Monitor progress weekly and adjust plans.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: CustomButton(
              text: currentPage == 2 ? "Finish" : "Next",
              onPressed: _moveNextPage,
              backgroundColor: Colors.green.shade600,
              textColor: Colors.white,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInstruction({required String image, required String text}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(image, height: 400, width: 400, fit: BoxFit.cover),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
