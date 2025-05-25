import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:volunter_management/screens/auth/login_screen.dart';
import 'package:volunter_management/screens/main/main_dashboard.dart';
import 'package:volunter_management/services/auth_methods.dart';
import 'package:volunter_management/wrapper/enum.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthMethods().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) return LoginScreen();

          return FutureBuilder<UserType>(
            future: AuthMethods().getUserType(user.uid),
            builder: (context, typeSnapshot) {
              if (typeSnapshot.connectionState == ConnectionState.done) {
                return MainDashboard(userType: typeSnapshot.data!);
              }
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
