import 'dart:typed_data';

/// No-op writer for platforms where direct file paths are unavailable.
Future<void> saveBytesToPath(String path, Uint8List bytes) async {}
