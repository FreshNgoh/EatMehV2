import 'dart:io';

import 'package:eatmehv2/core/theme/app_colors.dart';
import 'package:eatmehv2/presentation/widgets/toast.dart';
import 'package:eatmehv2/utils/firebase_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/user/user_model.dart';
import '../../../data/repos/user_repo.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfile extends StatefulWidget {
  final UserModel user;

  const EditProfile({super.key, required this.user});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _bmiController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedGender;
  String? _selectedDietType;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  File? _newImageFile;
  String? _avatarUrl;

  final _userRepo = UserRepository();
  final _firebaseStorageService = FirebaseStorageService();

  void _updateBMI() {
    final heightCm = double.tryParse(_heightController.text);
    final weightKg = double.tryParse(_weightController.text);

    if (heightCm != null && weightKg != null && heightCm > 0) {
      final heightM = heightCm / 100;
      final bmi = weightKg / (heightM * heightM);
      _bmiController.text = bmi.toStringAsFixed(2); // show 2 decimals
    } else {
      _bmiController.text = '';
    }
  }

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.user.username;
    _bioController.text = widget.user.bio ?? '';
    _ageController.text = widget.user.age?.toString() ?? '';
    _heightController.text = widget.user.height?.toString() ?? '';
    _weightController.text = widget.user.weight?.toString() ?? '';
    _selectedGender = widget.user.gender;
    _selectedDietType = widget.user.dietType;
    _bmiController.text = widget.user.bmi?.toStringAsFixed(2) ?? '';
    _avatarUrl = widget.user.imageUrl;

    // Initial BMI calculation
    _updateBMI();

    // Add listeners to update BMI automatically
    _heightController.addListener(_updateBMI);
    _weightController.addListener(_updateBMI);
  }

  @override
  void dispose() {
    _bmiController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _newImageFile = File(pickedFile.path);
        _avatarUrl = _newImageFile!.path; // preview locally
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? uploadedUrl = widget.user.imageUrl;

      // Upload new profile image if selected
      if (_newImageFile != null) {
        uploadedUrl = await _firebaseStorageService.uploadMealImage(
          file: _newImageFile!,
          userUid: widget.user.uid,
          folderName: 'profile_images',
        );
      }

      final bioText = _bioController.text.trim();

      final updatedData = {
        'username': _usernameController.text.trim(),
        'bio': bioText.isEmpty ? '' : bioText,
        'age': int.tryParse(_ageController.text),
        'gender': _selectedGender,
        'height': double.tryParse(_heightController.text),
        'weight': double.tryParse(_weightController.text),
        'dietType': _selectedDietType,
        'imageUrl': uploadedUrl,
        'bmi': double.tryParse(_bmiController.text),
      };

      // ✅ 1. Update password if entered
      if (_passwordController.text.isNotEmpty) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          try {
            await user.updatePassword(_passwordController.text.trim());
          } on FirebaseAuthException catch (e) {
            if (e.code == 'requires-recent-login') {
              final warningMsg =
                  'Please re-login before changing your password.';
              showCustomToast(context, warningMsg, type: ToastType.warning);
              setState(() => _isLoading = false);
              return;
            } else {
              throw Exception('Password update failed: ${e.message}');
            }
          }
        }
      }

      // ✅ 2. Clean null values (but keep FieldValue.delete)
      updatedData.removeWhere((key, value) => value == null);

      // ✅ 3. Update Firestore user document
      await _userRepo.updateUser(widget.user.uid, updatedData);

      final successMsg = 'Profile updated successfully!';
      showCustomToast(context, successMsg, type: ToastType.success);

      Navigator.pop(context, true);
    } catch (e) {
      final errorMsg = 'Update failed: ${e.toString()}';
      showCustomToast(context, errorMsg, type: ToastType.error);
    } finally {
      setState(() => _isLoading = false);
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
                          : const Color(
                            0xFFE2E8F0,
                          ), // use the original unselected border color
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
    final ImageProvider avatarImage;
    if (_newImageFile != null) {
      avatarImage = FileImage(_newImageFile!); // local picked image
    } else if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      avatarImage = NetworkImage(_avatarUrl!); // from Firestore
    } else {
      avatarImage = const AssetImage('assets/teralero.png'); // fallback
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Avatar with edit functionality
                      InkWell(
                        onTap: _pickImage, // tap anywhere
                        borderRadius: BorderRadius.circular(80),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(80),
                              child: SizedBox(
                                width: 150,
                                height: 150,
                                child: Image(
                                  image: avatarImage, // use ImageProvider here
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // User ID row with copy on long press
                      GestureDetector(
                        onLongPress: () {
                          Clipboard.setData(
                            ClipboardData(text: widget.user.uid),
                          );
                          final infoMsg = 'User ID copied to clipboard!';
                          showCustomToast(
                            context,
                            infoMsg,
                            type: ToastType.success,
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.user.uid,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.copy,
                              size: 14,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Username
                CustomTextField(
                  controller: _usernameController,
                  label: 'Username',
                  hint: 'Enter your username',
                  prefixIcon: Icons.person_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username cannot be empty';
                    }
                    if (value.length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Bio
                CustomTextField(
                  controller: _bioController,
                  label: 'Bio',
                  hint: 'Tell something about yourself',
                  prefixIcon: Icons.text_snippet_outlined,
                  maxLines: 1,
                  validator: (value) {
                    if (value != null && value.length > 150) {
                      return 'Bio cannot exceed 150 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

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

                // Gender & Diet selectors (keep your previous _buildGenderSelector and _buildDietSelector)
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
                const SizedBox(height: 20),

                // Password
                CustomTextField(
                  controller: _passwordController,
                  label: 'New Password (optional)',
                  hint: 'Enter new password',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed:
                        () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Confirm Password
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Re-enter new password',
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed:
                        () => setState(
                          () =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                        ),
                  ),
                  validator: (value) {
                    if (_passwordController.text.isNotEmpty &&
                        value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Update Button
                CustomButton(
                  text: 'Update',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _updateProfile,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
