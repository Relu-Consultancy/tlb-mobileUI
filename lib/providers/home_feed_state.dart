import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../services/home_feed_service.dart';
import '../services/events_listing_service.dart';
import '../services/classes_listing_service.dart';
import '../services/programs_listing_service.dart';

/// Holds the real homepage feed: each section key → ordered list of
/// [EventModel] cards. Section membership comes from
/// GET /api/v1/homepage/sections/; the full card visuals (image, price, city,
/// rating) are hydrated by matching IDs against the list APIs.
///
/// Sections with no listings resolve to an empty list (the section widgets
/// hide themselves). [version] bumps whenever the feed (re)loads so the
/// section widgets — built before the fetch completes — rebuild reactively.
class HomeFeedState {
  HomeFeedState._();

  static final ValueNotifier<int> version = ValueNotifier<int>(0);
  static final Map<String, List<EventModel>> _sections = {};
  static bool _loading = false;
  static bool _loaded = false;

  /// Cards for a section key (e.g. `'hot_picks'`); empty when none.
  static List<EventModel> section(String key) => _sections[key] ?? const [];

  static Future<void> load({bool force = false}) async {
    if (_loading) return;
    if (_loaded && !force) return;
    _loading = true;
    try {
      // Section membership + the four catalogs, in parallel.
      final results = await Future.wait([
        HomeFeedService.fetchSections(),
        EventsListingService.fetchEvents(pageSize: 50)
            .then<dynamic>((p) => p)
            .catchError((_) => null),
        EventsListingService.fetchVenues(pageSize: 50)
            .then<dynamic>((p) => p)
            .catchError((_) => null),
        ClassesListingService.fetchClasses(pageSize: 50)
            .then<dynamic>((p) => p)
            .catchError((_) => null),
        ProgramsListingService.fetchPrograms(pageSize: 50)
            .then<dynamic>((p) => p)
            .catchError((_) => null),
      ]);

      final sections = results[0] as List;
      final eventsPage = results[1];
      final venuesPage = results[2];
      final classesPage = results[3];
      final programsPage = results[4];

      // id → hydrated EventModel, per catalog.
      final byId = <String, EventModel>{};
      if (eventsPage != null) {
        for (final e in eventsPage.results) {
          byId[e.id] = EventModel(
            id: e.id,
            title: e.title,
            venue: e.city,
            imagePath: e.coverUrl ?? '',
            tag: e.subcategory?.name ?? e.category.name,
            price: e.priceFrom != null ? double.tryParse(e.priceFrom!) : null,
            listingType: 'event',
          );
        }
      }
      if (venuesPage != null) {
        for (final v in venuesPage.results) {
          final loc = [v.area, v.city]
              .where((s) => s != null && s!.isNotEmpty)
              .join(', ');
          byId[v.id] = EventModel(
            id: v.id,
            title: v.title,
            venue: loc,
            imagePath: v.cover ?? '',
            tag: v.category.name.isNotEmpty ? v.category.name : null,
            listingType: 'venue',
          );
        }
      }
      if (classesPage != null) {
        for (final c in classesPage.results) {
          byId[c.id] = EventModel(
            id: c.id,
            title: c.title,
            venue: c.category.name,
            imagePath: c.coverUrl ?? '',
            tag: c.category.name,
            rating: c.averageRating,
            reviewCount: '${c.totalReviews} reviews',
            listingType: 'class',
          );
        }
      }
      if (programsPage != null) {
        for (final p in programsPage.results) {
          byId[p.id] = EventModel(
            id: p.id,
            title: p.title,
            venue: p.city ?? p.category?.name ?? '',
            imagePath: p.cover ?? '',
            tag: p.category?.name,
            rating: p.averageRating,
            listingType: 'program',
          );
        }
      }

      // Build each section's card list, preserving the API order. Listings not
      // present in the fetched catalog pages fall back to a minimal card from
      // the homepage data so the section still renders.
      final map = <String, List<EventModel>>{};
      for (final s in sections) {
        final items = <EventModel>[];
        for (final l in s.listings) {
          final hydrated = byId[l.id];
          if (hydrated != null) {
            items.add(hydrated);
          } else {
            items.add(EventModel(
              id: l.id,
              title: l.title,
              venue: l.shortDescription,
              imagePath: '',
              description: l.shortDescription,
              listingType: l.listingType,
            ));
          }
        }
        map[s.section] = items;
      }

      _sections
        ..clear()
        ..addAll(map);
      _loaded = true;
      version.value++;
    } catch (_) {
      // Leave whatever we have; sections that stayed empty just hide.
    } finally {
      _loading = false;
    }
  }
}
