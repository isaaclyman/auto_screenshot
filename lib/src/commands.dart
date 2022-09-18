import 'dart:io';

import 'package:auto_screenshot/src/exceptions.dart';
import "package:path/path.dart" as path;

Future<void> runTestOnDevice(
  String testPath,
  String deviceIdentifier,
) async {
  final file = File(testPath);
  final type = file.statSync().type;
  final testFilePaths = <String>[];
  if (type == FileSystemEntityType.file) {
    testFilePaths.add(testPath);
  } else {
    final dir = Directory(testPath);
    final files = dir.listSync(recursive: true).where(
          (entity) =>
              entity.statSync().type == FileSystemEntityType.file &&
              entity.path.endsWith('.dart'),
        );
    testFilePaths.addAll(files.map((f) => f.path));
  }

  for (var target in testFilePaths) {
    final result = await Process.run("flutter", [
      "drive",
      "--driver=test_driver/integration_test.dart",
      "--target=$target",
      "-d",
      deviceIdentifier
    ]);
    if (result.exitCode != 0) {
      throw TestFailureException(
          "Flutter test runner failed: [stdout:${result.stdout}] [stderr:${result.stderr}]");
    }
    print('Test [${path.basename(target)}] passed.');
  }
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
