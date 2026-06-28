import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class VisionImagePayload {
  final Uint8List bytes;
  final String mimeType;

  const VisionImagePayload({required this.bytes, required this.mimeType});
}

/// Downscales large local images before vision API calls to avoid UI jank and payload limits.
class ImageBytesHelper {
  static const _maxEdge = 1280;
  static const _jpegQuality = 82;

  static Future<VisionImagePayload?> loadForVision(String path) async {
    if (!await File(path).exists()) return null;
    return compute(_processImageSync, path);
  }

  static VisionImagePayload? _processImageSync(String path) {
    final file = File(path);
    if (!file.existsSync()) return null;

    final raw = file.readAsBytesSync();
    if (raw.isEmpty) return null;

    try {
      final decoded = img.decodeImage(raw);
      if (decoded == null) {
        return VisionImagePayload(bytes: raw, mimeType: mimeForPath(path));
      }

      final longest = decoded.width > decoded.height ? decoded.width : decoded.height;
      if (longest <= _maxEdge) {
        return VisionImagePayload(bytes: raw, mimeType: mimeForPath(path));
      }

      final scale = _maxEdge / longest;
      final resized = img.copyResize(
        decoded,
        width: (decoded.width * scale).round(),
        height: (decoded.height * scale).round(),
        interpolation: img.Interpolation.linear,
      );

      return VisionImagePayload(
        bytes: Uint8List.fromList(img.encodeJpg(resized, quality: _jpegQuality)),
        mimeType: 'image/jpeg',
      );
    } catch (_) {
      return VisionImagePayload(bytes: raw, mimeType: mimeForPath(path));
    }
  }

  static String mimeForPath(String path) {
    switch (path.split('.').last.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }
}
