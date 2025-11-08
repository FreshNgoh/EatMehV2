import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/bloc/chat/chat_bloc_bloc.dart';
import 'package:eatmehv2/core/localization/app_localizations.dart';
import 'package:eatmehv2/core/theme/app_theme.dart';
import 'package:eatmehv2/data/repos/auth_repo.dart';
import 'package:eatmehv2/data/repos/chat_repo.dart';
import 'package:eatmehv2/data/repos/exercise_repo.dart';
import 'package:eatmehv2/data/repos/meal_records_repo.dart';
import 'package:eatmehv2/data/repos/user_repo.dart';
import 'package:eatmehv2/presentation/screens/auth/login_screen.dart';
import 'package:eatmehv2/routes/app_router.dart';
import 'package:eatmehv2/utils/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  // Initialize Flutter bindings and Firebase
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Get data from the cache
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");
  await FirebaseAuth.instance.signOut();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => UserRepository()),
        RepositoryProvider(create: (_) => ChatRepository()),
        RepositoryProvider(create: (_) => MealRecordsRepository()),
        RepositoryProvider(create: (_) => ExerciseRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (context) =>
                    AuthBloc(authRepository: context.read<AuthRepository>())
                      ..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create:
                (context) => ChatBlocBloc(
                  chatRepository: context.read<ChatRepository>(),
                ),
          ),
        ],

        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Eat Meh',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English
            Locale('zh', ''), // Chinese
          ],
          locale: const Locale('en'),
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is Authenticated) {
                return AppRouter.getHomeScreen(authState.user.role);
              }

              return const LoginScreen();
            },
          ),
        ),
      ),
    );
  }
}
