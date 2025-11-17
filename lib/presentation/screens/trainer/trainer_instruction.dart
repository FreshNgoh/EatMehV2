import 'package:eatmehv2/presentation/widgets/custom_button.dart';
import 'package:eatmehv2/presentation/screens/trainer/trainer_form.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:eatmehv2/core/localization/app_localizations.dart';

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
    final loc = context.loc;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: Colors.black87,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(loc.trainerInstructionTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SmoothPageIndicator(
                controller: controller,
                count: 3,
                effect: ExpandingDotsEffect(
                  spacing: 8.0,
                  radius: 6.0,
                  dotWidth: 10.0,
                  dotHeight: 10.0,
                  expansionFactor: 4,
                  dotColor: Colors.grey.shade300,
                  activeDotColor: Colors.green.shade600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Content
            Expanded(
              child: PageView(
                controller: controller,
                onPageChanged: (index) => setState(() => currentPage = index),
                children: [
                  _buildInstruction(
                    icon: Icons.fitness_center,
                    iconColor: Colors.green.shade600,
                    title: loc.trainerInstructionPage1Title,
                    text: loc.trainerInstructionPage1Sub,
                    gradient: LinearGradient(
                      colors: [Colors.green.shade50, Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  _buildInstruction(
                    icon: Icons.restaurant_menu,
                    iconColor: Colors.orange.shade600,
                    title: loc.trainerInstructionPage2Title,
                    text: loc.trainerInstructionPage2Sub,
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade50, Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  _buildInstruction(
                    icon: Icons.trending_up,
                    iconColor: Colors.blue.shade600,
                    title: loc.trainerInstructionPage3Title,
                    text: loc.trainerInstructionPage3Sub,
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Section with Button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (currentPage < 2)
                    TextButton(
                      onPressed: () {
                        controller.animateToPage(
                          2,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        loc.trainerInstructionButtonSkip,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Colors.green.shade600, Colors.green.shade500],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade600.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CustomButton(
                      text: currentPage == 2
                          ? loc.trainerInstructionButtonFinish
                          : loc.trainerInstructionButtonNext,
                      onPressed: _moveNextPage,
                      backgroundColor: Colors.transparent,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String text,
    required Gradient gradient,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, size: 70, color: iconColor),
            ),
          ),
          const SizedBox(height: 50),
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              color: Colors.black87,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w400,
                height: 1.6,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}