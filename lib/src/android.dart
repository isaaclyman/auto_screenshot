import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_screenshot/src/commands.dart';
import 'package:auto_screenshot/src/devices.dart';
import 'package:auto_screenshot/src/exceptions.dart';

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

Future<void> captureAndroidScreen(Device device, String outputPath) async {
  if (device.port == null) {
    throw InvalidDeviceException(
        "Android device [$device] has no port specified.");
  }

  // adb exec-out screencap -p > screen.png
  await runToCompletion(
    process: Process.run("adb", [
      "exec-out",
      "screencap",
      "-P",
      device.port!.toStringAsFixed(0),
      "-p",
      ">",
      outputPath,
    ]),
    onException: (data) =>
        AndroidCommandException("Failed to capture screen. $data"),
  );
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

Future<void> installAndroidApp(Device device, String apkPath) async {
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
      "emulator-${device.port!.toStringAsFixed(0)}",
      "install",
      apkPath,
    ]),
    onException: (data) =>
        AndroidCommandException("Couldn't install app. $data"),
  );
}

Future<void> loadAndroidDeepLink(Device device, String url) async {
  if (device.port == null) {
    throw InvalidDeviceException(
        "Android device [$device] has no port specified.");
  }

  // adb shell am start -a android.intent.action.VIEW \
  //   -c android.intent.category.BROWSABLE \
  //   -d "http://flutterbooksample.com/book/1"
  await runToCompletion(
    process: Process.run("adb", [
      "shell",
      "am",
      "-P",
      device.port!.toStringAsFixed(0),
      "start",
      "-a",
      "android.intent.action.VIEW",
      "-c",
      "android.intent.category.BROWSABLE",
      "-d",
      url,
    ]),
    onException: (data) =>
        AndroidCommandException("Failed to load deep link. $data"),
  );
}
