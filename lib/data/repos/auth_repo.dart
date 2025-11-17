import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/data/models/user/user_settings_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user/user_model.dart';
import 'user_repo.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepo = UserRepository();

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> getUserModel(String uid) async {
    return await _userRepo.getUser(uid);
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        uid: cred.user!.uid,
        email: email,
        username: username,
        friends: [],
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        settings: UserSettings(),
      );

      await _userRepo.createUser(user);
      return user;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered. Please login instead.';
          break;
        case 'invalid-email':
          message = 'The email address format is invalid.';
          break;
        case 'weak-password':
          message = 'Your password is too weak. Please choose a stronger one.';
          break;
        default:
          message = 'Registration failed. Please try again.';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = await _userRepo.getUser(cred.user!.uid);
      return user;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with that email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          message = 'Invalid email format.';
          break;
        default:
          message = 'Login failed. Please try again.';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
