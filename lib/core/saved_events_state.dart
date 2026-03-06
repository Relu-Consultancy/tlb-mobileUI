import 'package:flutter/material.dart';
import '../models/event_model.dart';
import 'auth_state.dart';
import '../screens/login_sheet.dart';

/// Global saved events state using ValueNotifier
class SavedEventsState {
  static final ValueNotifier<List<EventModel>> savedEvents =
      ValueNotifier<List<EventModel>>([]);

  static bool isSaved(EventModel event) {
    return savedEvents.value.any((e) => e.uniqueId == event.uniqueId);
  }

  /// Toggle saved state. Returns false if login required (popup shown).
  static bool toggle(EventModel event, BuildContext context) {
    if (!AuthState.isLoggedIn.value) {
      showLoginSheet(context);
      return false;
    }
    final list = List<EventModel>.from(savedEvents.value);
    if (isSaved(event)) {
      list.removeWhere((e) => e.uniqueId == event.uniqueId);
    } else {
      list.add(event);
    }
    savedEvents.value = list;
    return true;
  }

  static void remove(EventModel event) {
    final list = List<EventModel>.from(savedEvents.value);
    list.removeWhere((e) => e.uniqueId == event.uniqueId);
    savedEvents.value = list;
  }
}
