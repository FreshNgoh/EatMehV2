import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/presentation/widgets/toast.dart';
import 'package:eatmehv2/utils/calorie_utils.dart';
import 'package:flutter/material.dart';

import '../../../data/models/user/user_model.dart';
import '../../screens/admin/admin_screen.dart';
import '../../screens/user/home_screen.dart';
import '../../widgets/custom_text_field.dart';

class PersonalInfoController {
  void Function()? completeOnboarding;
}

class PersonalInfoScreen extends StatefulWidget {
  final UserModel user;
  final bool showButton;
  final PersonalInfoController? controller;

  const PersonalInfoScreen({
    super.key,
    required this.user,
    this.showButton = true,
    this.controller,
  });

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
    final heightCm = double.tryParse(_heightController.text.trim());
    final weightKg = double.tryParse(_weightController.text.trim());

    final bmi = CalorieUtils.calculateBMI(
      heightCm: heightCm,
      weightKg: weightKg,
    );

    if (bmi == null) {
      _bmiController.text = '';
    } else {
      _bmiController.text = bmi.toStringAsFixed(2);
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

    widget.controller?.completeOnboarding = () => _completeOnboarding(context);
  }

  // Public method that can be called from parent
  void completeOnboarding() {
    _completeOnboarding(context);
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
    if (!_formKey.currentState!.validate()) {
      final warningMsg = 'Please fill in all required fields';
      showCustomToast(context, warningMsg, type: ToastType.warning);
      return;
    }

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
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update(updatedData);

      if (!context.mounted) return;

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
      if (!context.mounted) return;
      final errorMsg = 'Failed to save: $e ';
      showCustomToast(context, errorMsg, type: ToastType.error);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      onWillPop: () async => !_isLoading, // Prevent back button during loading
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Image.asset('assets/logo/logo.png', height: 130)),
            const SizedBox(height: 15),

            const Text(
              "Tell us a bit about yourself!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                if (age > 150) {
                  return 'Please enter a realistic age';
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
                if (height < 50 || height > 300) {
                  return 'Please enter a realistic height';
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
                if (weight > 500) {
                  return 'Please enter a realistic weight';
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

            if (widget.showButton) ...[
              const SizedBox(height: 30),
              // Start EatMeh button (only shown when showButton is true)
              ElevatedButton(
                onPressed:
                    _isLoading ? null : () => _completeOnboarding(context),
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
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
