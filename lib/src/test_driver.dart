import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> autoScreenshotIntegrationDriver() async {
  await integrationDriver(
    onScreenshot: autoScreenshotOnScreenshotHandler,
  );
}

Future<bool> autoScreenshotOnScreenshotHandler(
  String screenshotName,
  List<int> screenshotBytes,
) async {
  final File image = File('$screenshotName.png');
  image.writeAsBytesSync(screenshotBytes);
  return true;
}
