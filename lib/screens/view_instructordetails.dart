import 'package:flutter/material.dart';

class ViewInstructorDetails extends StatelessWidget {
  // Define a list of instructors with their details
  final List<Map<String, String>> instructors = [
    {'name': 'Ram', 'email': 'ram23@gmail.com'},
    {'name': 'Leena', 'email': 'leena09@gmail.com'},
    {'name': 'Harish', 'email': 'harish@gmail.com'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Instructor Details'),
        backgroundColor: const Color.fromARGB(255, 3, 41, 111),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: instructors.length,
        itemBuilder: (context, index) {
          final instructor = instructors[index];
          return Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 177, 191, 217),
                  Color.fromARGB(255, 255, 255, 255),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: ListTile(
              leading: Icon(Icons.person, size: 40, color: Colors.blue),
              title: Text(
                instructor['name']!,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(
                instructor['email']!,
                style: TextStyle(fontSize: 14),
              ),
              trailing: Icon(Icons.email, color: Colors.blue),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ViewInstructorDetails(),
  ));
}