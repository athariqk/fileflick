import 'dart:typed_data';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:fileflick/models/transfer_data.dart';
import 'package:fileflick/services/sender.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';

class FileSendPage extends StatefulWidget {
  const FileSendPage({super.key});

  @override
  State<FileSendPage> createState() => _FileSendPageState();
}

class _FileSendPageState extends State<FileSendPage> {
  bool _isDragging = false;
  bool _isClicked = false;
  final List<TransferData> _files = [];

  final Sender sender = Sender();

  void _addFile(String name, Uint8List bytes, String? path) {
    if (!_files.any((item) => item.name == name)) {
      _files.add(TransferData(name: name, bytes: bytes, filePath: path));
    }
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: true,
      );

      if (result != null) {
        setState(() {
          for (var file in result.files) {
            _addFile(file.name, file.bytes!, file.path);
          }
        });
      }
    } catch (e) {
      debugPrint('Error with FilePicker: $e');
    }
  }

  void _handleDragDone(DropDoneDetails details) async {
    for (var file in details.files) {
      final fileName = file.name;

      Uint8List fileBytes;
      if (!kIsWeb) {
        try {
          fileBytes = await File(file.path).readAsBytes();
        } catch (e) {
          debugPrint('Error reading file bytes for $fileName: $e');
          continue;
        }
      } else {
        fileBytes = Uint8List(0);
      }

      setState(() {
        _addFile(fileName, fileBytes, file.path);
      });
    }
  }

  void _deleteFile(int index) {
    setState(() {
      if (index >= 0 && index < _files.length) {
        debugPrint('Deleting file: ${_files[index]}');
        _files.removeAt(index);
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
                  if (_files.isEmpty) ...[
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
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                _isDragging
                                    ? 'Release to Drop'
                                    : 'Tap or Drag Files Here',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isClicked = true;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _isClicked ? Colors.white : Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
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
                        itemCount: _files.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            elevation: 5,
                            child: ListTile(
                              leading: const Icon(Icons.file_present,
                                  color: Colors.green),
                              title: Text(_files[index].name),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
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
                            margin: const EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              color: _isDragging
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                _isDragging
                                    ? 'Release to Drop'
                                    : 'Drag Files Here',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 10),
                        child: ElevatedButton(
                          onPressed: () async {
                            // List<Device>? devices =
                            //     await TargetDevicesPage.prompt(context);
                            // if (devices != null) {
                            //   for (Device device in devices) {
                            //     sender.send(device, _files);
                            //   }
                            // }
                            sender.send(null, _files);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
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
