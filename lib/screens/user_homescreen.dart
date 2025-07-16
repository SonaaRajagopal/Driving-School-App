import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drivinghub_welcome_login/screens/welcome_screen.dart';
import 'package:drivinghub_welcome_login/screens/schedule_class.dart';
import 'package:drivinghub_welcome_login/screens/book_class.dart';
import 'package:drivinghub_welcome_login/screens/view_attendance.dart';
import 'package:drivinghub_welcome_login/screens/course_feedback.dart';
import 'package:drivinghub_welcome_login/screens/payment_portal.dart';
import 'package:drivinghub_welcome_login/screens/document_upload.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({Key? key}) : super(key: key);

  Future<String> _fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return doc.data()?['name'] ?? 'User';
    }
    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          backgroundColor: const Color.fromARGB(255, 3, 41, 111),
          title: Padding(
            padding: const EdgeInsets.only(
                top: 29.0, left: 1.0, right: 10.0, bottom: 16.0),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Driving Hub',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PublicSans-SemiBold',
                  color: Color.fromARGB(255, 203, 209, 233),
                ),
              ),
            ),
          ),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(2),
            ),
          ),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 3, 41, 111),
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.person_rounded,
                    color: Color.fromARGB(255, 184, 209, 233),
                    size: 50,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'User Profile',
                    style: TextStyle(
                      color: Color.fromARGB(255, 240, 234, 234),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Book Classes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookClass()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_note),
              title: const Text('Scheduled Classes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ScheduledPage(
                          onDelete: (int) {}, onMarkAsDone: (int) {})),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('View Attendance'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ViewAttendance()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.comment),
              title: const Text('Give Course Feedback'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CourseFeedback()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Payment Portal'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),

            // To:
            ListTile(
              leading: const Icon(Icons.file_upload_outlined),
              title: const Text('Document Upload'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          FileUploadScreen()), // Removed const
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Exit'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WelcomeScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 218, 225, 231),
              Color.fromARGB(255, 174, 206, 236),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<String>(
          future: _fetchUsername(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final username = snapshot.data ?? 'User';
            return Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 110.0), // Adjust this value to move up or down
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_rounded,
                    size: 100,
                    color: Color.fromARGB(255, 3, 41, 111),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome $username',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 3, 41, 111),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Use the Driving Hub app to optimize your driving school tasks and manage your classes efficiently.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
