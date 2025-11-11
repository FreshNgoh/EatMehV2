import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../data/models/user/user_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../screens/admin/admin_screen.dart';
import '../../screens/user/home_screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  final UserModel user;
  const PersonalInfoScreen({super.key, required this.user});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _bmiController = TextEditingController();

  bool _isLoading = false;

  void _updateBMI() {
    final heightCm = double.tryParse(_heightController.text);
    final weightKg = double.tryParse(_weightController.text);

    if (heightCm != null && weightKg != null && heightCm > 0) {
      final heightM = heightCm / 100;
      final bmi = weightKg / (heightM * heightM);
      _bmiController.text = bmi.toStringAsFixed(2);
    } else {
      _bmiController.text = '';
    }
  }

  @override
  void initState() {
    super.initState();
    _ageController.text = widget.user.age?.toString() ?? '';
    _heightController.text = widget.user.height?.toString() ?? '';
    _weightController.text = widget.user.weight?.toString() ?? '';
    _bmiController.text = widget.user.bmi?.toStringAsFixed(2) ?? '';

    _heightController.addListener(_updateBMI);
    _weightController.addListener(_updateBMI);
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bmiController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final age = int.tryParse(_ageController.text);
      final height = double.tryParse(_heightController.text);
      final weight = double.tryParse(_weightController.text);
      final bmi = double.tryParse(_bmiController.text);

      final updatedData = {
        'age': age,
        'height': height,
        'weight': weight,
        'bmi': bmi,
        'settings.showOnboarding': false,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update(updatedData);

      // Navigate based on role
      Widget nextScreen;
      switch (widget.user.role) {
        case 'admin':
          nextScreen = const AdminScreen();
          break;
        case 'trainer':
          nextScreen = const HomeScreen();
          break;
        default:
          nextScreen = const HomeScreen();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save info: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Tell us a bit about yourself 💪",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Age
          CustomTextField(
            controller: _ageController,
            label: 'Age',
            hint: 'Enter your age',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.cake_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Age is required';
              }
              final age = int.tryParse(value);
              if (age == null || age <= 0) {
                return 'Enter a valid age';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Height
          CustomTextField(
            controller: _heightController,
            label: 'Height (cm)',
            hint: 'Enter your height',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.height_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Height is required';
              }
              final height = double.tryParse(value);
              if (height == null || height <= 0) {
                return 'Enter a valid height';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Weight
          CustomTextField(
            controller: _weightController,
            label: 'Weight (kg)',
            hint: 'Enter your weight',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.monitor_weight_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Weight is required';
              }
              final weight = double.tryParse(value);
              if (weight == null || weight <= 0) {
                return 'Enter a valid weight';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // BMI (read-only)
          CustomTextField(
            controller: _bmiController,
            readOnly: true,
            enabled: false,
            label: 'BMI',
            hint: 'Body Mass Index',
            prefixIcon: Icons.line_style_outlined,
          ),
          const SizedBox(height: 30),

          // Start EatMeh button
          ElevatedButton(
            onPressed: _isLoading ? null : () => _completeOnboarding(context),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.green,
            ),
            child:
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                      "Start EatMeh",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
