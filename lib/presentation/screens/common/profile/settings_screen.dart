import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/settings/settings_bloc.dart';
import '../../../blocs/theme/theme_bloc.dart';
import 'user_manual_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is! SettingsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Appearance Section
              _buildSectionHeader('Appearance'),
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, themeState) {
                  final isDarkMode =
                      themeState is ThemeLoaded && themeState.isDarkMode;
                  return _buildSettingTile(
                    icon: Icons.dark_mode,
                    title: 'Dark Mode',
                    subtitle: 'Switch to dark theme',
                    trailing: Switch(
                      value: isDarkMode,
                      onChanged: (value) {
                        context.read<ThemeBloc>().add(ThemeToggled());
                        context
                            .read<SettingsBloc>()
                            .add(SettingsDarkModeToggled());
                      },
                    ),
                  );
                },
              ),

              // Language Section
              _buildSectionHeader('Language'),
              _buildLanguageTile(context, state.settings.language),

              // Notifications Section
              _buildSectionHeader('Notifications'),
              _buildSettingTile(
                icon: Icons.notifications,
                title: 'Push Notifications',
                subtitle: 'Receive updates and reminders',
                trailing: Switch(
                  value: state.settings.notifications,
                  onChanged: (value) {
                    context
                        .read<SettingsBloc>()
                        .add(SettingsNotificationsToggled());
                  },
                ),
              ),

              // Help & Support Section
              _buildSectionHeader('Help & Support'),
              _buildSettingTile(
                icon: Icons.help_outline,
                title: 'User Manual',
                subtitle: 'Learn how to use the app',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserManualScreen()),
                  );
                },
              ),
              _buildSettingTile(
                icon: Icons.contact_support,
                title: 'Contact Support',
                subtitle: 'Get help from our team',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening support chat...')),
                  );
                },
              ),

              // About Section
              _buildSectionHeader('About'),
              _buildSettingTile(
                icon: Icons.info_outline,
                title: 'About EatMeh',
                subtitle: 'Version 2.0.0',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showAboutDialog(context),
              ),
              _buildSettingTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening privacy policy...')),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF191919).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF191919)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle != null
            ? Text(subtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600))
            : null,
        trailing: trailing,
        onTap: onTap,
        tileColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, String currentLanguage) {
    final languages = {'en': 'English', 'zh': '中文 (Chinese)'};

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF191919).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.language, color: Color(0xFF191919)),
        ),
        title: const Text('Language',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        subtitle: Text(
          languages[currentLanguage] ?? 'English',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        tileColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Select Language'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: languages.entries.map((entry) {
                  return RadioListTile<String>(
                    title: Text(entry.value),
                    value: entry.key,
                    groupValue: currentLanguage,
                    onChanged: (value) {
                      if (value != null) {
                        context
                            .read<SettingsBloc>()
                            .add(SettingsLanguageChanged(value));
                        Navigator.pop(context);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'EatMeh',
      applicationVersion: '2.0.0',
      applicationIcon: Image.asset('assets/logo.png', width: 60, height: 60),
      children: [
        const Text(
          'EatMeh is a social health tracking app that helps you monitor your nutrition, '
          'connect with friends, and achieve your health goals with AI-powered meal analysis.',
        ),
      ],
    );
  }
}
