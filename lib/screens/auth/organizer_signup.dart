import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:volunter_management/screens/auth/login_screen.dart';
import 'package:volunter_management/screens/auth/signup_screen.dart';
import 'package:volunter_management/screens/main/organizer_main_dashboard.dart';
import 'package:volunter_management/services/auth_methods.dart';
import 'package:volunter_management/uitls/colors.dart';
import 'package:volunter_management/uitls/show_message_bar.dart';

class OrganizerSignup extends StatefulWidget {
  const OrganizerSignup({super.key});

  @override
  State<OrganizerSignup> createState() => _OrganizerSignupState();
}

class _OrganizerSignupState extends State<OrganizerSignup> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Organizor Registration",
          style: TextStyle(color: colorWhite),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: colorWhite),
        backgroundColor: mainColor,
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset("assets/logo.png", height: 200),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: userNameController,
                  decoration: InputDecoration(
                    hintText: 'User Name',
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
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
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
                      icon: const Icon(Icons.email, color: Color(0xff64748B)),
                      onPressed: () {},
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
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

              const SizedBox(height: 30),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        if (userNameController.text.isEmpty) {
                          showMessageBar("User Name is Required", context);
                        } else if (emailController.text.isEmpty) {
                          showMessageBar("Email is Required", context);
                        } else if (passController.text.isEmpty) {
                          showMessageBar("Password is Required", context);
                        } else {
                          setState(() {
                            isLoading = true;
                          });

                          if (_formKey.currentState?.validate() ?? false) {
                            await AuthMethods().signUpUser(
                              context: context,
                              fullName: userNameController.text.trim(),

                              email: emailController.text.trim(),

                              password: passController.text.trim(),

                              type: "Organizer",
                            );
                          }
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (builder) => OrganizerMainDashboard(),
                            ),
                          );
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
                      child: Text(
                        "Register",
                        style: TextStyle(color: colorWhite),
                      ),
                    ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (builder) => SignupScreen()),
                  );
                },
                child: Text("Register As Volunteer"),
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (builder) => LoginScreen()),
                  );
                },
                child: Text("Already Have an Account, Login In"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
