import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Language State
class LanguageState {
  final Locale locale;

  LanguageState(this.locale);
}

// Language Cubit
class LanguageCubit extends Cubit<LanguageState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  LanguageCubit() : super(LanguageState(const Locale('en', ''))) {
    _loadLanguageFromFirebase();
  }

  Future<void> _loadLanguageFromFirebase() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null && data['settings'] != null) {
        final language = data['settings']['language'] ?? 'en';
        emit(LanguageState(Locale(language, '')));
      }
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'settings.language': languageCode,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      emit(LanguageState(Locale(languageCode, '')));
    }
  }

  String get currentLanguageCode => state.locale.languageCode;
}
