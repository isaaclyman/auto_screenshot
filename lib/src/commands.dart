import 'dart:io';

import 'package:auto_screenshot/src/exceptions.dart';

Future<void> runTestOnDevice(
  String testPath,
  String deviceIdentifier,
) async {
  final result =
      await Process.run("flutter", ["test", testPath, "-d", deviceIdentifier]);
  if (result.exitCode != 0) {
    throw TestFailureException("Flutter test runner failed: ${result.stderr}");
  }
  print(result.stdout ?? '');
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
