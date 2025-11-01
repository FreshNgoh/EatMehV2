import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../../core/localization/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          _emailController.text,
          _passwordController.text,
          _usernameController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //localization
    final loc = context.loc;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.createAccount),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is Authenticated) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: Image.asset('assets/logo/logo.png', height: 100),
                  ),
                  const SizedBox(height: 30),

                  // Username Field
                  CustomTextField(
                    controller: _usernameController,
                    label: loc.usernameLabel,
                    hint: loc.usernameHint,
                    prefixIcon: Icons.person_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return loc.usernameErrorEmpty;
                      }
                      if (value.length < 3) {
                        return loc.usernameErrorShort;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    label: loc.emailLabel,
                    hint: loc.emailHint,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return loc.emailErrorEmpty;
                      }
                      if (!value.contains('@')) {
                        return loc.emailErrorInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  CustomTextField(
                    controller: _passwordController,
                    label: loc.passwordLabel,
                    hint: loc.passwordHint,
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outlined,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return loc.passwordErrorEmpty;
                      }
                      if (value.length < 6) {
                        return loc.passwordErrorShort;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password Field
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: loc.confirmPasswordLabel,
                    hint: loc.confirmPasswordHint,
                    obscureText: _obscureConfirmPassword,
                    prefixIcon: Icons.lock_outlined,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return loc.confirmPasswordErrorEmpty;
                      }
                      if (value != _passwordController.text) {
                        return loc.confirmPasswordErrorMismatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Register Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;

                      return CustomButton(
                        text: loc.createAccount,
                        onPressed: isLoading ? null : _register,
                        isLoading: isLoading,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
