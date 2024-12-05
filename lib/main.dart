import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'dart:io' if (dart.library.io) 'dart:io'; // Platform-specific import
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart'; // For desktop drag-and-drop
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FileFlick',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Welcome to FileFlick'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FileTransferPage()),
            );
          },
        child: const Text('Start'),
        ),
      ),
    );
  }
}

class FileTransferPage extends StatefulWidget {
  const FileTransferPage({super.key});

  @override
  State<FileTransferPage> createState() => _FileTransferPageState();
}

class _FileTransferPageState extends State<FileTransferPage> {
  bool _isDragging = false;
  bool _isClicked = false;  // Flag to track the button click
  List<String> _fileNames = []; // File names for display
  List<Uint8List> _fileBytes = []; // File bytes for web compatibility

  // Function to pick files using FilePicker
  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: true, // Ensure bytes are available
      );

      if (result != null) {
        setState(() {
          for (var file in result.files) {
            if (!_fileNames.contains(file.name)) {
              _fileNames.add(file.name);
              _fileBytes.add(file.bytes!);
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error with FilePicker: $e');
    }
  }

  // Drag-and-drop handler for desktop
  void _handleDragDone(DropDoneDetails details) async {
    for (var file in details.files) {
      final fileName = file.name;

      Uint8List fileBytes;
      if (!kIsWeb && file.path != null) {
        // For mobile/desktop platforms
        try {
          fileBytes = await File(file.path!).readAsBytes();
        } catch (e) {
          debugPrint('Error reading file bytes for $fileName: $e');
          continue;
        }
      } else {
        // For web platforms
        fileBytes = Uint8List(0);
      }

      setState(() {
        if (!_fileNames.contains(fileName)) {
          _fileNames.add(fileName);
          _fileBytes.add(fileBytes);
        }
      });
    }
  }

  // Function to delete selected file
  void _deleteFile(int index) {
    setState(() {
      if (index >= 0 && index < _fileNames.length && index < _fileBytes.length) {
        debugPrint('Deleting file: ${_fileNames[index]}');
        _fileNames.removeAt(index);
        _fileBytes.removeAt(index);
      } else {
        debugPrint('Invalid index for deletion: $index');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Transfer'),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  if (_fileNames.isEmpty) ...[
                    Expanded(
                      flex: 9,
                      child: GestureDetector(
                        onTap: _pickFiles,
                        child: DropTarget(
                          onDragEntered: (details) {
                            setState(() {
                              _isDragging = true;
                            });
                          },
                          onDragExited: (details) {
                            setState(() {
                              _isDragging = false;
                            });
                          },
                          onDragDone: _handleDragDone,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: _isDragging
                                  ? Colors.deepPurple.withOpacity(0.3)
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.deepPurple, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                _isDragging ? 'Release to Drop' : 'Tap or Drag Files Here',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      flex: 1, // 10% of height
                      child: Container(
                        width: double.infinity, // Make the width fill the screen
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isClicked = true; // Set flag to true when clicked
                            });
                            Navigator.pop(context); // To go back
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isClicked ? Colors.white : Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0), // Adjust the radius value here
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: _isClicked ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      flex: 5,
                      child: ListView.builder(
                        itemCount: _fileNames.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            elevation: 5,
                            child: ListTile(
                              leading: const Icon(Icons.file_present, color: Colors.deepPurple),
                              title: Text(_fileNames[index]),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteFile(index),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: GestureDetector(
                        onTap: _pickFiles,
                        child: DropTarget(
                          onDragEntered: (details) {
                            setState(() {
                              _isDragging = true;
                            });
                          },
                          onDragExited: (details) {
                            setState(() {
                              _isDragging = false;
                            });
                          },
                          onDragDone: _handleDragDone,
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 10), // Added margin to the right
                            decoration: BoxDecoration(
                              color: _isDragging
                                  ? Colors.deepPurple.withOpacity(0.3)
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.deepPurple, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                _isDragging ? 'Release to Drop' : 'Drag Files Here',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1, // 10% of height
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 10), // Make the width fill the screen
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // To go back
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0), // Adjust the radius value here
                            ),
                          ),
                          child: const Text(
                            'FLICK!',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
