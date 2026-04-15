/// Reusable photo picker widget: shows placeholder or preview,
/// bottom sheet with camera/gallery options, delete button.
library;

import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/photo_service.dart';
import '../theme/app_theme.dart';

class PhotoPicker extends StatelessWidget {
  /// Current photo path (null = no photo).
  final String? photoPath;

  /// Called with the new path when user picks a photo,
  /// or with null when user removes the photo.
  final ValueChanged<String?> onChanged;

  /// Height of the picker widget.
  final double height;

  const PhotoPicker({
    super.key,
    required this.photoPath,
    required this.onChanged,
    this.height = 200,
  });

  Future<void> _showPicker(BuildContext context) async {
    final svc = PhotoService.instance;
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(AppLocalizations.of(ctx).photoTakePhoto),
              onTap: () async {
                Navigator.pop(ctx);
                final path = await svc.pickFromCamera();
                if (path != null) {
                  await svc.deletePhoto(photoPath); // delete old
                  onChanged(path);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(AppLocalizations.of(ctx).photoFromGallery),
              onTap: () async {
                Navigator.pop(ctx);
                final path = await svc.pickFromGallery();
                if (path != null) {
                  await svc.deletePhoto(photoPath); // delete old
                  onChanged(path);
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _removePhoto(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dlgCtx) {
        final l10n = AppLocalizations.of(dlgCtx);
        return AlertDialog(
          title: Text(l10n.photoDeleteConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
    if (ok == true) {
      await PhotoService.instance.deletePhoto(photoPath);
      onChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final hasPhoto = photoPath != null && !kIsWeb;
    final file = hasPhoto ? File(photoPath!) : null;

    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.cardBorder,
            width: hasPhoto ? 0 : 1.5,
            style: hasPhoto ? BorderStyle.none : BorderStyle.solid,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo or placeholder
            if (hasPhoto && file != null && file.existsSync())
              Image.file(file, fit: BoxFit.cover)
            else
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 40,
                    color: isDark
                        ? AppColors.darkSubtitle
                        : AppColors.subtitleGray,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).photoAdd,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkSubtitle
                          : AppColors.subtitleGray,
                    ),
                  ),
                ],
              ),

            // Tap overlay (when no photo — show subtle gradient hint)
            if (!hasPhoto)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showPicker(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

            // When photo exists: edit overlay on tap + delete button
            if (hasPhoto) ...[
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showPicker(context),
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black38],
                          stops: [0.5, 1.0],
                        ),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.edit_outlined,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(AppLocalizations.of(context).photoChange,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Delete button top-right
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _removePhoto(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(160),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
