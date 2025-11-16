import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/core/constants/route_constants.dart';
import 'package:eatmehv2/presentation/screens/user/simple_user_manual_screen.dart';
import 'package:eatmehv2/presentation/widgets/custom_card.dart';
import 'package:eatmehv2/presentation/widgets/toast.dart';
import 'package:eatmehv2/utils/language_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _isDarkTheme = false;
  bool _notificationsEnabled = true;

  Future<void> _signOut(BuildContext context) async {
    try {
      context.read<AuthBloc>().add(AuthLogoutRequested());
      await FirebaseAuth.instance.signOut();

      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(RouteConstants.login, (route) => false);
      }
    } catch (e) {
      final errorMsg = 'Logout failed: $e';
      showCustomToast(context, errorMsg, type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, languageState) {
        final currentLanguage = languageState.locale.languageCode;

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            leadingWidth: 60,
            title: const Text('Settings'),
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // THEME SECTION
                  Row(
                    children: const [
                      Icon(Icons.light_mode, size: 23),
                      SizedBox(width: 6),
                      Text(
                        'Theme',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _isDarkTheme = false);
                          },
                          child: CustomCard(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.light_mode,
                                  size: 36,
                                  color: Colors.orange,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Light",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        !_isDarkTheme
                                            ? Colors.black
                                            : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _isDarkTheme = true);
                          },
                          child: CustomCard(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.dark_mode,
                                  size: 36,
                                  color: Colors.blueGrey,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Dark",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        _isDarkTheme
                                            ? Colors.black
                                            : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // NOTIFICATIONS SECTION
                  Row(
                    children: const [
                      Icon(Icons.notifications, size: 23),
                      SizedBox(width: 6),
                      Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CustomCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Enable Notifications",
                          style: TextStyle(fontSize: 16),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            padding: const EdgeInsets.symmetric(vertical: -8),
                            value: _notificationsEnabled,
                            activeColor: Colors.blueAccent,
                            onChanged: (value) {
                              setState(() => _notificationsEnabled = value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // LANGUAGE SECTION
                  Row(
                    children: const [
                      Icon(Icons.language_sharp, size: 23),
                      SizedBox(width: 6),
                      Text(
                        'Language',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CustomCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Select Language",
                          style: TextStyle(fontSize: 16),
                        ),
                        Transform.scale(
                          scale: 0.9,
                          child: DropdownButton<String>(
                            value: currentLanguage,
                            underline: const SizedBox(),
                            isDense: true,
                            items: const [
                              DropdownMenuItem(
                                value: "en",
                                child: Text("English"),
                              ),
                              DropdownMenuItem(value: "zh", child: Text("中文")),
                            ],
                            onChanged: (value) async {
                              if (value != null && value != currentLanguage) {
                                await context
                                    .read<LanguageCubit>()
                                    .changeLanguage(value);
                                if (context.mounted) {
                                  showCustomToast(
                                    context,
                                    'Language changed successfully',
                                    type: ToastType.success,
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // OTHER SECTION
                  Row(
                    children: const [
                      Icon(Icons.grid_view_outlined, size: 23),
                      SizedBox(width: 6),
                      Text(
                        'Other',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SimpleUserManualScreen(),
                        ),
                      );
                    },
                    child: CustomCard(
                      child: Row(
                        children: const [
                          Icon(Icons.menu_book, color: Colors.indigo),
                          SizedBox(width: 12),
                          Text("User Manual", style: TextStyle(fontSize: 16)),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Sign out
                  GestureDetector(
                    onTap: () {
                      _signOut(context);
                    },
                    child: CustomCard(
                      child: Row(
                        children: const [
                          Icon(Icons.exit_to_app, color: Colors.red),
                          SizedBox(width: 12),
                          Text("Sign Out", style: TextStyle(fontSize: 16)),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
