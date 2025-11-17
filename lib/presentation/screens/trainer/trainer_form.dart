import 'dart:io';
import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/data/repos/trainer_application_repo.dart';
import 'package:eatmehv2/data/services/trainer_application_service.dart';
import 'package:eatmehv2/presentation/widgets/custom_button.dart';
import 'package:eatmehv2/presentation/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eatmehv2/core/localization/app_localizations.dart';

class TrainerForm extends StatefulWidget {
  const TrainerForm({super.key});

  @override
  State<TrainerForm> createState() => _TrainerFormState();
}

class _TrainerFormState extends State<TrainerForm> {
  final _formKey = GlobalKey<FormBuilderState>();

  final trainerRepo = TrainerApplicationRepository(TrainerApplicationService());
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
    final loc = context.loc; 

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(loc.trainerFormTitle),
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
                    label: loc.trainerFormNameLabel,
                    hint: loc.trainerFormNameHint,
                    prefixIcon: Icons.person_outline,
                    validator: (value) =>
                        value == null || value.isEmpty
                            ? loc.trainerFormErrorRequired
                            : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _ageController,
                    label: loc.trainerFormAgeLabel,
                    hint: loc.trainerFormAgeHint,
                    prefixIcon: Icons.cake_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return loc.trainerFormErrorRequired;
                      }
                      final age = int.tryParse(value);
                      if (age == null || age <= 0) {
                        return loc.trainerFormErrorAgeInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _specializationController,
                    label: loc.trainerFormSpecLabel,
                    hint: loc.trainerFormSpecHint,
                    prefixIcon: Icons.work_outline,
                    validator: (value) =>
                        value == null || value.isEmpty
                            ? loc.trainerFormErrorRequired
                            : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _experienceController,
                    label: loc.trainerFormExpLabel,
                    hint: loc.trainerFormExpHint,
                    prefixIcon: Icons.history_edu_outlined,
                    validator: (value) =>
                        value == null || value.isEmpty
                            ? loc.trainerFormErrorRequired
                            : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _contactController,
                    label: loc.trainerFormContactLabel,
                    hint: loc.trainerFormContactHint,
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value == null || value.isEmpty
                            ? loc.trainerFormErrorRequired
                            : null,
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.trainerFormProveLabel,
                        style: const TextStyle(
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
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.upload_rounded,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            loc.trainerFormUploadHint,
                                            style:
                                                const TextStyle(color: Colors.grey),
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
                    text: loc.trainerFormButtonSubmit,
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
    final loc = context.loc;    
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.trainerFormErrorComplete)),
      );
      return;
    }

    if (_certPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.trainerFormErrorUpload)),
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
          SnackBar(content: Text(loc.trainerFormErrorNotLoggedIn)),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      final userUid = authState.user.uid;

      await trainerRepo.applyAsTrainer(
        userId: userUid,
        name: name,
        age: age,
        specialization: specialization,
        experience: experience,
        contactNumber: contact,
        certificateFile: _certPath!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.trainerFormSuccess)),
      );

      // have bug here
      Navigator.pop(context, 'submitted');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.trainerFormErrorPrefix + e.toString())));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}