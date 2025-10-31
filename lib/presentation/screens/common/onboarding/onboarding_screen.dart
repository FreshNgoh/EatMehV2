import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../../../blocs/settings/settings_bloc.dart';
import '../../../../routes/app_router.dart';
import '../../../../data/dummy_data.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Welcome to EatMeh!",
          body:
              "Track your meals, connect with friends, and achieve your health goals together.",
          image: Center(
            child: Image.asset('assets/logo.png', height: 200),
          ),
          decoration: _getPageDecoration(),
        ),
        PageViewModel(
          title: "AI-Powered Meal Analysis",
          body:
              "Simply take a photo of your meal and let our AI analyze the calories and nutrition for you.",
          image: Center(
            child: Icon(Icons.camera_alt, size: 150, color: Color(0xFF4CAF50)),
          ),
          decoration: _getPageDecoration(),
        ),
        PageViewModel(
          title: "Share Your Journey",
          body:
              "Post your meals as stories and see what your friends are eating. Stay motivated together!",
          image: Center(
            child: Icon(Icons.people, size: 150, color: Color(0xFF2196F3)),
          ),
          decoration: _getPageDecoration(),
        ),
        PageViewModel(
          title: "Track Your Progress",
          body:
              "Monitor your calorie intake, exercise, and watch your health status improve over time.",
          image: Center(
            child: Icon(Icons.analytics, size: 150, color: Color(0xFFFF9800)),
          ),
          decoration: _getPageDecoration(),
        ),
      ],
      onDone: () {
        context.read<SettingsBloc>().add(SettingsOnboardingCompleted());
        final user = DummyData.currentUser;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AppRouter.getHomeScreen(user.role),
          ),
        );
      },
      onSkip: () {
        context.read<SettingsBloc>().add(SettingsOnboardingCompleted());
        final user = DummyData.currentUser;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AppRouter.getHomeScreen(user.role),
          ),
        );
      },
      showSkipButton: true,
      skip: const Text("Skip", style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: const Color(0xFF191919),
        color: Colors.grey.shade300,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }

  PageDecoration _getPageDecoration() {
    return PageDecoration(
      titleTextStyle: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      bodyTextStyle: const TextStyle(fontSize: 16),
      bodyPadding: const EdgeInsets.all(16),
      pageColor: Colors.white,
      imagePadding: const EdgeInsets.only(top: 100),
    );
  }
}
