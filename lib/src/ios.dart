import 'dart:convert';
import 'dart:io';

import 'package:auto_screenshot/src/commands.dart';
import 'package:auto_screenshot/src/devices.dart';
import 'package:auto_screenshot/src/exceptions.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;

Future<void Function()> bootIOSSimulator(Device device) async {
  print("xcrun simctl bootstatus ${device.id} -b");
  final process = await Process.run(
    "xcrun",
    ["simctl", "bootstatus", device.id, "-b"],
    runInShell: true,
  );

  if (process.exitCode != 0) {
    throw IOSSimulatorBootException(
      "iOS Simulator failed to boot: ${process.stderr}",
    );
  }

  print('[stdout:${process.stdout}] [stderr:${process.stderr}]');

  return () async {
    print("xcrun simctl shutdown ${device.id}");
    await Process.run("xcrun", ["simctl", "shutdown", device.id]);
  };
}

Future<void> captureIOSScreen(Device device, String outputPath) async {
  final outputFile = File(outputPath);
  final fixedOutputPath = outputFile.absolute.path;
  print('outputPath: $fixedOutputPath');

  final dir = Directory(path.dirname(fixedOutputPath));
  dir.createSync(recursive: true);

  // xcrun simctl io booted screenshot ./screen.png
  await runToCompletion(
    process: Process.run(
      "xcrun",
      [
        "simctl",
        "io",
        device.id,
        "screenshot",
        fixedOutputPath,
        "--mask",
        "black",
      ],
    ),
    onException: (data) =>
        IOSCommandException("Failed to capture screen. $data"),
  );
}

Future<List<Device>> getInstalledIOSSimulators() async {
  final resultsJson = await Process.run("xcrun", ["simctl", "list", "--json"]);
  if (resultsJson.stdout == null) {
    return [];
  }

  final results = jsonDecode(resultsJson.stdout) as Map;
  final deviceCategories = results["devices"] as Map;
  final devices = (deviceCategories.values)
      .map((deviceList) => deviceList as Iterable<dynamic>)
      .flattened
      .where((device) => device["isAvailable"] == true);

  return devices
      .map((device) => Device(device["udid"], device["name"], DeviceType.iOS))
      .toList();
}

Future<void> installIOSApp(Device device, String appFolder) async {
  final dir = Directory(appFolder);
  if (!dir.existsSync()) {
    throw MissingPackageException(
        "Couldn't find folder at [$appFolder]. Make sure to run `flutter run` targeting an iOS Simulator first.");
  }

  final files = dir.listSync();
  final file = files.firstWhereOrNull((f) => f.path.endsWith('.app'));
  if (file == null) {
    throw MissingPackageException(
      "Couldn't find APP file in [$appFolder]. Make sure to run `flutter run` targeting an iOS Simulator first.",
    );
  }

  print('App found at [${file.absolute.path}].');

  // xcrun simctl install $DEVICE_UDID /path/to/your/app
  await runToCompletion(
    process: Process.run(
      "xcrun",
      [
        "simctl",
        "install",
        device.id,
        path.basename(file.path),
      ],
      workingDirectory: path.dirname(file.absolute.path),
    ),
    onException: (data) => IOSCommandException("Couldn't install app. $data"),
  );
}

Future<void> loadIOSDeepLink(Device device, String url) async {
  // xcrun simctl openurl booted customscheme://flutterbooksample.com/book/1
  await runToCompletion(
    process: Process.run("xcrun", [
      "simctl",
      "openurl",
      device.id,
      url,
    ]),
    onException: (data) =>
        IOSCommandException("Failed to load deep link. $data"),
  );
}

Future<void> loadIOSData(
  Device device,
  String bundleId,
  Directory seedDirectory,
) async {
  // xcrun simctl get_app_container booted com.isaaclyman.sootly data
  final appContainerResult = await runToCompletion(
    process: Process.run("xcrun", [
      "simctl",
      "get_app_container",
      device.id,
      bundleId,
      "data",
    ]),
    onException: (data) => IOSCommandException(
      "Failed to get data directory. $data",
    ),
  );
  final docsPath =
      path.join(appContainerResult.stdout.toString().trim(), "Documents");
  seedDirectory.listSync(recursive: true).forEach((file) {
    File(file.path).copySync(path.join(docsPath, path.basename(file.path)));
  });
}
