import 'dart:async';
import 'dart:io';

import 'package:auto_screenshot/src/android.dart';
import 'package:auto_screenshot/src/config.dart';
import 'package:auto_screenshot/src/exceptions.dart';
import 'package:auto_screenshot/src/extensions.dart';
import 'package:auto_screenshot/src/ios.dart';

import 'package:path/path.dart' as path;

enum DeviceType {
  iOS,
  android,
  unsupported,
}

class Device {
  final String id;
  final String name;
  final DeviceType type;
  int? port;

  void Function()? _stopEmulator;

  Device(this.id, this.name, this.type);

  @override
  String toString() {
    return "$id:$name";
  }

  Future<void> boot() async {
    if (type == DeviceType.android) {
      _stopEmulator = await bootAndroidEmulator(this);
      return;
    } else if (type == DeviceType.iOS) {
      _stopEmulator = await bootIOSSimulator(this);
      return;
    } else {
      throw InvalidDeviceException("boot: Unsupported device [$this].");
    }
  }

  Future<void> captureScreen(String outputPath) async {
    if (type == DeviceType.android) {
      await captureAndroidScreen(this, outputPath);
    } else if (type == DeviceType.iOS) {
      await captureIOSScreen(this, outputPath);
    } else {
      throw InvalidDeviceException(
          "captureScreen: Unsupported device [$this].");
    }
  }

  Future<void> installApp(Map<String, String> bundleId) async {
    if (type == DeviceType.android) {
      await installAndroidApp(
        this,
        path.join(
          'build',
          'app',
          'outputs',
          'apk',
          'release',
          'app-release.apk',
        ),
        bundleId[DeviceTypeString.android]!,
      );
    } else if (type == DeviceType.iOS) {
      await installIOSApp(
          this,
          path.join(
            'build',
            'ios',
            'iphonesimulator',
          ));
    } else {
      throw InvalidDeviceException("installApp: Unsupported device [$this].");
    }
  }

  Future<void> loadDeepLink(
      String baseUrl, String path, Map<String, String> bundleId) async {
    if (type == DeviceType.android) {
      await loadAndroidDeepLink(
          this, baseUrl.joinUrl(path), bundleId[DeviceTypeString.android]!);
    } else if (type == DeviceType.iOS) {
      await loadIOSDeepLink(this, baseUrl.joinUrl(path));
    } else {
      throw InvalidDeviceException("loadDeepLink: Unsupported device [$this].");
    }
  }

  void stop() async {
    _stopEmulator?.call();
  }
}
