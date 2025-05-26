import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:volunter_management/screens/auth/login_screen.dart';
import 'package:volunter_management/uitls/colors.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController _emailController = TextEditingController();
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _sendPasswordResetEmail() async {
    setState(() {
      isLoading = true;
    });

    try {
      String email = _emailController.text.trim();

      // Send password reset email
      await _auth.sendPasswordResetEmail(email: email);

      // Show confirmation and navigate to the login screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password reset email sent! Please check your email, including the spam folder, for any response',
          ),
        ),
      );

      // Navigate to the login screen after a successful password reset email
      Navigator.push(
        context,
        MaterialPageRoute(builder: (builder) => LoginScreen()),
      ); // Replace '/login' with your actual login route
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending password reset email: $e')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: colorWhite),
        title: Text("Forgot Password", style: TextStyle(color: colorWhite)),
        backgroundColor: mainColor,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/logo.png', // Replace with your icon asset
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Forgot Password",
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  "Please type your email below and we will give you a OTP code",
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 16),
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Text(
                    'Email',
                    style: GoogleFonts.plusJakartaSans(
                      color: mainColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  controller: _emailController,
                  style: GoogleFonts.plusJakartaSans(color: secondaryColor),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: secondaryColor),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: mainColor),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: mainColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: mainColor),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: mainColor),
                    ),
                    hintText: "Enter Email Address",
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: secondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Flexible(child: Container(), flex: 5),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  _sendPasswordResetEmail();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // <-- Radius
                  ),
                  backgroundColor: mainColor,
                  fixedSize: const Size(320, 60),
                ),
                child: Text("Send Email", style: TextStyle(color: colorWhite)),
              ),
            ),
          ),
          Flexible(child: Container()),
        ],
      ),
    );
  }
}
