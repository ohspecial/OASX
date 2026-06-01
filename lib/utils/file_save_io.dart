import 'dart:io';
import 'dart:typed_data';

/// Writes downloaded bytes to a local path on IO platforms.
Future<void> saveBytesToPath(String path, Uint8List bytes) async {
  await File(path).writeAsBytes(bytes);
}
