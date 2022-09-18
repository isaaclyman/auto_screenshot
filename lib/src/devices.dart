import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_screenshot/src/exceptions.dart';
import 'package:auto_screenshot/src/extensions.dart';
import 'package:collection/collection.dart';
import "package:path/path.dart" as path;

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

  String get flutterId {
    if (type == DeviceType.android) {
      return "emulator-$port";
    } else if (type == DeviceType.iOS) {
      return id;
    } else {
      throw UnsupportedDeviceException(
          "flutterId: Unsupported device [$id:$name].");
    }
  }

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
      throw UnsupportedDeviceException("boot: Unsupported device [$id:$name].");
    }
  }

  void stop() async {
    _stopEmulator?.call();
  }
}

Future<List<Device>> getConnectedDevices() async {
  final resultsJson = await Process.run("flutter", ["devices", "--machine"]);
  if (resultsJson.stdout == null) {
    return [];
  }

  final results = jsonDecode(resultsJson.stdout) as List<dynamic>;
  if (results.isEmpty) {
    return [];
  }

  final devices = results.map((result) {
    final platform = result["targetPlatform"] as String;
    return Device(
      result["id"],
      result["name"],
      platform.startsWith("android")
          ? DeviceType.android
          : platform.startsWith("ios")
              ? DeviceType.iOS
              : DeviceType.unsupported,
    );
  }).toList();
  return devices;
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

  return () async {
    print("xcrun simctl shutdown ${device.id}");
    await Process.run("xcrun", ["simctl", "shutdown", device.id]);
  };
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

var port = 5554;
Future<void Function()> bootAndroidEmulator(Device device) async {
  print(
      "emulator -avd ${device.name} -port ${port.toStringAsFixed(0)} -no-boot-anim");
  final process = await Process.start(
    "emulator",
    ["-avd", device.name, "-port", port.toStringAsFixed(0), "-no-boot-anim"],
  );
  device.port = port;
  port += 2;

  stopFn() {
    print("kill ${process.pid}");
    Process.killPid(process.pid);
  }

  final settled = Completer<void Function()>();

  var timer = Timer(Duration.zero, () {});
  final stdout = <String>[];
  final stderr = <String>[];

  resetTimer() {
    timer.cancel();
    timer = Timer(Duration(seconds: 1), () {
      if (stderr.isNotEmpty) {
        print(
          AndroidEmulatorBootException(
            "Android emulator had non-fatal errors: ${stderr.join("\n")}",
          ),
        );
      }
      settled.complete(stopFn);
    });
  }

  resetTimer();

  process.stdout.transform(utf8.decoder).forEach((line) {
    stdout.add(line);
    resetTimer();
  });

  process.stderr.transform(utf8.decoder).forEach((line) {
    stderr.add(line);
  });

  process.exitCode.then((value) {
    if (value == 0) {
      settled.complete(stopFn);
    } else {
      settled.completeError(AndroidEmulatorBootException(
          "Android emulator failed to boot: ${stderr.join("\n")}"));
    }
  });

  return settled.future;
}
