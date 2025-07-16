import 'package:flutter/material.dart';
import 'package:drivinghub_welcome_login/screens/user_homescreen.dart';
import 'package:drivinghub_welcome_login/auth/firebasefunctions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CourseFeedback extends StatefulWidget {
  const CourseFeedback({Key? key}) : super(key: key);

  @override
  State<CourseFeedback> createState() => _CourseFeedbackState();
}

class _CourseFeedbackState extends State<CourseFeedback> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();
  bool isLoading = false;
  bool isSubmitted = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      final User? user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid;
      final username = user?.displayName ?? 'Unknown User';

      if (uid != null) {
        // Save feedback to Firestore
        await FirestoreServices.saveFeedback(
          uid,
          username,
          _messageController.text,
        );

        setState(() {
          isLoading = false;
          isSubmitted = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted successfully!')),
        );

        _messageController.clear();

        // Reset submission state after a delay
        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            isSubmitted = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Feedback'),
        backgroundColor: const Color.fromARGB(255, 3, 41, 111),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'We welcome your feedback on the driving class. Please share your thoughts!',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading || isSubmitted ? null : submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 214, 217, 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        )
                      : isSubmitted
                          ? const Icon(Icons.check, color: Colors.black, size: 30)
                          : const Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
