// import 'dart:developer';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:eatmehv2/widgets/bar.dart';
// import 'package:eatmehv2/data/models/user_model.dart';
// import "package:eatmehv2/services/user_service.dart";
// import 'package:eatmehv2/core/localization/app_localizations.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final UserService _userService = UserService();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   bool _isLoading = false;
//   // final Random _random = Random();
//   bool _isLogin = true;
//   bool _obscurePassword = true;
//   // final GlobalKey _avatarKey = GlobalKey(); // Key for RepaintBoundary
//   // NotionAvatarController? _avatarController; // To access the controller

//   void _toggleTab(bool isLoginTab) {
//     setState(() {
//       _isLogin = isLoginTab;
//       _emailController.clear();
//       _passwordController.clear();
//       _usernameController.clear();
//     });
//   }

//   Future<void> _submit() async {
//     final email = _emailController.text.trim();
//     final password = _passwordController.text.trim();
//     final username = _usernameController.text.trim();

//     if (email.isEmpty || password.isEmpty || (!_isLogin && username.isEmpty)) {
//       _showError("Please fill in all fields.");
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       if (_isLogin) {
//         await _auth.signInWithEmailAndPassword(
//           email: email,
//           password: password,
//         );
//         if (!mounted) return;

//         if (_auth.currentUser != null) {
//           log("User is logged in: ${_auth.currentUser?.email}");
//           // Navigate to the home page
//           if (!mounted) return;
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const Bar()),
//           );
//         }
//       } else {
//         UserCredential userCredential = await _auth
//             .createUserWithEmailAndPassword(email: email, password: password);

//         final User? user = userCredential.user;
//         if (user != null) {
//           final String uid = user.uid;
//           await user.updateDisplayName(username);

//           try {
//             UserModel newUser = UserModel(
//               uid: uid,
//               username: username,
//               email: email,
//               // imageUrl: avatarUrl,
//               imageUrl: "",
//               userRecordId: "",
//               friends: [],
//               // avatarOptions: avatarIndices,
//             );
//             await _userService.addUser(newUser);
//             if (!mounted) return;
//             _showSuccess("Registration successful!");
//             // Do NOT redirect to Bar() here
//             if (mounted) {
//               setState(() {
//                 _isLogin = true; // Switch to the login tab
//               });
//             }
//           } catch (e) {
//             log("Error creating user in Firestore: $e");
//             _showError("Error creating user profile.");
//             // await user.delete();
//           }
//         } else {
//           if (mounted) {
//             setState(() {
//               _isLoading = false;
//             });
//           }
//         }
//       }
//     } on FirebaseAuthException catch (e) {
//       if (!mounted) return;
//       _handleAuthError(e);
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;
//       _showError("Something went wrong. Please try again.");
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } finally {
//       if (_isLogin && mounted && _isLoading) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _showSuccess(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(message)));
//   }

//   void _handleAuthError(FirebaseAuthException e) {
//     String errorMessage;
//     switch (e.code) {
//       case 'invalid-email':
//         errorMessage = 'Invalid email format.';
//         break;
//       case 'user-not-found':
//         errorMessage = 'User not found.';
//         break;
//       case 'wrong-password':
//         errorMessage = 'Incorrect password.';
//         break;
//       case 'email-already-in-use':
//         errorMessage = 'Email already registered.';
//         break;
//       case 'weak-password':
//         errorMessage = 'Password must be at least 6 characters.';
//         break;
//       default:
//         errorMessage = 'Authentication failed. [${e.code}]';
//     }
//     _showError(errorMessage);
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(message)));
//   }

//   Widget _buildLoginForm() {
//     return Column(
//       children: [
//         TextField(
//           controller: _emailController,
//           decoration: InputDecoration(labelText: context.loc.email),
//           keyboardType: TextInputType.emailAddress,
//         ),
//         const SizedBox(height: 10),
//         TextField(
//           controller: _passwordController,
//           obscureText: _obscurePassword,
//           decoration: InputDecoration(
//             labelText: context.loc.password,
//             suffixIcon: IconButton(
//               icon: Icon(
//                 _obscurePassword ? Icons.visibility_off : Icons.visibility,
//               ),
//               onPressed: () {
//                 setState(() {
//                   _obscurePassword = !_obscurePassword;
//                 });
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildRegisterForm() {
//     return Stack(
//       children: [
//         Column(
//           mainAxisSize:
//               MainAxisSize.min, // Ensure Column only takes necessary height
//           children: [
//             TextField(
//               controller: _usernameController,
//               decoration: InputDecoration(labelText: context.loc.username),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _emailController,
//               decoration: InputDecoration(labelText: context.loc.email),
//               keyboardType: TextInputType.emailAddress,
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _passwordController,
//               obscureText: _obscurePassword,
//               decoration: InputDecoration(
//                 labelText: context.loc.password,
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     _obscurePassword ? Icons.visibility_off : Icons.visibility,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       _obscurePassword = !_obscurePassword;
//                     });
//                   },
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             // No visible placeholder for the avatar anymore
//           ],
//         ),
//         RepaintBoundary(child: SizedBox(width: 100, height: 100)),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // 🖼️ App logo
//                 Image.asset(
//                   'assets/logo/logo.png', // Replace with your actual image path
//                   height: 150,
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   "Eat Meh",
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 30),

//                 // 🔁 Login/Register Toggle
//                 ToggleButtons(
//                   borderRadius: BorderRadius.circular(10),
//                   isSelected: [_isLogin, !_isLogin],
//                   onPressed: (index) => _toggleTab(index == 0),
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 20),
//                       child: Text(context.loc.login),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 20),
//                       child: Text(context.loc.register),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 30),

//                 // 👇 Dynamic Form
//                 _isLogin ? _buildLoginForm() : _buildRegisterForm(),

//                 const SizedBox(height: 20),

//                 // ✅ Submit Button
//                 _isLoading
//                     ? const CircularProgressIndicator()
//                     : ElevatedButton(
//                       onPressed: _submit,
//                       child: Text(
//                         _isLogin ? context.loc.login : context.loc.register,
//                       ),
//                     ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Page'), centerTitle: true),
      body: const Center(
        child: Text(
          'This is a simple Flutter page!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
