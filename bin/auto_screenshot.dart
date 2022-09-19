import 'package:auto_screenshot/src/android.dart';
import 'package:auto_screenshot/src/commands.dart';
import 'package:auto_screenshot/src/exceptions.dart';
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

  await stopRunningEmulators();

  final errors = <Object>[];
  for (var device in selectedDevices) {
    print('###');

    try {
      print('Booting up [$device]');
      await device.boot();
      print('Installing app on [$device]');
      await device.installApp(config.bundleId);

      if (config.sqliteFolder != null) {
        print('Loading seed data on [$device]');
        await device.loadSeedFiles(config.bundleId, config.sqliteFolder!);
      }

      print('Capturing screens on [$device]');
      await captureScreensOnDevice(config, device);
      print('Sending kill signal to [$device]');
      device.stop();
    } catch (err) {
      errors.add(err);
    }
    print('###');
    print('');
  }

  if (errors.isNotEmpty) {
    print(
      '${errors.length} devices out of ${selectedDevices.length} had problems.',
    );
    print(AggregateException(errors));
  }

  print('Done.');
}
