import 'package:auto_screenshot/src/commands.dart';
import 'package:auto_screenshot/src/config.dart';
import 'package:auto_screenshot/src/config_validate.dart';
import 'package:auto_screenshot/src/exceptions.dart';

void main() async {
  await doValidation();
}

Future<AutoScreenshotConfig> doValidation() async {
  final config = AutoScreenshotConfig.fromPubspec();

  if (config == null) {
    throw InvalidConfigException("Configuration not found.");
  } else {
    print('✓ Found your auto_screenshot configuration.');
  }

  await assertBinariesAvailable();

  await validateConfig(config);
  print('Configuration passes all checks.');

  return config;
}
