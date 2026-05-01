import 'package:shared_preferences/shared_preferences.dart';

class WalkthroughService {
  static const _keyIsNewUser = 'tlb_is_new_user';

  static Future<void> markAsNewUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsNewUser, true);
  }

  static Future<bool> isNewUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsNewUser) ?? false;
  }

  static Future<void> markWalkthroughComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsNewUser, false);
  }
}
