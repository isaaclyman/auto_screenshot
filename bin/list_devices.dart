import 'package:auto_screenshot/src/android.dart';
import 'package:auto_screenshot/src/ios.dart';

void main() async {
  final iosDevices = await getInstalledIOSSimulators();

  print('');
  print('Valid iOS devices:');
  for (var device in iosDevices) {
    print("- ${device.name}");
  }

  final androidDevices = await getInstalledAndroidEmulators();

  print('');
  print('Valid Android devices:');
  for (var device in androidDevices) {
    print("- ${device.name}");
  }
}
