import 'package:fileflick/screens/home.dart';
import 'package:fileflick/services/app_service.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FileFlickApp());
}

class FileFlickApp extends StatelessWidget {
  const FileFlickApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppService().startAdvertising();

    return MaterialApp(
      title: 'FileFlick',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
