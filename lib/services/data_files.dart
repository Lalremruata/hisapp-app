import 'dart:convert';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

/// Whether files leave through the share sheet — WhatsApp, Drive, mail — as
/// they do on a phone or tablet, rather than a save dialog.
bool get _sharesFiles =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

/// Sends [text] out of the app as a file called [fileName]: the share sheet on
/// a phone or tablet, a save dialog on a computer, a download in a browser.
///
/// [origin] is where the share sheet points from on an iPad. Returns false
/// when the person backed out.
Future<bool> sendTextFile({
  required String text,
  required String fileName,
  required String mimeType,
  Rect? origin,
}) async {
  final bytes = Uint8List.fromList(utf8.encode(text));

  if (_sharesFiles) {
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, name: fileName, mimeType: mimeType)],
        fileNameOverrides: [fileName],
        sharePositionOrigin: origin,
      ),
    );
    return result.status != ShareResultStatus.dismissed;
  }

  final extension = fileName.split('.').last;
  final path = await FilePicker.saveFile(
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: [extension],
    bytes: bytes,
  );
  // The browser downloads straight away and names no path.
  return kIsWeb || path != null;
}

/// Asks for a backup file and reads it. Null when the person backed out.
Future<String?> pickTextFile() async {
  // Android does not map .json to a type on every device, and would grey the
  // file out; the backup is checked on reading anyway.
  final anyFile = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  final result = await FilePicker.pickFiles(
    type: anyFile ? FileType.any : FileType.custom,
    allowedExtensions: anyFile ? null : const ['json'],
    withData: true,
  );
  final bytes = result?.files.singleOrNull?.bytes;
  if (bytes == null) return null;
  return utf8.decode(bytes, allowMalformed: true);
}
