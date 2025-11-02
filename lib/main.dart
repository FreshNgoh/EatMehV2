import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
// import 'package:eatmehv2/bloc/chat/chat_bloc_bloc.dart';
import 'package:eatmehv2/core/localization/app_localizations.dart';
import 'package:eatmehv2/core/theme/app_theme.dart';
import 'package:eatmehv2/data/repos/auth_repo.dart';
import 'package:eatmehv2/data/repos/user_repo.dart';
import 'package:eatmehv2/presentation/screens/auth/login_screen.dart';
import 'package:eatmehv2/presentation/screens/friend_page.dart';
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
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (context) =>
                    AuthBloc(authRepository: context.read<AuthRepository>())
                      ..add(AuthCheckRequested()),
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
          locale: const Locale('zh'),
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

// AuthWrapper listens to authentication state changes
// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         // If the connection state is waiting, show a loading indicator
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         // If the user is signed in, show the authenticated page (NutritionScreen with Bar)
//         if (snapshot.hasData) {
//           return const Bar(); // Assuming Bar includes Navigation to NutritionScreen
//         }

//         // If the user is not signed in, show the LoginPage
//         return const LoginPage(); // Show the login page
//       },
//     );
//   }
// }
