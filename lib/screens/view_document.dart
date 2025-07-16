import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class FileItem {
  final String name;
  final String downloadUrl;
  final DateTime? uploadTime;
  final int? size;
  final Reference ref;

  FileItem({
    required this.name,
    required this.downloadUrl,
    this.uploadTime,
    this.size,
    required this.ref,
  });
}

class ViewDocumentScreen extends StatefulWidget {
  const ViewDocumentScreen({Key? key}) : super(key: key);

  @override
  _ViewDocumentScreenState createState() => _ViewDocumentScreenState();
}

class _ViewDocumentScreenState extends State<ViewDocumentScreen> {
  List<FileItem> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final Reference storageRef =
          FirebaseStorage.instance.ref().child('uploads');
      final ListResult result = await storageRef.listAll();

      final files = await Future.wait(
        result.items.map((Reference ref) async {
          final FullMetadata metadata = await ref.getMetadata();
          final String downloadUrl = await ref.getDownloadURL();

          return FileItem(
            name: ref.name,
            downloadUrl: downloadUrl,
            uploadTime: metadata.timeCreated,
            size: metadata.size,
            ref: ref,
          );
        }),
      );

      setState(() {
        _files = files;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading files: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Failed to load files. Error: $e');
    }
  }

  Future<void> _viewFile(FileItem file) async {
    try {
      if (file.name.toLowerCase().endsWith('.pdf')) {
        await _viewPDF(file);
      } else if (file.name.toLowerCase().endsWith('.txt')) {
        await _viewTextFile(file);
      } else {
        await _downloadFile(file);
      }
    } catch (e) {
      _showErrorDialog('Error viewing file: $e');
    }
  }

  Future<void> _viewPDF(FileItem file) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/${file.name}';
      final pdfFile = File(filePath);

      if (!await pdfFile.exists()) {
        await Dio().download(file.downloadUrl, filePath);
      }

      Navigator.pop(context); // Dismiss loading dialog

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(file.name),
              backgroundColor: const Color.fromARGB(255, 3, 41, 111),
              foregroundColor: Colors.white,
            ),
            body: PDFView(
              filePath: filePath,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageSnap: true,
              onError: (error) {
                _showErrorDialog('Error loading PDF: $error');
              },
            ),
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Dismiss loading dialog
      _showErrorDialog('Error viewing PDF: $e');
    }
  }

  Future<void> _viewTextFile(FileItem file) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final response = await Dio().get(file.downloadUrl);
      final content = response.data.toString();

      Navigator.pop(context); // Dismiss loading dialog

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(file.name),
              backgroundColor: const Color.fromARGB(255, 3, 41, 111),
              foregroundColor: Colors.white,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Text(content),
            ),
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Dismiss loading dialog
      _showErrorDialog('Error viewing text file: $e');
    }
  }

  Future<void> _downloadFile(FileItem file) async {
    try {
      final uri = Uri.parse(file.downloadUrl);

      if (!await canLaunchUrl(uri)) {
        throw 'Could not launch URL';
      }

      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    } catch (e) {
      print('Download error: $e');
      _showErrorDialog('Failed to download file. Please try again.\nError: $e');
    }
  }

  Future<void> _deleteFile(FileItem file) async {
    try {
      await file.ref.delete();
      await _loadFiles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File deleted successfully')),
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to delete file. Error: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return 'Unknown size';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _getFileIcon(String fileName) {
    IconData iconData;
    if (fileName.toLowerCase().endsWith('.pdf')) {
      iconData = Icons.picture_as_pdf;
    } else if (fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg') ||
        fileName.toLowerCase().endsWith('.png')) {
      iconData = Icons.image;
    } else if (fileName.toLowerCase().endsWith('.doc') ||
        fileName.toLowerCase().endsWith('.docx')) {
      iconData = Icons.description;
    } else {
      iconData = Icons.insert_drive_file;
    }
    return Icon(iconData, size: 32);
  }

  Widget _buildFileActions(FileItem file) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.visibility, size: 20),
          onPressed: () => _viewFile(file),
          tooltip: 'View',
          constraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.download, size: 20),
          onPressed: () => _downloadFile(file),
          tooltip: 'Download',
          constraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
            size: 20,
          ),
          onPressed: () => _deleteFile(file),
          tooltip: 'Delete',
          constraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Documents'),
        backgroundColor: const Color.fromARGB(255, 3, 41, 111),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFiles,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _files.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.folder_open, size: 50, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No files uploaded yet'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFiles,
                  child: ListView.builder(
                    itemCount: _files.length,
                    itemBuilder: (context, index) {
                      final file = _files[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          dense: true,
                          visualDensity: VisualDensity.comfortable,
                          leading: _getFileIcon(file.name),
                          title: Text(
                            file.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            'Size: ${_formatFileSize(file.size)}\n'
                            'Uploaded: ${_formatDate(file.uploadTime)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: _buildFileActions(file),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
