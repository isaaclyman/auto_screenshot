import 'package:auto_screenshot/src/android.dart';
import 'package:auto_screenshot/src/config.dart';
import 'package:auto_screenshot/src/exceptions.dart';
import 'package:auto_screenshot/src/ios.dart';

validateConfig(AutoScreenshotConfig config) async {
  await _validateBundleId(config.bundleId);
  await _validateDevices(config.devices);
  await _validateUrls(config);
}

Future<void> _validateBundleId(Map<String, String> bundleId) async {
  final errors = <Exception>[];

  if (!bundleId.containsKey(DeviceTypeString.ios)) {
    errors.add(
      InvalidConfigException(
        "[bundle_id] field is missing [${DeviceTypeString.ios}] key.",
      ),
    );
  }

  if (!bundleId.containsKey(DeviceTypeString.android)) {
    errors.add(
      InvalidConfigException(
        "[bundle_id] field is missing [${DeviceTypeString.android}] key.",
      ),
    );
  }

  if (errors.isNotEmpty) {
    throw AggregateException(errors);
  } else {
    print('✓ bundle_id field is populated.');
  }
}

Future<void> _validateDevices(List<String> deviceNames) async {
  final errors = <Exception>[];

  final validIOSDeviceNames =
      (await getInstalledIOSSimulators()).map((device) => device.name);
  final validAndroidDeviceNames =
      (await getInstalledAndroidEmulators()).map((device) => device.name);
  final listedIOSDeviceNames = <String>[];
  final listedAndroidDeviceNames = <String>[];

  for (var deviceName in deviceNames) {
    final isIOSDevice = validIOSDeviceNames.contains(deviceName);
    final isAndroidDevice = validAndroidDeviceNames.contains(deviceName);

    if (isIOSDevice) {
      listedIOSDeviceNames.add(deviceName);
    } else if (isAndroidDevice) {
      listedAndroidDeviceNames.add(deviceName);
    } else {
      errors.add(InvalidDeviceException(
        "[$deviceName] is not a valid device. To see a list of valid devices, run `dart run auto_screenshot:list_devices`.",
      ));
    }
  }

  if (errors.isNotEmpty) {
    throw AggregateException(errors);
  } else {
    print(
      '✓ All device names are valid (${listedIOSDeviceNames.length} iOS, ${listedAndroidDeviceNames.length} Android).',
    );
  }
}

Future<void> _validateUrls(AutoScreenshotConfig config) async {
  final errors = <Exception>[];

  if (!config.baseUrl.containsKey(DeviceTypeString.ios)) {
    errors.add(
      InvalidConfigException(
        "[base_url] field is missing [${DeviceTypeString.ios}] key.",
      ),
    );
  }

  if (!config.baseUrl.containsKey(DeviceTypeString.android)) {
    errors.add(
      InvalidConfigException(
        "[base_url] field is missing [${DeviceTypeString.android}] key.",
      ),
    );
  }

  if (config.paths.isEmpty) {
    errors.add(
      InvalidConfigException(
        '[screenshot] field is empty.',
      ),
    );
  }

  if (errors.isNotEmpty) {
    throw AggregateException(errors);
  } else {
    print('✓ Required URL configuration fields are present.');
  }
}
