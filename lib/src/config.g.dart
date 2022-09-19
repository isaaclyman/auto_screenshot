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
          allowedKeys: const [
            'bundle_id',
            'devices',
            'base_url',
            'screenshot',
            'output_folder',
            'sqlite_folder'
          ],
        );
        final val = AutoScreenshotConfig(
          devices: $checkedConvert('devices',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          baseUrl: $checkedConvert(
              'base_url', (v) => Map<String, String>.from(v as Map)),
          paths: $checkedConvert('screenshot',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          outputFolder: $checkedConvert(
              'output_folder', (v) => v as String? ?? "auto_screenshot"),
          bundleId: $checkedConvert(
              'bundle_id', (v) => Map<String, String>.from(v as Map)),
          sqliteFolder: $checkedConvert('sqlite_folder', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'baseUrl': 'base_url',
        'paths': 'screenshot',
        'outputFolder': 'output_folder',
        'bundleId': 'bundle_id',
        'sqliteFolder': 'sqlite_folder'
      },
    );

Map<String, dynamic> _$AutoScreenshotConfigToJson(
        AutoScreenshotConfig instance) =>
    <String, dynamic>{
      'bundle_id': instance.bundleId,
      'devices': instance.devices,
      'base_url': instance.baseUrl,
      'screenshot': instance.paths,
      'output_folder': instance.outputFolder,
      'sqlite_folder': instance.sqliteFolder,
    };
