import 'dart:async';
import 'package:flutter/material.dart';
import 'package:volunter_management/uitls/colors.dart';
import 'package:volunter_management/wrapper/wrapper_class.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    await Future.delayed(const Duration(seconds: 3)); // Simulate splash time

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Wrapper()),
    );
    // User? user = FirebaseAuth.instance.currentUser;

    // if (user != null) {
    //   // User is signed in, navigate to Home Page
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => MainDashboard()),
    //   );
    // } else {
    //   // No user signed in, navigate to Login Page
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => LoginScreen()),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Center(child: Image.asset('assets/logo.png'))],
      ),
    );
  }
}
