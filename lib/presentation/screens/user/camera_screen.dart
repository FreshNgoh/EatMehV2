import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/bloc/chat/chat_bloc_bloc.dart';
import 'package:eatmehv2/core/constants/firebase_constants.dart';
import 'package:eatmehv2/core/theme/app_colors.dart';
import 'package:eatmehv2/data/models/chat/chat_message_model.dart';
import 'package:eatmehv2/data/models/meal/meal_record_model.dart';
import 'package:eatmehv2/data/models/meal/nutrition_info_model.dart';
import 'package:eatmehv2/data/repos/meal_records_repo.dart';
import 'package:eatmehv2/presentation/widgets/custom_button.dart';
import 'package:eatmehv2/utils/firebase_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/localization/app_localizations.dart';
import 'package:eatmehv2/data/models/story/story_model.dart';
import 'package:eatmehv2/data/repos/story_repo.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _selectedImage;
  bool _isAnalyzing = false;
  bool _isSaving = false;
  bool _isPosting = false;
  Map<String, dynamic>? _analysisResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedImage == null) {
        _showImageSourceDialog();
      }
    });
  }

  Future<void> _saveMealRecord({
    required String foodName,
    required int calories,
    required num protein,
    required num carbs,
    required num fat,
    required num fiber,
    required String recommendation,
  }) async {
    setState(() => _isSaving = true); // 🟡 start loading
    final loc = context.loc;

    final authState = context.read<AuthBloc>().state as Authenticated;
    final userUid = authState.user.uid;
    final mealRepo = MealRecordsRepository();

    final file = File(_selectedImage!.path);

    try {
      // 1. Upload image
      final storageService = FirebaseStorageService();
      final downloadUrl = await storageService.uploadMealImage(
        file: file,
        userUid: userUid,
        folderName: FirebaseConstants.mealRecordFolder,
      );

      // 2. Save Firestore record
      final meal = MealRecordModel(
        uid:
            FirebaseFirestore.instance
                .collection(FirebaseConstants.mealRecordFolder)
                .doc()
                .id,
        userUid: userUid,
        imageUrl: downloadUrl,
        calories: calories,
        foodName: foodName,
        nutritionInfo: NutritionInfo(
          protein: protein.toDouble(),
          carbs: carbs.toDouble(),
          fat: fat.toDouble(),
          fiber: fiber.toDouble(),
        ),
        recommendation: recommendation,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await mealRepo.saveMealRecord(meal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          // --- 3. USE LOCALIZED STRING ---
          SnackBar(content: Text(loc.cameraMealSaveSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // --- 4. USE LOCALIZED STRING WITH PARAMETER ---
            content: Text(
              loc.cameraMealSaveError.replaceFirst('{error}', e.toString()),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false); // 🔵 stop loading
    }
  }

  Future<void> _postStory() async {
    if (_selectedImage == null || _analysisResult == null) return;

    setState(() => _isPosting = true);
    final loc = context.loc;

    final authState = context.read<AuthBloc>().state as Authenticated;
    final user = authState.user;
    final file = File(_selectedImage!.path);

    try {
      // 🟢 1. Upload image to SAME mealRecord folder (not separate)
      final storageService = FirebaseStorageService();
      final downloadUrl = await storageService.uploadMealImage(
        file: file,
        userUid: user.uid,
        folderName: FirebaseConstants.mealRecordFolder,
      );

      // 🟢 2. Extract analysis result
      final result = _analysisResult!;
      final foodName = result['foodName'] ?? loc.cameraUnknownMeal;
      final calories = int.tryParse(result['calories'].toString()) ?? 0;
      final protein = result['protein'] ?? 0;
      final carbs = result['carbs'] ?? 0;
      final fat = result['fat'] ?? 0;
      final fiber = result['fiber'] ?? 0;
      final recommendation =
          result['recommendation'] ?? loc.cameraNoRecommendation;

      final now = Timestamp.now();
      final expiresAt = Timestamp.fromDate(
        now.toDate().add(const Duration(hours: 24)),
      );

      // 🟢 3. Create story
      final story = StoryModel(
        uid: FirebaseFirestore.instance.collection('stories').doc().id,
        userId: user.uid,
        username: user.username,
        userImageUrl: user.imageUrl ?? '',
        mediaUrl: downloadUrl,
        createdAt: now,
        expiresAt: expiresAt,
        views: [],
        viewCount: 0,
        comments: [],
      );

      // 🟢 4. Create meal record (same image)
      final meal = MealRecordModel(
        uid:
            FirebaseFirestore.instance
                .collection(FirebaseConstants.mealRecordFolder)
                .doc()
                .id,
        userUid: user.uid,
        imageUrl: downloadUrl,
        calories: calories,
        foodName: foodName,
        nutritionInfo: NutritionInfo(
          protein: protein.toDouble(),
          carbs: carbs.toDouble(),
          fat: fat.toDouble(),
          fiber: fiber.toDouble(),
        ),
        recommendation: recommendation,
        createdAt: now,
        updatedAt: now,
      );

      // 🟢 5. Save both to Firestore
      final storyRepo = StoryRepository();
      final mealRepo = MealRecordsRepository();

      await Future.wait([
        storyRepo.createStory(story),
        mealRepo.saveMealRecord(meal),
      ]);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.cameraStoryAdded)));
        setState(() {
          _selectedImage = null;
          _analysisResult = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to post story: $e')));
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Future<void> _showImageSourceDialog() async {
    // --- 5. GET LOCALIZATION ---
    final loc = context.loc;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF6F6F6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  // --- 6. USE LOCALIZED STRING ---
                  loc.cameraSourceTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.camera_alt, size: 30),
                  // --- 7. USE LOCALIZED STRING ---
                  title: Text(loc.cameraSourceCamera),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, size: 30),
                  // --- 8. USE LOCALIZED STRING ---
                  title: Text(loc.cameraSourceGallery),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _analysisResult = null;
      });

      // Trigger Gemini analysis
      _analyzeWithGemini(_selectedImage!);
    }
  }

  Future<void> _analyzeWithGemini(File imageFile) async {
    setState(() => _isAnalyzing = true);

    // Dispatch Gemini analysis event
    context.read<ChatBlocBloc>().add(
      AnalyzeMealImageEvent(inputImage: imageFile),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- 9. GET LOCALIZATION ---
    final loc = context.loc;

    if (_selectedImage == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 100, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            Text(
              // --- 10. USE LOCALIZED STRING ---
              loc.cameraNoImage,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showImageSourceDialog,
              icon: const Icon(Icons.add_a_photo),
              // --- 11. USE LOCALIZED STRING ---
              label: Text(loc.cameraButton),
            ),
          ],
        ),
      );
    }

    return BlocListener<ChatBlocBloc, ChatBlocState>(
      listener: (context, state) {
        if (state is ChatLoadingState) {
          setState(() => _isAnalyzing = true);
        } else if (state is ChatSuccessState) {
          setState(() {
            _analysisResult = _extractFirstValidAnalysis(state.messages);
            _isAnalyzing = false;
          });
        } else if (state is AnalyzeMealErrorState) {
          setState(() => _isAnalyzing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                loc.cameraError.replaceFirst('{error}', state.error),
              ),
            ),
          );
        }
      },
      child:
          _selectedImage == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 100,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      loc.cameraNoImage,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _showImageSourceDialog,
                      icon: const Icon(Icons.add_a_photo),
                      label: Text(loc.cameraButton),
                    ),
                  ],
                ),
              )
              : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 350,
                    pinned: true,
                    backgroundColor: Colors.white,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          // Close button
                          Positioned(
                            top: 24,
                            left: 24,
                            child: IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedImage = null;
                                  _analysisResult = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child:
                          _isAnalyzing
                              ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : _analysisResult != null
                              ? _buildAnalysisResult()
                              : Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 40,
                                  ),
                                  child: Text(
                                    // --- 15. USE LOCALIZED STRING ---
                                    loc.cameraNoAnalysis,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildAnalysisResult() {
    final loc = context.loc;
    final result = _analysisResult!;

    final foodName = result['foodName'] ?? loc.cameraUnknownMeal;
    final calories = int.tryParse(result['calories'].toString()) ?? 0;
    final protein = result['protein'] ?? 0;
    final carbs = result['carbs'] ?? 0;
    final fat = result['fat'] ?? 0;
    final fiber = result['fiber'] ?? 0;
    final recommendation =
        result['recommendation'] ?? loc.cameraNoRecommendation;

    final calorieColor = AppColors.getCalorieColor(calories);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_fire_department, color: calorieColor, size: 32),
            const SizedBox(width: 8),
            Text(
              '$calories kcal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: calorieColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // --- Nutrition Breakdown ---
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildNutrientRow(
                AppColors.proteinIcon,
                loc.cameraNutrientProtein, // --- 19. USE LOCALIZED STRING ---
                "$protein g",
                AppColors.proteinColor,
              ),
              _buildNutrientRow(
                AppColors.carbsIcon,
                loc.cameraNutrientCarbs, // --- 20. USE LOCALIZED STRING ---
                "$carbs g",
                AppColors.carbsColor,
              ),
              _buildNutrientRow(
                AppColors.fatIcon,
                loc.cameraNutrientFat, // --- 21. USE LOCALIZED STRING ---
                "$fat g",
                AppColors.fatColor,
              ),
              _buildNutrientRow(
                AppColors.fiberIcon,
                loc.cameraNutrientFiber, // --- 22. USE LOCALIZED STRING ---
                "$fiber g",
                AppColors.fiberColor,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.blue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  recommendation.toString(),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Action Buttons
        Row(
          children: [
            // 🟩 Save Button
            Expanded(
              child: CustomButton(
                // --- 23. USE LOCALIZED STRING ---
                text: _isSaving ? loc.cameraSaving : loc.cameraSave,
                icon: _isSaving ? null : Icons.save,
                onPressed:
                    _isSaving
                        ? null // 🔒 disable while saving
                        : () {
                          _saveMealRecord(
                            foodName: foodName,
                            calories: calories,
                            protein: protein,
                            carbs: carbs,
                            fat: fat,
                            fiber: fiber,
                            recommendation: recommendation,
                          );
                        },
              ),
            ),
            const SizedBox(width: 12),

            // ⚪ Post Story Button (outlined look)
            Expanded(
              child: CustomButton(
                text: _isPosting ? "Posting" : 'Post',
                icon: Icons.add_circle,
                backgroundColor: Colors.white,
                textColor: const Color(0xFF191919),
                onPressed: _isPosting ? null : _postStory,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNutrientRow(
    IconData icon,
    String label,
    String value,
    Color customColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: customColor, size: 22),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: customColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔍 Helper to extract valid Gemini JSON response
  Map<String, dynamic>? _extractFirstValidAnalysis(
    List<ChatMessageModel> messages,
  ) {
    for (final message in messages) {
      for (final part in message.parts) {
        final text = part.text;
        if (text != null && text.toLowerCase() != 'null') {
          try {
            final decoded = jsonDecode(text);
            if (decoded is Map<String, dynamic>) {
              return decoded;
            }
          } catch (e) {
            debugPrint('Invalid JSON: $e');
          }
        }
      }
    }
    // Added explicit null return
    return null;
  }
}
