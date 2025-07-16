import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drivinghub_welcome_login/screens/welcome_screen.dart';
import 'package:drivinghub_welcome_login/screens/view_feedback.dart';
import 'package:drivinghub_welcome_login/screens/view_userdetails.dart';
import 'package:drivinghub_welcome_login/screens/view_document.dart';
import 'package:drivinghub_welcome_login/screens/view_instructordetails.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  Future<String> _fetchAdminName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return doc.data()?['name'] ?? 'Admin';
    }
    return 'Admin';
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
              child: const Text(
                'Driving Hub',
                style: TextStyle(
                  fontSize: 40,
                  fontFamily: 'PublicSans-SemiBold',
                  fontWeight: FontWeight.bold,
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
                    Icons.account_circle,
                    color: Color.fromARGB(255, 184, 209, 233),
                    size: 50,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Admin Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.rate_review),
              title: const Text('View Feedback'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ViewFeedback()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_list),
              title: const Text('View Documents Uploaded'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewDocumentScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('View User Details'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ViewUserDetails()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.supervisor_account),
              title: const Text('View Instructor Details'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewInstructorDetails()),
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
          future: _fetchAdminName(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final adminName = snapshot.data ?? 'Admin';
            return Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 150.0), // Adjust this value to move up/down
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.account_circle,
                      size: 100,
                      color: Color.fromARGB(255, 3, 41, 111),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Welcome $adminName',
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
                        'You can view and control all tasks at the driving school digitally.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
