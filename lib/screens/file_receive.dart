import 'package:fileflick/services/app_service.dart';
import 'package:flutter/material.dart';

class FileReceivePage extends StatefulWidget {
  const FileReceivePage({super.key});

  @override
  State<FileReceivePage> createState() => _FileReceivePageState();
}

class _FileReceivePageState extends State<FileReceivePage> {
  @override
  void initState() {
    super.initState();
    AppService().startAdvertising();
  }

  // TODO: implementasi seluruh fungsionalitas

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("File Receive")),
        body: const Center(child: Text("Ready to receive files!")));
  }
}
