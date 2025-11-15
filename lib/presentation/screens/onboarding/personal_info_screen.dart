import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/presentation/widgets/toast.dart';
import 'package:eatmehv2/utils/calorie_utils.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
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

  String? _selectedGender;
  String? _selectedDietType;
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
    _selectedGender = widget.user.gender;
    _selectedDietType = widget.user.dietType;

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

    // Validate gender and diet type
    if (_selectedGender == null) {
      final warningMsg = 'Please select your gender';
      showCustomToast(context, warningMsg, type: ToastType.warning);
      return;
    }

    if (_selectedDietType == null) {
      final warningMsg = 'Please select your diet type';
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
        'gender': _selectedGender,
        'dietType': _selectedDietType,
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

  Widget _buildGenderSelector() {
    const genders = ['male', 'female'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          genders.map((gender) {
            final isSelected = _selectedGender == gender;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? (_selectedGender == 'male'
                            ? Colors.blue.withOpacity(0.1)
                            : _selectedGender == 'female'
                            ? Colors.pink.withOpacity(0.1)
                            : Colors.grey[200])
                        : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isSelected
                          ? (_selectedGender == 'male'
                              ? Colors.blue.withOpacity(0.3)
                              : _selectedGender == 'female'
                              ? Colors.pink.withOpacity(0.3)
                              : Colors.grey[200]!)
                          : const Color(0xFFE2E8F0),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => setState(() => _selectedGender = gender),
                borderRadius: BorderRadius.circular(16),
                child: Text(
                  gender,
                  style: TextStyle(
                    color:
                        isSelected
                            ? (_selectedGender == 'male'
                                ? Colors.blue
                                : _selectedGender == 'female'
                                ? Colors.pink
                                : Colors.grey[200])
                            : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildDietSelector() {
    const diets = ['Vegetarian', 'Vegan', 'Omnivore', 'Pescatarian'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          diets.map((diet) {
            final isSelected = _selectedDietType == diet;
            final baseColor = AppColors.getDietColor(diet);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? baseColor.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isSelected
                          ? baseColor.withOpacity(0.3)
                          : const Color(0xFFE2E8F0),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => setState(() => _selectedDietType = diet),
                borderRadius: BorderRadius.circular(16),
                child: Text(
                  diet,
                  style: TextStyle(
                    color: isSelected ? baseColor : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
    );
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

            // Gender Selector
            const Text(
              'Gender',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 10),
            _buildGenderSelector(),
            const SizedBox(height: 20),

            // Diet Type Selector
            const Text(
              'Diet Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 10),
            _buildDietSelector(),
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
