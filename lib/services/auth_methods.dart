import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:volunter_management/uitls/show_message_bar.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signUpUser({
    required BuildContext context,
    required String fullName,
    required String email,
    required String password,
    required String type,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user?.sendEmailVerification(); // ✅ Send verification

      // Store additional user info in Firestore if needed
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'fullName': fullName,
            'email': email,
            'type': type,
            'uid': userCredential.user!.uid,
            'password': password,
            'isVerified': false,
          });

      showMessageBar(
        "Verification email sent! Please check your inbox.",
        context,
      );
      return userCredential.user;
    } catch (e) {
      showMessageBar(e.toString(), context);
      return null;
    }
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
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot snap = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      return snap['type'];
    }
    return null;
  }
}
