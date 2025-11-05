import 'dart:io';
import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/data/repos/trainer_repo.dart';
import 'package:eatmehv2/data/services/trainer_service.dart';
import 'package:eatmehv2/presentation/screens/user/home_screen.dart';
import 'package:eatmehv2/presentation/widgets/custom_button.dart';
import 'package:eatmehv2/presentation/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';

class TrainerForm extends StatefulWidget {
  const TrainerForm({super.key});

  @override
  State<TrainerForm> createState() => _TrainerFormState();
}

class _TrainerFormState extends State<TrainerForm> {
  final _formKey = GlobalKey<FormBuilderState>();

  final TrainerRepository _trainerRepo = TrainerRepository(TrainerService());
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _contactController = TextEditingController();

  File? _certPath;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _specializationController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Trainer Form'),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    controller: _nameController,
                    label: 'Name',
                    hint: 'Enter your full name',
                    prefixIcon: Icons.person_outline,
                    validator:
                        (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _ageController,
                    label: 'Age',
                    hint: 'Enter your age',
                    prefixIcon: Icons.cake_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      final age = int.tryParse(value);
                      if (age == null || age <= 0) return 'Enter a valid age';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _specializationController,
                    label: 'Specialization',
                    hint: 'e.g. Fitness, Nutrition, etc.',
                    prefixIcon: Icons.work_outline,
                    validator:
                        (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _experienceController,
                    label: 'Years of Experience',
                    hint: 'Enter your experience in years',
                    prefixIcon: Icons.history_edu_outlined,
                    validator:
                        (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                  ),

                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _contactController,
                    label: 'Contact Number',
                    hint: 'e.g. 0123456789',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator:
                        (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Prove',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (pickedFile != null) {
                            setState(() {
                              _certPath = File(pickedFile.path);
                            });
                          } else {}
                        },
                        child: Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              _certPath == null
                                  ? const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.upload_rounded,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Tap to upload certificate',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  )
                                  : ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(_certPath!.path),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  CustomButton(
                    text: "Submit",
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting ? null : submitTrainerApplication,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> submitTrainerApplication() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the form properly.')),
      );
      return;
    }

    if (_certPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your certificate.')),
      );
      return;
    }

    final name = _nameController.text;
    final age = _ageController.text;
    final specialization = _specializationController.text;
    final experience = _experienceController.text;
    final contact = _contactController.text;

    try {
      setState(() => _isSubmitting = true);
      final authState = context.read<AuthBloc>().state;
      if (authState is! Authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to apply.')),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      final userUid = authState.user.uid;

      await _trainerRepo.applyAsTrainer(
        userId: userUid,
        name: name,
        age: age,
        specialization: specialization,
        experience: experience,
        contactNumber: contact,
        certificateFile: _certPath!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
