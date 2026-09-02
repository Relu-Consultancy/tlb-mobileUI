import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_category_model.dart';
import '../models/api_event_model.dart';
import '../models/api_provider_model.dart';
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
    String? search,
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
        if (search != null && search.isNotEmpty) 'search': search,
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
    int? subcategoryId,
    String? city,
    String? area,
    String? locationType,
    bool? isFeatured,
    bool? isTopRated,
    bool? isNewThisWeek,
    String? search,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final params = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
        if (categoryId != null) 'category_id': categoryId.toString(),
        // Venues filter by integer id, like programs — the name form is
        // ignored (`?subcategory=Soft Play` returns the unfiltered count).
        if (subcategoryId != null) 'subcategory_id': subcategoryId.toString(),
        if (city != null) 'city': city,
        if (area != null) 'area': area,
        if (locationType != null) 'location_type': locationType,
        if (isFeatured == true) 'is_featured': 'true',
        if (isTopRated == true) 'is_top_rated': 'true',
        if (isNewThisWeek == true) 'is_new_this_week': 'true',
        if (search != null && search.isNotEmpty) 'search': search,
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

  // ── Provider ──────────────────────────────────────────────────────────────

  /// Returns the public partner profile for the provider who owns [listingId].
  /// Response may arrive as a direct object or wrapped in `{"success", "data"}`.
  static Future<ApiProvider> fetchProvider(String listingId) async {
    try {
      final res = await http
          .get(
            Uri.parse('$_base/api/v1/listings/$listingId/provider/'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(_timeout);

      if (res.statusCode == 404) throw Exception('Provider not found');

      final body = jsonDecode(res.body);

      // Envelope: { "success": true, "data": {...} }
      if (body is Map<String, dynamic> && body['success'] == true) {
        return ApiProvider.fromJson(body['data'] as Map<String, dynamic>);
      }
      // Direct object (no envelope)
      if (body is Map<String, dynamic> && body.containsKey('id')) {
        return ApiProvider.fromJson(body);
      }

      final rawErr = (body is Map) ? body['error'] : null;
      final errMsg = rawErr is Map
          ? (rawErr['message'] as String? ?? 'Failed to load provider')
          : (rawErr?.toString() ?? 'Failed to load provider');
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

  /// POST /api/v1/listings/venues/{id}/enquiry/ — submit a venue enquiry
  /// (used for enquiry-only venues).
  static Future<void> submitVenueEnquiry({
    required String listingId,
    required String studentName,
    required String mobile,
    String? parentName,
    int? studentAge,
    String? message,
    String? area,
  }) async {
    try {
      // Was /enquiries/ (plural) — that route only exists for partners
      // viewing enquiries they've received. The customer-facing route is
      // singular, and (unlike programs' /enquire/) uses the noun form.
      final url =
          Uri.parse('$_base/api/v1/listings/venues/$listingId/enquiry/');
      final reqBody = {
        // The venue schema's required contact-name field is `name`, not
        // `student_name` — that key only exists on classes/programs, which
        // are enquiring about a child attending. Sending `student_name` left
        // this required field missing entirely, so the request would still
        // have been rejected even once the URL was fixed.
        'name': studentName,
        'mobile': mobile,
        // parent_name, student_age and area are not fields on this endpoint
        // (confirmed against the published schema); left harmless as extras
        // rather than dropped, since the API ignores unknown keys.
        if (parentName != null && parentName.isNotEmpty) 'parent_name': parentName,
        if (studentAge != null) 'student_age': studentAge,
        if (message != null && message.isNotEmpty) 'message': message,
        if (area != null && area.isNotEmpty) 'area': area,
      };

      final res = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(reqBody),
          )
          .timeout(_timeout);

      final resBody = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 201 || resBody['success'] == true) return;

      final rawErr = resBody['error'];
      final errMsg = rawErr is Map
          ? (rawErr['message'] as String? ?? 'Failed to submit enquiry')
          : (rawErr?.toString() ?? 'Failed to submit enquiry');
      throw Exception(errMsg);
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }
}
