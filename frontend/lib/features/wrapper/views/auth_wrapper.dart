import 'package:flutter/material.dart';
import 'package:frontend/features/splash/views/splash_screen.dart';
import 'package:frontend/features/wrapper/provider/auth_provider.dart';
import 'package:provider/provider.dart';

import 'package:frontend/features/home/views/home_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authProvider.isLoggedIn) {
      return HomeScreen();
    } else {
      return SplashScreen();
    }
  }
}
