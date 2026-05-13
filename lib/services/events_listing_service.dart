import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_category_model.dart';
import '../models/api_event_model.dart';
import '../models/api_venue_model.dart';

class EventsListingService {
  static const _base = 'https://tlb-api.reluconsultancy.in';
  static const _timeout = Duration(seconds: 30);

  // ── Categories ────────────────────────────────────────────────────────────

  /// Returns all event categories (and their subcategories) from the server.
  /// Response wrapper: { "success": true, "data": [...], "error": null }
  static Future<List<ApiCategory>> fetchCategories() async {
    try {
      final res = await http
          .get(
            Uri.parse('$_base/api/v1/listings/events/metadata/categories/'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(_timeout);

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        return (body['data'] as List)
            .map((e) => ApiCategory.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception(body['error'] ?? 'Failed to load categories');
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  // ── Events list ───────────────────────────────────────────────────────────

  /// Fetches the published-events listing page.
  /// All filter parameters are optional.
  ///
  /// Response wrapper: { "success": true, "data": { count, page, page_size, results[] } }
  static Future<ApiEventsPage> fetchEvents({
    String? category,
    String? subcategory,
    String? format,
    String? mode,
    String? ageGroup,
    String? city,
    String? area,
    String? datePreset,
    String? priceType,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final params = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
        if (category != null) 'category': category,
        if (subcategory != null) 'subcategory': subcategory,
        if (format != null) 'format': format,
        if (mode != null) 'mode': mode,
        if (ageGroup != null) 'age_group': ageGroup,
        if (city != null) 'city': city,
        if (area != null) 'area': area,
        if (datePreset != null) 'date_preset': datePreset,
        if (priceType != null) 'price_type': priceType,
      };

      final uri = Uri.parse('$_base/api/v1/listings/events/')
          .replace(queryParameters: params);

      final res = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_timeout);

      // 404 on the listing endpoint means no events match the filter — treat as empty
      if (res.statusCode == 404) {
        return ApiEventsPage(count: 0, page: page, pageSize: pageSize, results: []);
      }

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        return ApiEventsPage.fromJson(body['data'] as Map<String, dynamic>);
      }

      // API error may be a nested Map { code, message } or a plain string
      final rawErr = body['error'];
      final errMsg = rawErr is Map
          ? (rawErr['message'] as String? ?? 'Failed to load events')
          : (rawErr?.toString() ?? 'Failed to load events');
      throw Exception(errMsg);
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  // ── Event detail ──────────────────────────────────────────────────────────

  /// Fetches full detail for a single published event.
  /// Response wrapper: { "success": true, "data": { ... } }
  static Future<ApiEventDetail> fetchEventDetail(String listingId) async {
    try {
      final res = await http
          .get(
            Uri.parse('$_base/api/v1/listings/events/$listingId/'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(_timeout);

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        return ApiEventDetail.fromJson(body['data'] as Map<String, dynamic>);
      }
      if (res.statusCode == 404) throw Exception('Event not found');
      throw Exception(body['error'] ?? 'Failed to load event detail');
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  // ── Venue categories ──────────────────────────────────────────────────────

  static Future<List<ApiCategory>> fetchVenueCategories() async {
    try {
      final res = await http
          .get(
            Uri.parse('$_base/api/v1/listings/venues/metadata/categories/'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(_timeout);

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        return (body['data'] as List)
            .map((e) => ApiCategory.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception(body['error'] ?? 'Failed to load venue categories');
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  // ── Venues list ───────────────────────────────────────────────────────────

  static Future<ApiVenuesPage> fetchVenues({
    int? categoryId,
    String? city,
    String? area,
    String? locationType,
    bool? isFeatured,
    bool? isTopRated,
    bool? isNewThisWeek,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final params = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
        if (categoryId != null) 'category_id': categoryId.toString(),
        if (city != null) 'city': city,
        if (area != null) 'area': area,
        if (locationType != null) 'location_type': locationType,
        if (isFeatured == true) 'is_featured': 'true',
        if (isTopRated == true) 'is_top_rated': 'true',
        if (isNewThisWeek == true) 'is_new_this_week': 'true',
      };

      final uri = Uri.parse('$_base/api/v1/listings/venues/')
          .replace(queryParameters: params);

      final res = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_timeout);

      if (res.statusCode == 404) {
        return ApiVenuesPage(count: 0, page: page, pageSize: pageSize, results: []);
      }

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        return ApiVenuesPage.fromJson(body['data'] as Map<String, dynamic>);
      }

      final rawErr = body['error'];
      final errMsg = rawErr is Map
          ? (rawErr['message'] as String? ?? 'Failed to load venues')
          : (rawErr?.toString() ?? 'Failed to load venues');
      throw Exception(errMsg);
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  // ── Venue detail ──────────────────────────────────────────────────────────

  static Future<ApiVenueDetail> fetchVenueDetail(String listingId) async {
    try {
      final res = await http
          .get(
            Uri.parse('$_base/api/v1/listings/venues/$listingId/'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(_timeout);

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        return ApiVenueDetail.fromJson(body['data'] as Map<String, dynamic>);
      }
      if (res.statusCode == 404) throw Exception('Venue not found');
      throw Exception(body['error'] ?? 'Failed to load venue detail');
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }
}
