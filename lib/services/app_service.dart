import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:fileflick/models/device.dart';

class AppService {
  static final AppService _singleton = AppService._internal();

  factory AppService() {
    return _singleton;
  }

  AppService._internal()
      : _bonsoirService = BonsoirService(
            name: "FileFlick service",
            type: "_fileflick-serv._tcp",
            port: 62504);

  final BonsoirService _bonsoirService;
  BonsoirBroadcast? _broadcast;
  BonsoirDiscovery? _discovery;

  void startAdvertising() async {
    _broadcast = BonsoirBroadcast(service: _bonsoirService);
    await _broadcast!.ready;
    if (_broadcast!.isReady) {
      _broadcast!.start();
    }
  }

  void stopAdvertising() {
    _broadcast!.stop();
  }

  Future<List<Device>> discover() async {
    _discovery = BonsoirDiscovery(type: "_fileflick-serv._tcp");

    List<Device> devices = [];
    Completer<List<Device>> completer = Completer();

    await _discovery!.ready;

    _discovery!.eventStream!.listen((event) {
      if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
        event.service!.resolve(_discovery!.serviceResolver);
      } else if (event.type ==
          BonsoirDiscoveryEventType.discoveryServiceResolved) {
        devices.add(Device(
            name: event.service!.name,
            host: (event.service as ResolvedBonsoirService).host));
      }
    });

    _discovery!.start();

    Future.delayed(const Duration(milliseconds: 1000), () {
      _discovery!.stop();
      if (!completer.isCompleted) {
        completer.complete(devices);
      }
    });

    return completer.future;
  }
}
