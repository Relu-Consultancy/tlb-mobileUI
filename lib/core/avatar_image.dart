import 'dart:io';
import 'package:flutter/material.dart';

/// Resolves a stored avatar value into the right [ImageProvider].
///
/// - Empty / null → [fallback]
/// - Starts with `http` → [NetworkImage]
/// - Otherwise (an absolute file path from [AvatarStorage]) → [FileImage]
///
/// Use everywhere AuthState.avatarUrl is rendered.
ImageProvider avatarImageProvider(String? value, {required ImageProvider fallback}) {
  if (value == null || value.isEmpty) return fallback;
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return NetworkImage(value);
  }
  final file = File(value);
  if (file.existsSync()) return FileImage(file);
  return fallback;
}
