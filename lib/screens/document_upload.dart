import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({Key? key}) : super(key: key);
  @override
  _FileUploadScreenState createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  List<PlatformFile>? _selectedFiles;
  bool _isUploading = false;

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        setState(() {
          _selectedFiles = result.files;
        });
      }
    } catch (e) {
      print('Error picking files: $e');
    }
  }

  Future<void> _uploadFiles() async {
    if (_selectedFiles == null || _selectedFiles!.isEmpty) return;

    setState(() {
      _isUploading = true;
    });

    try {
      for (PlatformFile file in _selectedFiles!) {
        File fileToUpload = File(file.path!);
        String fileName =
            DateTime.now().millisecondsSinceEpoch.toString() + '_' + file.name;

        // Create a reference to the file location in Firebase Storage
        Reference ref =
            FirebaseStorage.instance.ref().child('uploads/$fileName');

        // Upload the file
        await ref.putFile(fileToUpload);

        // Get the download URL (optional, if you need to store it somewhere)
        String downloadURL = await ref.getDownloadURL();
        print('File uploaded: $downloadURL');
      }

      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Files submitted successfully!'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      // Clear selected files
      setState(() {
        _selectedFiles = null;
      });
    } catch (e) {
      print('Error uploading files: $e');
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while uploading files.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Upload'),
        backgroundColor: const Color.fromARGB(255, 3, 41, 111),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _pickFiles,
              child: Text('Select Files'),
            ),
            SizedBox(height: 16),
            if (_selectedFiles != null && _selectedFiles!.isNotEmpty) ...[
              Text(
                'Selected Files:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedFiles!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_selectedFiles![index].name),
                      subtitle: Text(
                          'Size: ${(_selectedFiles![index].size / 1024).toStringAsFixed(2)} KB'),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _isUploading ? null : _uploadFiles,
                child: _isUploading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Submit Files'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
