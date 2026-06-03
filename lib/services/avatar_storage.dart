import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's locally-picked profile picture.
///
/// Backend profile API doesn't currently accept avatar uploads, so until it
/// does we copy the picked file into the app's documents directory and
/// remember its path in SharedPreferences. On startup [load] returns that
/// path so the home header / profile screen / account settings can show
/// the same avatar across launches.
class AvatarStorage {
  AvatarStorage._();

  static const String _key = 'tlb_local_avatar_path';
  static const String _filenamePrefix = 'tlb_local_avatar';

  /// Returns the stored absolute path to the local avatar, or null if the
  /// user hasn't picked one (or the file no longer exists on disk).
  static Future<String?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString(_key);
      if (path == null || path.isEmpty) return null;
      // Verify the file still exists — temp-dir paths can get pruned by the
      // OS even though our copy lives in app documents.
      if (!File(path).existsSync()) {
        await prefs.remove(_key);
        return null;
      }
      return path;
    } catch (e) {
      debugPrint('AvatarStorage.load failed: $e');
      return null;
    }
  }

  /// Copies [sourcePath] into the app documents directory and remembers it.
  /// Returns the new absolute path on success.
  ///
  /// Each call writes to a freshly-named file so the resulting path differs
  /// from the previous one. This matters because [AuthState.avatarUrl] is a
  /// ValueNotifier — assigning the same string value never notifies, and the
  /// Flutter `imageCache` keys FileImage entries by path, so re-using one
  /// filename made the new bytes invisible on every screen.
  static Future<String?> saveFromPickedFile(String sourcePath) async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final prefs = await SharedPreferences.getInstance();
      final oldPath = prefs.getString(_key);

      final stamp = DateTime.now().microsecondsSinceEpoch;
      final dest = File('${docs.path}/$_filenamePrefix-$stamp.jpg');
      await File(sourcePath).copy(dest.path);
      await prefs.setString(_key, dest.path);

      // Delete the previous avatar file and evict its cached bytes so a stale
      // copy doesn't linger if the OS recycles the same inode.
      if (oldPath != null && oldPath.isNotEmpty && oldPath != dest.path) {
        try {
          final old = File(oldPath);
          if (old.existsSync()) await old.delete();
          // Best-effort eviction — `imageCache` is in `flutter/painting`.
          PaintingBinding.instance.imageCache.evict(FileImage(old));
        } catch (_) {}
      }
      return dest.path;
    } catch (e) {
      debugPrint('AvatarStorage.saveFromPickedFile failed: $e');
      return null;
    }
  }

  /// Clears both the on-disk copy and the stored path. Called from logout.
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString(_key);
      if (path != null) {
        final f = File(path);
        if (f.existsSync()) await f.delete();
      }
      await prefs.remove(_key);
    } catch (e) {
      debugPrint('AvatarStorage.clear failed: $e');
    }
  }
}
