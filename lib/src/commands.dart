import 'dart:io';

import 'package:auto_screenshot/src/config.dart';
import 'package:auto_screenshot/src/devices.dart';
import 'package:auto_screenshot/src/exceptions.dart';
import 'package:path/path.dart' as path;

Future<void> assertBinariesAvailable() async {
  final expectedBinaries = <String>[
    "flutter",
    "xcrun",
    "emulator",
    "adb",
    "java",
  ];
  final errors = <Exception>[];

  for (var bin in expectedBinaries) {
    final result = await Process.run("which", [bin]);
    if (result.exitCode != 0) {
      errors.add(MissingBinaryException(
        "Couldn't find [$bin]. Check the README and make sure the necessary "
        "software is installed and added to your PATH.",
      ));
    } else {
      print("  [$bin] found at [${result.stdout.trim()}].");
    }
  }

  if (errors.isNotEmpty) {
    throw AggregateException(errors);
  } else {
    print('✓ All ${expectedBinaries.length} expected binaries were found.');
  }

  return;
}

Future<void> captureScreensOnDevice(
  AutoScreenshotConfig config,
  Device device,
) async {
  final baseUrl = device.type == DeviceType.android
      ? config.baseUrl[DeviceTypeString.android]
      : device.type == DeviceType.iOS
          ? config.baseUrl[DeviceTypeString.ios]
          : null;
  if (baseUrl == null) {
    throw InvalidDeviceException('Invalid device: [$device]');
  }

  final outputFolder = path.join(config.outputFolder, device.name);
  await device.loadDeepLink(baseUrl, "");
  await Future.delayed(Duration(seconds: 8));
  for (var capturePath in config.paths) {
    await device.loadDeepLink(baseUrl, capturePath);
    await Future.delayed(Duration(seconds: 1));
    await device.captureScreen(
      path.join(outputFolder, '${capturePath.replaceAll('/', '_')}.png'),
    );
  }

  print('Captured ${config.paths.length} screen(s) on [$device].');
}

Future<void> runToCompletion({
  required Future<ProcessResult> process,
  required MessageException Function(String data) onException,
}) async {
  final result = await process;
  if (result.exitCode != 0) {
    throw onException("[stdout:${result.stdout}] [stderr:${result.stderr}]");
  }

  print("[stdout:${result.stdout}]");
}
