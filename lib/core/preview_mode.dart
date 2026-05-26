import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreviewMode {
  PreviewMode._();

  static const String _key = 'tlb_device_preview_enabled';
  static final ValueNotifier<bool> enabled = ValueNotifier<bool>(false);

  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      enabled.value = prefs.getBool(_key) ?? false;
    } catch (_) {
      enabled.value = false;
    }
  }

  static Future<void> toggle() async {
    enabled.value = !enabled.value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, enabled.value);
    } catch (_) {}
  }
}
