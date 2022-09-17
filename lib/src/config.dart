import 'dart:convert';
import 'dart:io';

import 'package:auto_screenshot/src/exceptions.dart';
import 'package:json_annotation/json_annotation.dart';
import "package:path/path.dart" as path;
import 'package:checked_yaml/checked_yaml.dart' as yaml;

part 'config.g.dart';

@JsonSerializable(
  anyMap: true,
  checked: true,
  disallowUnrecognizedKeys: true,
)
class AutoScreenshotConfig {
  final List<String> devices;

  @JsonKey(name: 'test_path')
  final String testPath;
  String get joinedTestPath => path.join(testPath);

  @JsonKey(name: 'output_folder')
  final String outputFolder;
  String get joinedOutputFolder => path.join(outputFolder);

  AutoScreenshotConfig({
    required this.devices,
    this.testPath = "integration_test",
    this.outputFolder = "auto_screenshot",
  });

  factory AutoScreenshotConfig.fromJson(Map json) =>
      _$AutoScreenshotConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AutoScreenshotConfigToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  static AutoScreenshotConfig? fromPubspec() {
    try {
      final file = File(pubspecFilePath);
      if (!file.existsSync()) {
        return AutoScreenshotConfig(devices: []);
      }

      final contents = file.readAsStringSync();
      return yaml.checkedYamlDecode<AutoScreenshotConfig?>(
        contents,
        (json) {
          return json == null || json["auto_screenshot"] == null
              ? null
              : AutoScreenshotConfig.fromJson(json["auto_screenshot"]);
        },
        allowNull: true,
      );
    } on yaml.ParsedYamlException catch (e) {
      throw InvalidConfigException(e.formattedMessage);
    } catch (e) {
      rethrow;
    }
  }
}

final pubspecFilePath = path.join("pubspec.yaml");
