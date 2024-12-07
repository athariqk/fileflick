import 'dart:typed_data';

class TransferData {
  final String name;
  final Uint8List bytes;
  final String? filePath;

  TransferData({required this.name, required this.bytes, this.filePath});
}
