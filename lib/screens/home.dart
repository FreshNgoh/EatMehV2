import 'dart:io';
import 'package:flutter/material.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  bool _showCookSection = false;
  bool _showRestaurantSection = false;
  bool _isImageConfirmed = false;

  // final _userRecordService = UserRecordService();
  // late final String _currentUserId;
  DateTime? _selectedMonth = DateTime.now();

  // @override
  // void initState() {
  //   super.initState();
  //   _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  //   _selectedMonth = DateTime.now();
  // }

  File? _selectedImage;

  final double totalCalories = 2000;
  double get remainingCalories => 1700;

  void _changeMonth(int direction) {
    setState(() {
      if (_selectedMonth == null) {
        _selectedMonth = DateTime.now();
      }
      int currentMonth = _selectedMonth!.month;
      int newMonth = currentMonth + direction;

      if (newMonth > 12) {
        _selectedMonth = DateTime(_selectedMonth!.year + 1, 1);
      } else if (newMonth < 1) {
        _selectedMonth = DateTime(_selectedMonth!.year - 1, 12);
      } else {
        _selectedMonth = DateTime(_selectedMonth!.year, newMonth);
      }
    });
  }

  Color getCalorieColor(int calories) {
    if (calories > 700) {
      return Colors.red;
    } else if (calories >= 300) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        backgroundColor: const Color(0xFF191919),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActionButtons(),
            _buildIngredientsSection(),
            _buildUploadButton(),
            if (_selectedImage != null && !_isImageConfirmed)
              _buildImagePreviewSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Expanded(
              child: ElevatedButton.icon(
                icon: Icon(
                  Icons.restaurant_menu,
                  size: 20,
                  color: _showCookSection ? Colors.white : Colors.black,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _showCookSection ? Color(0xFF191919) : Color(0xFFF6F6F6),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.shade400, width: 1),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _showCookSection = true;
                    _showRestaurantSection = false;
                  });
                },
                label: Text(
                  'Cook',
                  style: TextStyle(
                    color: _showCookSection ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(
                Icons.storefront,
                size: 20,
                color: _showRestaurantSection ? Colors.white : Colors.black,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _showRestaurantSection
                        ? Color(0xFF191919)
                        : Color(0xFFF6F6F6),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.shade400, width: 1),
                ),
              ),
              onPressed: () {
                setState(() {
                  _showCookSection = false;
                  _showRestaurantSection = true;
                });
              },
              label: Text(
                'Restaurant',
                style: TextStyle(
                  color: _showRestaurantSection ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              'Let Gemini AI to decide your recipe today',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return Column(
      children: [
        SizedBox(
          width: 250,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.upload_rounded, size: 20),
            style: OutlinedButton.styleFrom(
              backgroundColor: Color(0xFFF6F6F6),
              foregroundColor: Color(0xFF191919),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.black.withAlpha(50)),
            ),
            onPressed: () {
              // _pickImageFromGallery();
            },
            label: const Text(
              'Upload Image',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreviewSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              height: 150, // Increased height
              width: double.infinity, // Full width
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[200],
                image: DecorationImage(
                  image: FileImage(_selectedImage!),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(color: Colors.white, width: 2),
              ),
              clipBehavior: Clip.antiAlias,
            ),
            // Improved close button
            Container(
              margin: const EdgeInsets.all(8),
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                    _isImageConfirmed = true;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF191919),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
          onPressed: () {
            // if (_selectedImage != null) {
            //   context.read<ChatBlocBloc>().add(
            //     ChatGenerateNewRecipeEvent(inputImage: _selectedImage!),
            //   );
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder:
            //           (context) =>
            //               RecipeSuggestionScreen(imageFile: _selectedImage!),
            //     ),
            //   );
            // }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Procced with Gemini AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Future _pickImageFromGallery() async {
  //   try {
  //     final returnedImage = await ImagePicker().pickImage(
  //       source: ImageSource.gallery,
  //     );

  //     if (returnedImage != null) {
  //       setState(() {
  //         _selectedImage = File(returnedImage.path);
  //       });
  //     }
  //   } catch (e) {
  //     ('Image picker error: $e');
  //   }
  // }
}
