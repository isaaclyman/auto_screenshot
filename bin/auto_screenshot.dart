import 'package:auto_screenshot/src/commands.dart';
import 'package:auto_screenshot/src/config.dart';

void main() async {
  final config = AutoScreenshotConfig.fromPubspec();
  print(config);
}
