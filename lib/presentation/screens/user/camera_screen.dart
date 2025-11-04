import 'dart:io';
import 'dart:convert';
import 'package:eatmehv2/core/theme/app_colors.dart';
import 'package:eatmehv2/data/models/chat_message_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eatmehv2/bloc/chat/chat_bloc_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eatmehv2/presentation/widgets/custom_button.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _selectedImage;
  bool _isAnalyzing = false;
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

  Future<void> _showImageSourceDialog() async {
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
                const Text(
                  'Choose Image Source',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.camera_alt, size: 30),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, size: 30),
                  title: const Text('Choose from Gallery'),
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
    if (_selectedImage == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 100, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            const Text(
              'No image selected',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showImageSourceDialog,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Take Photo'),
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
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
                    const Text(
                      'No image selected',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _showImageSourceDialog,
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text('Take Photo'),
                    ),
                  ],
                ),
              )
              : CustomScrollView(
                slivers: [
                  // ======= Collapsible image header =======
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

                  // ======= Scrollable Content Section =======
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
                              : const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40),
                                  child: Text(
                                    'No analysis result yet.',
                                    style: TextStyle(color: Colors.grey),
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
    final result = _analysisResult!;

    final foodName = result['foodName'] ?? 'Unknown Meal';
    final calories = int.tryParse(result['calories'].toString()) ?? 0;
    final protein = result['protein'] ?? 0;
    final carbs = result['carbs'] ?? 0;
    final fat = result['fat'] ?? 0;
    final fiber = result['fiber'] ?? 0;
    final recommendation =
        result['recommendation'] ?? 'No recommendation available';

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
                Icons.egg_alt_outlined,
                "Protein",
                "$protein g",
                AppColors.protein,
              ),
              _buildNutrientRow(
                Icons.grain,
                "Carbs",
                "$carbs g",
                AppColors.carbs,
              ),
              _buildNutrientRow(
                Icons.water_drop_sharp,
                "Fat",
                "$fat g",
                AppColors.fat,
              ),
              _buildNutrientRow(
                Icons.eco,
                "Fiber",
                "$fiber g",
                AppColors.fiber,
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
                text: 'Save',
                icon: Icons.save,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Meal saved to records!')),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            // ⚪ Post Story Button (outlined look)
            Expanded(
              child: CustomButton(
                text: 'Post Story',
                icon: Icons.add_circle,
                backgroundColor: Colors.white,
                textColor: const Color(0xFF191919),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '{ foodName: $foodName ,kcal: $calories, protein: $protein, carbs: $carbs, fat: $fat, fiber: $fiber}',
                      ),
                    ),
                  );
                },
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
          debugPrint('Gemini raw response: $text'); // 👈 Add this line
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
  }
}
