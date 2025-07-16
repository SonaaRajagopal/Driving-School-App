import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduledPage extends StatefulWidget {
  final Function(int) onDelete;
  final Function(int) onMarkAsDone;

  const ScheduledPage({
    Key? key,
    required this.onDelete,
    required this.onMarkAsDone,
  }) : super(key: key);

  @override
  _ScheduledPageState createState() => _ScheduledPageState();
}

class _ScheduledPageState extends State<ScheduledPage> {
  List<Map<String, dynamic>> _scheduledClasses = [];

  @override
  void initState() {
    super.initState();
    _fetchScheduledClasses();
  }

  Future<void> _fetchScheduledClasses() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("User is not logged in");
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('scheduledClasses')
          .where('userId', isEqualTo: user.uid)
          .get();

      setState(() {
        _scheduledClasses = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'date': data['date'] ?? 'No Date',
            'classType': data['classType'] ?? 'No Class Type',
            'instructor': data['instructor'] ?? 'No Instructor',
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching scheduled classes: $e");
    }
  }

  void _deleteClass(int index) async {
    final classToDelete = _scheduledClasses[index];
    final String docId = classToDelete['id'];

    try {
      await FirebaseFirestore.instance
          .collection('scheduledClasses')
          .doc(docId)
          .delete();

      setState(() {
        _scheduledClasses.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Class on ${classToDelete['date']} deleted.')),
      );

      print("Class deleted successfully.");
    } catch (e) {
      print("Error deleting class: $e");
    }
  }

  void _markClassAsDone(int index) async {
    final classToMark = _scheduledClasses[index];
    final String docId = classToMark['id'];

    final user = FirebaseAuth.instance.currentUser;

    try {
      await FirebaseFirestore.instance
          .collection('scheduledClasses')
          .doc(docId)
          .delete();

      if (user != null) {
        await FirebaseFirestore.instance.collection('attendedClasses').add({
          'userId': user.uid,
          'date': classToMark['date'],
          'classType': classToMark['classType'],
          'instructor': classToMark['instructor'],
        });

        setState(() {
          _scheduledClasses.removeAt(index);
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Class on ${classToMark['date']} marked as attended.',
          ),
        ),
      );

      print("Class marked as done: ${classToMark['classType']}");
    } catch (e) {
      print("Error marking class as done: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduled Classes'),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 3, 41, 111),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Text(
                'List of Scheduled Classes:',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: _scheduledClasses.isEmpty
                  ? const Center(child: Text('No classes scheduled.'))
                  : ListView.builder(
                      itemCount: _scheduledClasses.length,
                      itemBuilder: (context, index) {
                        final classItem = _scheduledClasses[index];
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(255, 177, 191, 217),
                                Color.fromARGB(255, 255, 255, 255),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 10.0),
                          child: ListTile(
                            title: Text(
                                '${classItem['date']} - ${classItem['classType']}'),
                            subtitle: Text('Instructor: ${classItem['instructor']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Tooltip(
                                  message: "Mark class as attended",
                                  child: IconButton(
                                    icon: const Icon(Icons.done_rounded),
                                    onPressed: () {
                                      _markClassAsDone(index);
                                    },
                                  ),
                                ),
                                Tooltip(
                                  message: "Cancel Class",
                                  child: IconButton(
                                    icon: const Icon(Icons.delete_rounded),
                                    onPressed: () {
                                      _deleteClass(index);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}