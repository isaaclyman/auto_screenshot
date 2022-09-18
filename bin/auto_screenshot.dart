import 'package:auto_screenshot/src/commands.dart';
import 'package:auto_screenshot/src/devices.dart';

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
    print('Booting up [${device.flutterId}:${device.name}]');
    await device.boot();
    print('Running tests on [${device.flutterId}:${device.name}]');
    await runTestOnDevice(config.testPath, device.flutterId);
    print('Sending kill signal to [${device.flutterId}:${device.name}]');
    device.stop();
    print('###');
    print('');
  }

  print('Done.');
}
