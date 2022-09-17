import 'dart:convert';
import 'dart:io';

import 'package:auto_screenshot/src/extensions.dart';

class Device {
  final String id;
  final String name;

  Device(this.id, this.name);

  @override
  String toString() {
    return "$id:$name";
  }
}

Future<List<Device>> getConnectedDevices() async {
  const defaultVal = <Device>[];

  final resultsJson = await Process.run("flutter", ["devices", "--machine"]);
  if (resultsJson.stdout == null) {
    return defaultVal;
  }

  final results = jsonDecode(resultsJson.stdout) as List<dynamic>;
  if (results.isEmpty) {
    return defaultVal;
  }

  final devices =
      results.map((result) => Device(result["id"], result["name"])).toList();
  return devices;
}

Future<List<Device>> getInstalledIOSSimulators() async {
  final results = await Process.run("xcrun", ["simctl", "list"]);
  final resultLines =
      LineSplitter().convert(results.stdout).map((line) => line.trim());

  final ignoreHeaders = resultLines
      .where((line) => !line.startsWith("--") && !line.startsWith("=="));

  // Matches any valid UUID surrounded by parentheses
  final uuidRx = RegExp(
      r'\([0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}\)');
  final containsUuid = ignoreHeaders.where((line) => uuidRx.hasMatch(line));

  final pairRx = RegExp(r"^[a-zA-Z]+\:");
  final ignorePairs = containsUuid.where((line) => !pairRx.hasMatch(line));

  // Matches a parenthesized UUID (group 2) and anything before it (group 1)
  final deviceRx = RegExp(
      r'^(.+).+(\([0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}\))');
  final devices = ignorePairs.map((line) {
    final match = deviceRx.firstMatch(line);
    if (match == null) {
      return Device("N/A", "N/A");
    }

    final deviceName = match.group(1) ?? 'N/A';
    final deviceId = match.group(2) ?? 'N/A';
    return Device(deviceId.trimChar("(").trimChar(")"), deviceName.trim());
  });
  final validDevices = devices.where((device) => device.id != "N/A");
  return validDevices.toList();
}

Future<void> bootIOSSimulator(Device device) async {
  await Process.run("xcrun", ["simctl", "bootstatus", device.id, "-b"]);
}

Future<List<Device>> getInstalledAndroidEmulators() async {
  final result = await Process.run("emulator", ["-list-avds"]);
  final resultLines = LineSplitter().convert(result.stdout);
  return resultLines
      .map((deviceName) => Device(deviceName, deviceName))
      .toList();
}

Future<void> bootAndroidEmulator(Device device) async {
  await Process.run("emulator", ["-avd", device.name]);
}
