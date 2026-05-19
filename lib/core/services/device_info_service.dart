import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  DeviceInfoService._();
  static final DeviceInfoService instance = DeviceInfoService._();

  String? _cached;

  Future<String> readDeviceName() async {
    if (_cached != null) return _cached!;
    final plugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final info = await plugin.androidInfo;
        return _cached = '${info.manufacturer} ${info.model}';
      }
      if (Platform.isIOS) {
        final info = await plugin.iosInfo;
        return _cached = '${info.name} · ${info.model}';
      }
      if (Platform.isWindows) {
        final info = await plugin.windowsInfo;
        return _cached = info.computerName;
      }
      if (Platform.isLinux) {
        final info = await plugin.linuxInfo;
        return _cached = info.prettyName;
      }
      if (Platform.isMacOS) {
        final info = await plugin.macOsInfo;
        return _cached = '${info.computerName} · ${info.model}';
      }
    } catch (_) {}
    return _cached = 'Unknown terminal';
  }
}
