import 'package:fileflick/models/device.dart';
import 'package:fileflick/models/file_history.dart';
import 'package:fileflick/models/transfer_data.dart';
import 'package:share_plus/share_plus.dart';

class Sender {
  void send(Device? targetDevice, List<TransferData> data) async {
    final result = await Share.shareXFiles(
        data.map((file) => XFile(file.filePath!)).toList());

    // TODO: implementasi transfer file via bluetooth atau LAN
    if (result.status == ShareResultStatus.success) {
      FileHistory().addFiles(data.map((file) => file.name).toList());
    }
  }
}
