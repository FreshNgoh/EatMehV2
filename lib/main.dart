import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app.dart';
import 'core/localization/app_localizations.dart';
import 'data/services/local/shared_prefs_service.dart';
import 'data/services/local/notification_service.dart';
import '../lib_claude/utils/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize SharedPreferences
  await SharedPrefsService.init();

  // Initialize Notifications
  await NotificationService.init();

  runApp(const EatMehApp());
}
