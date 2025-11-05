import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads an image file to Firebase Storage under `meal_images/`
  /// and returns the download URL.
  Future<String> uploadMealImage({
    required File file,
    required String userUid,
    required String folderName,
  }) async {
    try {
      final fileName =
          '${userUid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final ref = _storage.ref().child(folderName).child(fileName);

      await ref.putFile(file);

      final downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Firebase Storage upload failed: ${e.message}');
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }
}
