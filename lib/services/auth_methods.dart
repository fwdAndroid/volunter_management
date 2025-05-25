import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:volunter_management/models/user_models.dart';
import 'package:volunter_management/screens/main/main_dashboard.dart';
import 'package:volunter_management/screens/main/organizer_main_dashboard.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signUpUser({
    required BuildContext context,
    required String fullName,
    required String email,
    required String password,
    required String type,
  }) async {
    try {
      List<String> methods = await FirebaseAuth.instance
          .fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email is already registered')),
        );
        return null;
      }

      if (email.isNotEmpty && password.isNotEmpty && fullName.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        UserModel userModel = UserModel(
          uuid: cred.user!.uid,
          type: type,
          fullName: fullName,
          email: email,
          password: password,
        );

        await _firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(userModel.toJson());
        // Optional: Show success and navigate
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Registration successful")));
        if (type == "Organizer") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (builder) => OrganizerMainDashboard()),
          );
        } else if (type == "Volunteer") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (builder) => MainDashboard()),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    return null;
  }

  Future<String> loginUpUser({
    required String email,
    required String pass,
  }) async {
    String res = 'Wrong Email or Password';
    try {
      if (email.isNotEmpty && pass.isNotEmpty) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: pass,
        );
        res = 'success';
      } else {
        res = 'Please fill in all fields';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        res = 'No user found for this email.';
      } else if (e.code == 'wrong-password') {
        res = 'Wrong password provided.';
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String?> getUserType() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        return userDoc.get('type') as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
