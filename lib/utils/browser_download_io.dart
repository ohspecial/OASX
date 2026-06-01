import 'dart:typed_data';

/// No-op browser download helper on non-web platforms.
Future<void> downloadBytesToBrowser(Uint8List bytes, String fileName) async {}
