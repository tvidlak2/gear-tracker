/// Handles photo picking, compression, and storage for GearTracker.
library;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PhotoService {
  PhotoService._();
  static final PhotoService instance = PhotoService._();

  final _picker = ImagePicker();

  // ── Pick from camera ──────────────────────────────────────────────────────

  /// Returns the saved file path, or null if cancelled/error.
  Future<String?> pickFromCamera() => _pick(ImageSource.camera);

  /// Returns the saved file path, or null if cancelled/error.
  Future<String?> pickFromGallery() => _pick(ImageSource.gallery);

  Future<String?> _pick(ImageSource source) async {
    if (kIsWeb) return null;
    try {
      final xfile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (xfile == null) return null;
      return await _saveToAppDocs(xfile.path);
    } catch (e) {
      debugPrint('PhotoService._pick error: $e');
      return null;
    }
  }

  // ── Copy to permanent app-docs storage ───────────────────────────────────

  Future<String> _saveToAppDocs(String tempPath) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(docsDir.path, 'photos'));
    if (!photosDir.existsSync()) photosDir.createSync(recursive: true);

    final ext      = p.extension(tempPath).toLowerCase().isNotEmpty
        ? p.extension(tempPath).toLowerCase()
        : '.jpg';
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
    final destPath = p.join(photosDir.path, fileName);

    await File(tempPath).copy(destPath);
    return destPath;
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  /// Deletes the photo file at [path]. Silent on errors.
  Future<void> deletePhoto(String? path) async {
    if (path == null || kIsWeb) return;
    try {
      final file = File(path);
      if (file.existsSync()) await file.delete();
    } catch (e) {
      debugPrint('PhotoService.deletePhoto error: $e');
    }
  }
}
