import 'dart:io';

import 'package:auto_screenshot/src/exceptions.dart';

Future<ProcessResult> runTestOnDevice(
    String testPath, String deviceIdentifier) async {
  return Process.run("flutter", ["test", testPath, "-d", deviceIdentifier]);
}

Future<void> assertBinariesAvailable() async {
  final expectedBinaries = <String>[
    "flutter",
    "xcrun",
    "emulator",
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
    }
  }

  if (errors.isNotEmpty) {
    throw AggregateException(errors);
  } else {
    print('✓ All ${expectedBinaries.length} expected binaries were found.');
  }

  return;
}
