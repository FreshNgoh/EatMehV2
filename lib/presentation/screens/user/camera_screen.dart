import 'dart:io';
import 'dart:convert';
import 'package:eatmehv2/data/models/chat_message_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eatmehv2/bloc/chat/chat_bloc_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: Stack(
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
                      child: const Icon(Icons.close, color: Colors.white),
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
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child:
                  _isAnalyzing
                      ? const Center(child: CircularProgressIndicator())
                      : _analysisResult != null
                      ? SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildAnalysisResult(),
                      )
                      : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResult() {
    final result = _analysisResult!;
    final calories = int.tryParse(result['calories'].toString()) ?? 0;
    final recommendation =
        result['recommendation'] ?? 'No recommendation found';

    final calorieColor =
        calories > 700
            ? Colors.red
            : calories >= 300
            ? Colors.green
            : Colors.orange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_fire_department, color: calorieColor, size: 40),
            const SizedBox(width: 12),
            Text(
              '$calories kcal',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: calorieColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Recommendation:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          recommendation,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
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
