import 'package:auto_screenshot/src/devices.dart';

void main() async {
  final iosDevices = await getInstalledIOSSimulators();

  print('');
  print('Valid iOS devices:');
  for (var device in iosDevices) {
    print("- ${device.name}");
  }
}
