import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/core/constants/route_constants.dart';
import 'package:eatmehv2/presentation/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            RouteConstants.home,
            (route) => false,
            arguments: state.user,
          );
        }
      },
      child: const LoginScreen(), // initial login screen
    );
  }
}
