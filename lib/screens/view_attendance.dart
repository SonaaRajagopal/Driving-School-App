import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewAttendance extends StatelessWidget {
  const ViewAttendance({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: const Color.fromARGB(255, 3, 41, 111),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Only fetch attended classes for the current user
        stream: FirebaseFirestore.instance
            .collection('attendedClasses')
            .where('userId', isEqualTo: user?.uid) // Filter by userId
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No classes attended yet.'));
          }

          final attendedClasses = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'date': data['date'] ?? 'No Date',
              'classType': data['classType'] ?? 'No Class Type',
              'instructor': data['instructor'] ?? 'No Instructor',
            };
          }).toList();

          return ListView.builder(
            itemCount: attendedClasses.length,
            itemBuilder: (context, index) {
              final classInfo = attendedClasses[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 177, 191, 217),
                      Color.fromARGB(255, 255, 255, 255),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text('${classInfo['classType']} Class'),
                  subtitle: Text(
                      'Date: ${classInfo['date']}\nInstructor: ${classInfo['instructor']}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}