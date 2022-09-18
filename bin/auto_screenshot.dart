import 'package:auto_screenshot/src/android.dart';
import 'package:auto_screenshot/src/commands.dart';
import 'package:auto_screenshot/src/ios.dart';

import 'validate.dart';

void main() async {
  final config = await doValidation();

  print('Running tests...');

  final iOSSims = await getInstalledIOSSimulators();
  final androidSims = await getInstalledAndroidEmulators();
  final allSims = iOSSims.followedBy(androidSims);
  final selectedDevices = config.devices.map(
    (deviceName) => allSims.firstWhere((sim) => sim.name == deviceName),
  );

  for (var device in selectedDevices) {
    print('###');
    print('Booting up [$device]');
    await device.boot();
    print('Installing app on [$device]');
    await device.installApp();
    print('Capturing screens on [$device]');
    await captureScreensOnDevice(config, device);
    print('Sending kill signal to [$device]');
    device.stop();
    print('###');
    print('');
  }

  print('Done.');
}
