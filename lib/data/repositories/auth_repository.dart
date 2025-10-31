import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user/user_model.dart';
import 'user_repository.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  User? get currentUser => _firebaseAuth.currentUser;

  // Get user model from Firestore
  Future<UserModel?> getUserModel(String uid) async {
    return await _userRepository.getUser(uid);
  }

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        return await _userRepository.getUser(credential.user!.uid);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(username);

        final newUser = UserModel(
          uid: credential.user!.uid,
          username: username,
          email: email,
          role: 'user',
          friends: [],
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        );

        await _userRepository.createUser(newUser);
        return newUser;
      }
      throw Exception('User creation failed');
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
