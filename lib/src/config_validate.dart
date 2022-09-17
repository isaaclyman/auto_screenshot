import 'dart:io';

import 'package:auto_screenshot/src/config.dart';
import 'package:auto_screenshot/src/devices.dart';
import 'package:auto_screenshot/src/exceptions.dart';

validateConfig(AutoScreenshotConfig config) async {
  _validateTestPath(config.joinedTestPath);
  await _validateDevices(config.devices);
}

void _validateTestPath(String path) {
  final file = File(path);
  final type = file.statSync().type;
  if (type == FileSystemEntityType.file) {
    if (!file.path.endsWith('.dart')) {
      throw InvalidPathException(
        "The file at test_path exists but is not a Dart file: [$path].",
      );
    }
    print('✓ test_path is a Dart file.');
    return;
  }

  if (type == FileSystemEntityType.directory) {
    final dir = Directory(path);
    final files = dir.listSync(recursive: true).where(
          (entity) =>
              entity.statSync().type == FileSystemEntityType.file &&
              entity.path.endsWith('.dart'),
        );
    if (files.isEmpty) {
      throw InvalidPathException(
        "The directory at test_path doesn't contain any Dart files: [$path].",
      );
    }
    print(
        '✓ test_path is a directory containing ${files.length} Dart file(s).');
    return;
  }

  throw InvalidPathException(
    "No file or folder found at path: [$path].",
  );
}

Future<void> _validateDevices(List<String> deviceNames) async {
  final errors = <Exception>[];

  final validIOSDeviceNames =
      (await getInstalledIOSSimulators()).map((device) => device.name);
  final listedIOSDeviceNames = <String>[];
  final listedAndroidDeviceNames = <String>[];

  for (var deviceName in deviceNames) {
    final isIOSDevice = validIOSDeviceNames.contains(deviceName);
    final isAndroidDevice = false;

    if (isIOSDevice) {
      listedIOSDeviceNames.add(deviceName);
    } else if (isAndroidDevice) {
      listedAndroidDeviceNames.add(deviceName);
    } else {
      errors.add(InvalidDeviceException(
        "[$deviceName] is not a valid device. To see a list of valid devices, run `dart run auto_screenshot:list_devices`.",
      ));
    }
  }

  if (errors.isNotEmpty) {
    throw AggregateException(errors);
  } else {
    print(
      '✓ All device names are valid (${listedIOSDeviceNames.length} iOS, ${listedAndroidDeviceNames.length} Android).',
    );
  }
}
