import 'package:eatmehv2/presentation/screens/auth/login_screen.dart';
import 'package:eatmehv2/presentation/widgets/custom_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _isDarkTheme = false;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out user
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                children: [
                  Icon(Icons.light_mode, size: 23),
                  SizedBox(width: 6),
                  Text(
                    'Theme',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
                        print("clicked light theme");
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
                                    !_isDarkTheme ? Colors.black : Colors.grey,
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
                        print("clicked dark theme");
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
                                    _isDarkTheme ? Colors.black : Colors.grey,
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
                  Icon(Icons.notifications, size: 23),
                  SizedBox(width: 6),
                  Text(
                    'Notifications',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
                        padding: EdgeInsets.symmetric(vertical: -8),
                        value: _notificationsEnabled,
                        activeColor: Colors.blueAccent,
                        onChanged: (value) {
                          setState(() => _notificationsEnabled = value);
                          print("clicked notification toggle");
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
                  Icon(Icons.language_sharp, size: 23),
                  SizedBox(width: 6),
                  Text(
                    'Language',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
                      scale: 0.9, // make it slightly smaller visually
                      child: DropdownButton<String>(
                        value: _selectedLanguage,
                        underline: const SizedBox(),
                        isDense: true,
                        items: const [
                          DropdownMenuItem(
                            value: "English",
                            child: Text("English"),
                          ),
                          DropdownMenuItem(
                            value: "Chinese",
                            child: Text("Chinese"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedLanguage = value!);
                          print("clicked language selection");
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
                  Icon(Icons.grid_view_outlined, size: 23),
                  SizedBox(width: 6),
                  Text(
                    'Other',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  print("clicked user manual");
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
  }
}
