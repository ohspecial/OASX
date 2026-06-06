import 'dart:typed_data';

class ConfigImportResult {
  const ConfigImportResult({required this.name, required this.file});

  final String name;
  final String file;

  factory ConfigImportResult.fromJson(Map<String, dynamic> json) {
    return ConfigImportResult(
      name: json['name']?.toString() ?? '',
      file: json['file']?.toString() ?? '',
    );
  }
}

class ConfigExportResult {
  const ConfigExportResult({required this.fileName, required this.bytes});

  final String fileName;
  final Uint8List bytes;
}

class ConfigTransferException implements Exception {
  const ConfigTransferException(this.message, [this.code]);

  final String message;
  final int? code;

  @override
  String toString() => message;
}
