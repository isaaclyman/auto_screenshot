// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AutoScreenshotConfig _$AutoScreenshotConfigFromJson(Map json) => $checkedCreate(
      'AutoScreenshotConfig',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          allowedKeys: const ['devices', 'test_path', 'output_folder'],
        );
        final val = AutoScreenshotConfig(
          devices: $checkedConvert('devices',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          testPath: $checkedConvert(
              'test_path', (v) => v as String? ?? "integration_test"),
          outputFolder: $checkedConvert(
              'output_folder', (v) => v as String? ?? "auto_screenshot"),
        );
        return val;
      },
      fieldKeyMap: const {
        'testPath': 'test_path',
        'outputFolder': 'output_folder'
      },
    );

Map<String, dynamic> _$AutoScreenshotConfigToJson(
        AutoScreenshotConfig instance) =>
    <String, dynamic>{
      'devices': instance.devices,
      'test_path': instance.testPath,
      'output_folder': instance.outputFolder,
    };
