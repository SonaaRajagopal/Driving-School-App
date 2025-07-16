import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookClass extends StatelessWidget {
  static const String _title = 'Book Classes';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      debugShowCheckedModeBanner: false, 
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            _title,
            style: TextStyle(color: Colors.white, fontSize: 28),
          ),
          backgroundColor: const Color.fromARGB(255, 3, 41, 111),
          foregroundColor: Colors.white,
        ),
        body: const Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: 40.0),
            child: MyStatefulWidget(),
          ),
        ),
      ),
    );
  }
}

enum Bookclasses { theory, stimulation, driving }

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  Bookclasses _site = Bookclasses.theory;
  TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedInstructor;

  final List<String> _instructors = ['Ram', 'Leena', 'Harish'];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
      });
    }
  }

  String _getClassType() {
    switch (_site) {
      case Bookclasses.theory:
        return 'Theory';
      case Bookclasses.stimulation:
        return 'Stimulation';
      case Bookclasses.driving:
        return 'Driving';
      default:
        return '';
    }
  }

  Future<void> _addClass() async {
    final user = FirebaseAuth.instance.currentUser;
    final selectedDateStr = DateFormat('dd/MM/yyyy').format(_selectedDate);

    if (user != null && _selectedInstructor != null) {
      // Check if the instructor is already booked on the selected date
      final querySnapshot = await FirebaseFirestore.instance
          .collection('scheduledClasses')
          .where('instructor', isEqualTo: _selectedInstructor)
          .where('date', isEqualTo: selectedDateStr)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _showInstructorUnavailableAlert(context);
      } else {
        final classData = {
          'userId': user.uid, 
          'date': selectedDateStr,
          'classType': _getClassType(),
          'instructor': _selectedInstructor!,
        };

        try {
          await FirebaseFirestore.instance
              .collection('scheduledClasses')
              .add(classData);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Class booked successfully')),
          );
        } catch (e) {
          print("Error adding class: $e");
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an instructor')),
      );
    }
  }

  void _showInstructorUnavailableAlert(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Instructor Unavailable'),
          content: const Text('The selected instructor is already booked on this date. Please choose a different date or instructor.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select Date',
                hintText: 'Tap to select a date',
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
          ),
          const SizedBox(height: 20),

          // Radio button for Theory
          ListTile(
            leading: Radio(
              value: Bookclasses.theory,
              groupValue: _site,
              onChanged: (Bookclasses? value) {
                setState(() {
                  _site = value!;
                });
              },
            ),
            title: const Row(
              children: [
                Icon(Icons.menu_book, size: 30),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Theory'),
                    SizedBox(height: 5),
                    Text(
                      'Theory classes will be taken for 4 days.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Radio button for Stimulation
          ListTile(
            leading: Radio(
              value: Bookclasses.stimulation,
              groupValue: _site,
              onChanged: (Bookclasses? value) {
                setState(() {
                  _site = value!;
                });
              },
            ),
            title: Row(
              children: [
                Icon(Icons.videogame_asset_rounded, size: 30),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Stimulation'),
                      SizedBox(height: 5),
                      Text(
                        'Stimulation classes will be taken for 6 days.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        overflow: TextOverflow.ellipsis, // Prevents text overflow
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Radio button for Driving
          ListTile(
            leading: Radio(
              value: Bookclasses.driving,
              groupValue: _site,
              onChanged: (Bookclasses? value) {
                setState(() {
                  _site = value!;
                });
              },
            ),
            title: const Row(
              children: [
                Icon(Icons.directions_car_rounded, size: 30),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Driving'),
                    SizedBox(height: 5),
                    Text(
                      'Driving classes will be taken for 10 days.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Dropdown to select instructor
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select Instructor',
              ),
              value: _selectedInstructor,
              hint: const Text('Select Instructor'),
              items: _instructors.map((String instructor) {
                return DropdownMenuItem<String>(
                  value: instructor,
                  child: Text(instructor),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedInstructor = value;
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          // Submit button
         Container(
          margin: const EdgeInsets.all(25),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _addClass, // Replace this with your function
              style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 214, 217, 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100), // Adjusting to match your request
                ),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }
}