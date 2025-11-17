import 'dart:async';

import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/core/constants/route_constants.dart';
import 'package:eatmehv2/presentation/screens/user/simple_user_manual_screen.dart';
import 'package:eatmehv2/presentation/widgets/custom_card.dart';
import 'package:eatmehv2/presentation/widgets/toast.dart';
import 'package:eatmehv2/utils/language_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eatmehv2/core/localization/app_localizations.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _isDarkTheme = false;
  bool _notificationsEnabled = true;

  Future<void> _signOut(BuildContext context) async {
    final loc = context.loc;
    try {
      context.read<AuthBloc>().add(AuthLogoutRequested());
      await FirebaseAuth.instance.signOut();

      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(RouteConstants.login, (route) => false);
      }
    } catch (e) {
      final errorMsg = loc.settingsLogoutError(e.toString());
      showCustomToast(context, errorMsg, type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, languageState) {
        final currentLanguage = languageState.locale.languageCode;
        final loc = context.loc;

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            leadingWidth: 60,
            title: Text(loc.settingsTitle),
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // THEME SECTION
                  Row(
                    children: [
                      const Icon(Icons.light_mode, size: 23),
                      const SizedBox(width: 6),
                      Text(
                        loc.settingsSectionTheme,
                        style: const TextStyle(
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
                                  loc.settingsThemeLight,
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
                                  loc.settingsThemeDark,
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
                    children: [
                      const Icon(Icons.notifications, size: 23),
                      const SizedBox(width: 6),
                      Text(
                        loc.settingsSectionNotifications,
                        style: const TextStyle(
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
                        Text(
                          loc.settingsNotificationsEnable,
                          style: const TextStyle(fontSize: 16),
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
                    children: [
                      const Icon(Icons.language_sharp, size: 23),
                      const SizedBox(width: 6),
                      Text(
                        loc.settingsSectionLanguage,
                        style: const TextStyle(
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
                        Text(
                          loc.settingsLanguageSelect,
                          style: const TextStyle(fontSize: 16),
                        ),
                        Transform.scale(
                          scale: 0.9,
                          child: DropdownButton<String>(
                            value: currentLanguage,
                            underline: const SizedBox(),
                            isDense: true,
                            items: [
                              DropdownMenuItem(
                                value: "en",
                                child: Text(loc.settingsLanguageEnglish),
                              ),
                              DropdownMenuItem(
                                value: "zh",
                                child: Text(loc.settingsLanguageChinese),
                              ),
                            ],
                            onChanged: (value) async {
                              if (value != null && value != currentLanguage) {
                                await context
                                    .read<LanguageCubit>()
                                    .changeLanguage(value);
                                if (context.mounted) {
                                  showCustomToast(
                                    context,
                                    loc.settingsLanguageSuccess,
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
                    children: [
                      const Icon(Icons.grid_view_outlined, size: 23),
                      const SizedBox(width: 6),
                      Text(
                        loc.settingsSectionOther,
                        style: const TextStyle(
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
                        children: [
                          const Icon(Icons.menu_book, color: Colors.indigo),
                          const SizedBox(width: 12),
                          Text(loc.settingsOtherUserManual,
                              style: const TextStyle(fontSize: 16)),
                          const Spacer(),
                          const Icon(
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
                        children: [
                          const Icon(Icons.exit_to_app, color: Colors.red),
                          const SizedBox(width: 12),
                          Text(loc.settingsOtherSignOut,
                              style: const TextStyle(fontSize: 16)),
                          const Spacer(),
                          const Icon(
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