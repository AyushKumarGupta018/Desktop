import 'package:deskprint/main.dart';
import 'package:deskprint/screens/login_screen.dart';
import 'package:deskprint/screens/printing_dashboard.dart';
import 'package:deskprint/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LoginState>(
      future: _checkLoginState(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing Café System...'),
                ],
              ),
            ),
          );
        }

        final loginState = snapshot.data ?? LoginState.firstTime;

        switch (loginState) {
          case LoginState.loggedIn:
            return const PrintingDashboard();
          case LoginState.returningUser:
            return const LoginScreen(isReturning: true);
          case LoginState.firstTime:
            return const WelcomeScreen();
        }
      },
    );
  }

  Future<LoginState> _checkLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    final cafeId = prefs.getString('cafe_id');
    final ownerEmail = prefs.getString('owner_email');
    final hasSeenWelcome = prefs.getBool('has_seen_welcome') ?? false;

    if (cafeId != null && ownerEmail != null) {
      return LoginState.loggedIn;
    } else if (hasSeenWelcome) {
      return LoginState.returningUser;
    } else {
      return LoginState.firstTime;
    }
  }
}
