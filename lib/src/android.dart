import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_screenshot/src/commands.dart';
import 'package:auto_screenshot/src/devices.dart';
import 'package:auto_screenshot/src/exceptions.dart';
import 'package:path/path.dart' as path;

var port = 5554;
Future<void Function()> bootAndroidEmulator(Device device) async {
  print(
      "emulator -avd ${device.name} -port ${port.toStringAsFixed(0)} -no-boot-anim");

  final startEmu = await Process.start(
    "emulator",
    [
      "-avd",
      device.name,
      "-port",
      port.toStringAsFixed(0),
      "-no-boot-anim",
      "-wipe-data"
    ],
  );
  device.port = port;
  port += 2;

  final deviceOnline = await Process.run("adb", [
    "-s",
    "emulator-${device.port!.toStringAsFixed(0)}",
    "wait-for-device",
  ]);

  if (deviceOnline.exitCode != 0) {
    throw AndroidCommandException(
        "wait-for-device failed. [stdout:${deviceOnline.stdout}] [stderr:${deviceOnline.stderr}]");
  }

  await Future.delayed(Duration(seconds: 8));

  return () {
    print("kill ${startEmu.pid}");
    Process.killPid(startEmu.pid);
  };
}

Future<void> captureAndroidScreen(Device device, String outputPath) async {
  if (device.port == null) {
    throw InvalidDeviceException(
        "Android device [$device] has no port specified.");
  }

  final outputFile = File(outputPath);
  final fixedOutputPath = outputFile.absolute.path.replaceAll(" ", "_");
  print('outputPath: $fixedOutputPath');

  final dir = Directory(path.dirname(fixedOutputPath));
  dir.createSync(recursive: true);

  // adb exec-out screencap -p > screen.png
  final result = await runToCompletion(
    process: Process.run(
      "adb",
      [
        "-s",
        "emulator-${device.port!.toStringAsFixed(0)}",
        "exec-out",
        "screencap",
        "-p",
      ],
      stdoutEncoding: null,
    ),
    onException: (data) =>
        AndroidCommandException("Failed to capture screen. $data"),
    printStdout: false,
  );

  final png = result.stdout as List<int>;
  await File(fixedOutputPath).writeAsBytes(png);
}

Future<List<Device>> getInstalledAndroidEmulators() async {
  final result = await Process.run("emulator", ["-list-avds"]);
  final resultLines = LineSplitter().convert(result.stdout);
  return resultLines
      .map((deviceName) => Device(
            deviceName,
            deviceName,
            DeviceType.android,
          ))
      .toList();
}

Future<void> installAndroidApp(
    Device device, String apkPath, String bundleId) async {
  final file = File(apkPath);
  if (!file.existsSync() || !apkPath.endsWith('.apk')) {
    throw MissingPackageException(
      "Couldn't find APK file at [$apkPath]. Make sure to run `flutter build apk` first. Appbundles are not supported.",
    );
  }

  if (device.port == null) {
    throw InvalidDeviceException(
        "Android device [$device] has no port specified.");
  }

  print('App found at [$apkPath].');

  // adb -s emulator-5554 install myapp.apk
  await runToCompletion(
    process: Process.run("adb", [
      "-s",
      "emulator-${device.port!.toStringAsFixed(0)}",
      "install",
      "-r",
      "-g",
      apkPath,
    ]),
    onException: (data) =>
        AndroidCommandException("Couldn't install app. $data"),
  );
}

Future<void> loadAndroidDeepLink(
  Device device,
  String url,
  String bundleId,
) async {
  if (device.port == null) {
    throw InvalidDeviceException(
        "Android device [$device] has no port specified.");
  }

  // adb shell am start -a android.intent.action.VIEW \
  //   -c android.intent.category.BROWSABLE \
  //   -d "http://flutterbooksample.com/book/1"
  await runToCompletion(
    process: Process.run("adb", [
      "-s",
      "emulator-${device.port!.toStringAsFixed(0)}",
      "shell",
      "am",
      "start",
      "-a",
      "android.intent.action.VIEW",
      "-c",
      "android.intent.category.BROWSABLE",
      "-d",
      url,
      bundleId,
    ]),
    onException: (data) =>
        AndroidCommandException("Failed to load deep link. $data"),
  );
}

Future<void> stopRunningEmulators() async {
  final list = await runToCompletion(
    process: Process.run("adb", ["devices"]),
    onException: (data) => AndroidCommandException(
      "Couldn't get list of running emulators. $data",
    ),
  );
  final whitespaceRx = RegExp(r"\s");
  final devices = LineSplitter()
      .convert(list.stdout)
      .where((line) => line.startsWith("emulator-"))
      .map((line) => line.substring(0, line.indexOf(whitespaceRx)));
  for (var device in devices) {
    await runToCompletion(
      process: Process.run("adb", [
        "-s",
        device,
        "emu",
        "kill",
      ]),
      onException: (data) => AndroidCommandException(
        "Couldn't shut down device [$device]. $data",
      ),
    );
  }
}
