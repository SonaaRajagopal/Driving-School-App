import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {
  static Future<void> saveUser(String name, String email, String uid, {bool isAdmin = false}) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'role': isAdmin ? 'admin' : 'user',
    });
  }

  static Future<bool> isUserAdmin(String uid) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc['role'] == 'admin';
    }
    return false;
  }
  static Future<void> saveFeedback(String uid , String username,String message) async {
    await FirebaseFirestore.instance.collection('course_feedback').add({
      'uid': uid,
      'username': username,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

