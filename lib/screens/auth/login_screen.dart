import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:volunter_management/screens/auth/forgot_password.dart';
import 'package:volunter_management/screens/auth/signup_screen.dart';
import 'package:volunter_management/screens/main/main_dashboard.dart';
import 'package:volunter_management/services/auth_methods.dart';
import 'package:volunter_management/uitls/colors.dart';
import 'package:volunter_management/uitls/show_message_bar.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool isGoogle = false;
  bool _isPasswordVisible = false;
  bool isLoading = false;
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await _showExitDialog(context);
        return shouldPop ?? false;
      },
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              child: TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'example@gmail.com',
                  hintStyle: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  contentPadding: const EdgeInsets.only(left: 8, top: 15),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    borderSide: BorderSide(color: mainColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: mainColor),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: mainColor),
                  ),
                  fillColor: textColor,
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.person, color: Color(0xff64748B)),
                    onPressed: () {},
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: passController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  contentPadding: const EdgeInsets.only(left: 8, top: 15),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    borderSide: BorderSide(color: mainColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: mainColor),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: mainColor),
                  ),
                  fillColor: textColor,
                  prefixIcon: Icon(Icons.lock, color: Color(0xff64748B)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Color(0xff64748B),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        checkColor: Colors.white,
                        value: isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            isChecked = value!;
                          });
                        },
                      ),
                      Text(
                        'Remember Me',
                        style: GoogleFonts.poppins(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (builder) => const ForgotPassword(),
                        ),
                      );
                    },
                    child: Text(
                      "Forgot Password",
                      style: GoogleFonts.poppins(
                        color: Color(0xff94A3B8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (emailController.text.isEmpty ||
                    passController.text.isEmpty) {
                  showMessageBar("Email & Password is Required", context);
                } else {
                  setState(() {
                    isLoading = true;
                  });
                  String result = await AuthMethods().loginUpUser(
                    email: emailController.text.trim(),
                    pass: passController.text.trim(),
                  );
                  if (result == 'success') {
                    // SharedPref().saveRememberMe();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (builder) => MainDashboard()),
                    );
                  } else {
                    showMessageBar(result, context);
                  }
                  setState(() {
                    isLoading = false;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // <-- Radius
                ),
                backgroundColor: mainColor,
                fixedSize: const Size(320, 60),
              ),
              child: Text("Login", style: TextStyle(color: colorWhite)),
            ),
            SizedBox(height: 20),

            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (builder) => const SignupScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text.rich(
                  TextSpan(
                    text: 'Don’t have an account? ',
                    children: <InlineSpan>[
                      TextSpan(
                        text: 'Sign Up',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Do you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              if (Platform.isAndroid) {
                SystemNavigator.pop(); // For Android
              } else if (Platform.isIOS) {
                exit(0); // For iOS
              }
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
