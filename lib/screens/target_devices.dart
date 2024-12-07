import 'package:fileflick/models/device.dart';
import 'package:fileflick/services/app_service.dart';
import 'package:fileflick/widgets/device_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_selectable_cards/flutter_selectable_cards.dart';

class TargetDevicesPage extends StatefulWidget {
  const TargetDevicesPage({super.key});

  @override
  State<TargetDevicesPage> createState() => _TargetDevicesPageState();

  static Future<List<Device>?> prompt(BuildContext context) => showDialog(
        context: context,
        builder: (context) => const TargetDevicesPage(),
      );
}

class _TargetDevicesPageState extends State<TargetDevicesPage> {
  List<Device>? _discoveredServices;
  List<Device>? _selectedDevices;

  void _discoverServices() async {
    _discoveredServices = await AppService().discover();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _discoverServices();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: _discoveredServices == null
              ? const Center(child: Text('No services discovered yet'))
              : SingleChildScrollView(
                  child: SelectableCards(
                  isMultipleSelection: true,
                  children: List.generate(
                    _discoveredServices!.length,
                    (index) => DeviceWidget(
                      index: index,
                      child: ListTile(
                        leading: const Icon(Icons.wifi),
                        title: Text(_discoveredServices![index].name),
                      ),
                    ),
                  ),
                  onSelected: (index) {
                    _selectedDevices = (index as List<int>).map((i) => _discoveredServices![i]).toList();
                  },
                ))),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'.toUpperCase()),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedDevices),
          child: Text('Ok'.toUpperCase()),
        ),
      ],
    );
  }
}
