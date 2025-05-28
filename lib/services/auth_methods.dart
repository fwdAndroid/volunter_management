import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String> signUpUser({
    required String email,
    required String password,
    required String fullName,
    required String type,
  }) async {
    String res = "Some error occurred";
    try {
      // Try creating user
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user to database (Firestore/Realtime DB)
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'email': email,
        'fullName': fullName,
        'password': password,
        'type': type,
        'createdAt': DateTime.now(),
      });

      // Send email verification
      await cred.user!.sendEmailVerification();

      res = "success";
    } on FirebaseAuthException catch (err) {
      if (err.code == 'email-already-in-use') {
        res = 'Email is already used. Try logging in.';
      } else {
        res = err.message ?? "An error occurred";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
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
