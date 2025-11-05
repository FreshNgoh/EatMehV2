import 'dart:io';
import 'package:eatmehv2/presentation/widgets/custom_button.dart';
import 'package:eatmehv2/presentation/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';

class TrainerForm extends StatefulWidget {
  const TrainerForm({super.key});

  @override
  State<TrainerForm> createState() => _TrainerFormState();
}

class _TrainerFormState extends State<TrainerForm> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _specializationController = TextEditingController();
  final _contactController = TextEditingController();

  String? _photoPath;

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
                              _photoPath = pickedFile.path;
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
                              _photoPath == null
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
                                      File(_photoPath!),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  CustomButton(
                    text: "Submit",
                    onPressed: () {},
                    backgroundColor: Colors.green.shade600,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
