import 'package:shared_preferences/shared_preferences.dart';

/// Persists the set of partner IDs the current user is following.
///
/// Backed by SharedPreferences (keyed per user) so the state survives both
/// screen navigation and full app restarts. The in-memory Set means reads are
/// synchronous — safe to call from widget initState without async/await.
class FollowState {
  FollowState._();

  static final Set<String> _ids = {};
  static String? _prefKey;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Load the persisted follow list for [userId].
  /// Call this after a successful login or session restore.
  static Future<void> loadForUser(String userId) async {
    _prefKey = 'follow_ids_$userId';
    _ids.clear();
    final prefs = await SharedPreferences.getInstance();
    _ids.addAll(prefs.getStringList(_prefKey!) ?? []);
  }

  /// Synchronous — safe to call from initState.
  static bool isFollowing(String partnerId) => _ids.contains(partnerId);

  /// Persist a follow/unfollow action in memory + SharedPreferences.
  static Future<void> set(String partnerId, {required bool following}) async {
    if (following) {
      _ids.add(partnerId);
    } else {
      _ids.remove(partnerId);
    }
    if (_prefKey == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey!, _ids.toList());
  }

  /// Wipe in-memory state on logout so a different user on the same device
  /// starts with a clean slate.
  static void clear() {
    _ids.clear();
    _prefKey = null;
  }
}
