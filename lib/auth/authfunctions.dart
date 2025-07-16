import 'package:drivinghub_welcome_login/auth/firebasefunctions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:drivinghub_welcome_login/screens/user_homescreen.dart';
import 'package:drivinghub_welcome_login/screens/admin_homescreen.dart'; 

class AuthServices {
  //Signup 
  static signupUser(
      String email, String password, String name, BuildContext context, {bool isAdmin = false}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseAuth.instance.currentUser!.updateDisplayName(name);
      await FirebaseAuth.instance.currentUser!.updateEmail(email);
      await FirestoreServices.saveUser(
          name, email, userCredential.user!.uid, isAdmin: isAdmin);   // saving user details to firestore (name , email , role)

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account Created Successfully!')),
      );

      //Redirect based on role
      if (isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminHomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserHomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password Provided is too weak.')),
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email Provided already Exists.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup Failed: ${e.message}')),
        );
      }
    } catch (e) {
      debugPrint("Error during signup: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred.')),
      );
    }
  }
  //Signin Method
  static signinUser(String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      //Fetch user role from Firestore
      bool isAdmin = await FirestoreServices.isUserAdmin(userCredential.user!.uid);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged in Successfully!')),
      );

      // Redirect based on role
      if (isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminHomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserHomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuthException: ${e.code}");

      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user found with this email.')),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password did not match.')),
        );
      } else {
        // Log and show any other FirebaseAuthException
        debugPrint("Unhandled error: ${e.code}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.message}')),
        );
      }
    } catch (e) {
      debugPrint("Error during signin: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred.')),
      );
    }
  }
}
