import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_category_model.dart';
import '../models/api_class_model.dart';

class ClassesListingService {
  static const _base = 'https://tlb-api.reluconsultancy.in';
  static const _timeout = Duration(seconds: 30);

  // ── Categories ────────────────────────────────────────────────────────────

  static Future<List<ApiCategory>> fetchClassCategories() async {
    try {
      final res = await http
          .get(
            Uri.parse('$_base/api/v1/listings/classes/metadata/categories/'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(_timeout);

      // Decoded as `dynamic` on purpose: this endpoint has been seen both
      // bare (`[ {...} ]`) and wrapped (`{success, data}`), and casting to a
      // Map up front would make the bare case an unreachable branch.
      final dynamic body = jsonDecode(res.body);

      if (body is Map && body['success'] == true) {
        return (body['data'] as List)
            .map((e) => ApiCategory.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (body is List) {
        return body
            .map((e) => ApiCategory.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw Exception(
        (body is Map ? body['error'] : null) ?? 'Failed to load class categories',
      );
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  // ── Classes list ──────────────────────────────────────────────────────────

  static Future<ApiClassesPage> fetchClasses({
    String? category,
    String? subcategory,
    String? city,
    String? area,
    String? format,
    String? mode,
    String? search,
    /// Sent together or not at all. With both present the API sorts by
    /// distance and returns `distance_km` per row; listings with no
    /// coordinates stored are excluded from those results.
    ///
    /// Because of that exclusion this call retries without them when a
    /// geo-sorted request comes back empty — see the note in the body.
    double? lat,
    double? lng,
    int page = 1,
    int pageSize = 10,
  }) async {
    final page1 = await _fetch(
      category: category,
      subcategory: subcategory,
      city: city,
      area: area,
      format: format,
      mode: mode,
      search: search,
      lat: lat,
      lng: lng,
      page: page,
      pageSize: pageSize,
    );
    // A geo-sorted request excludes every class with no coordinates stored,
    // and no partner has set any yet — so sending the user's location would
    // empty the catalogue rather than order it. Ask again without the
    // coordinates so the user sees the classes that exist; they simply come
    // back unsorted, with distance_km null, and the cards omit the distance
    // row. Drop this once class coordinates are populated.
    if (page1.results.isEmpty && lat != null && lng != null) {
      return _fetch(
        category: category,
        subcategory: subcategory,
        city: city,
        area: area,
        format: format,
        mode: mode,
        search: search,
        page: page,
        pageSize: pageSize,
      );
    }
    return page1;
  }

  static Future<ApiClassesPage> _fetch({
    String? category,
    String? subcategory,
    String? city,
    String? area,
    String? format,
    String? mode,
    String? search,
    double? lat,
    double? lng,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final params = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
        if (category != null) 'category': category,
        if (subcategory != null) 'subcategory': subcategory,
        if (city != null) 'city': city,
        if (area != null) 'area': area,
        if (format != null) 'format': format,
        if (mode != null) 'mode': mode,
        if (search != null && search.isNotEmpty) 'search': search,
        // Both or neither — the API answers 400 INVALID_COORDS to a
        // lone or malformed one.
        if (lat != null && lng != null) ...{
          'lat': lat.toString(),
          'lng': lng.toString(),
        },
      };

      final uri = Uri.parse('$_base/api/v1/listings/classes/')
          .replace(queryParameters: params);

      final res = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_timeout);

      if (res.statusCode == 404) {
        return ApiClassesPage(count: 0, page: page, pageSize: pageSize, results: []);
      }

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      
      // Wait, standard paginated list for this one from doc:
      // { "count": 48, "page": 1, ... "results": [...] }
      // But standard API from others is { "success": true, "data": { count... } }
      // The doc says Response data: Standard paginated list { count... results... } 
      // without success wrapper? Let's handle both.
      
      if (body.containsKey('success') && body['success'] == true) {
        return ApiClassesPage.fromJson(body['data'] as Map<String, dynamic>);
      } else if (body.containsKey('results')) {
        return ApiClassesPage.fromJson(body);
      }

      final rawErr = body['error'];
      final errMsg = rawErr is Map
          ? (rawErr['message'] as String? ?? 'Failed to load classes')
          : (rawErr?.toString() ?? 'Failed to load classes');
      throw Exception(errMsg);
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  // ── Class detail ──────────────────────────────────────────────────────────

  static Future<ApiClassDetail> fetchClassDetail(String listingId) async {
    try {
      final res = await http
          .get(
            Uri.parse('$_base/api/v1/listings/classes/$listingId/'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(_timeout);

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      
      if (body.containsKey('success') && body['success'] == true) {
        return ApiClassDetail.fromJson(body['data'] as Map<String, dynamic>);
      } else if (body.containsKey('id') || body.containsKey('listing_type')) {
        return ApiClassDetail.fromJson(body);
      }
      
      if (res.statusCode == 404) throw Exception('Class not found');
      throw Exception(body['error'] ?? 'Failed to load class detail');
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  // ── Enquiry ───────────────────────────────────────────────────────────────

  /// POST /api/v1/listings/classes/{id}/enquiries/
  ///
  /// The endpoint was cut back to a minimal, shared shape: `batch_id`,
  /// `attendee_name`, `student_age`, `mobile`, `message`. The name field was
  /// renamed from `student_name`, and `parent_name` and `area` were removed
  /// from the schema outright — sending them now is not merely ignored, it is
  /// data the customer was asked for and the organiser will never see, so the
  /// form no longer collects them.
  static Future<void> submitEnquiry({
    required String listingId,
    required String attendeeName,
    required String mobile,
    int? studentAge,
    int? batchId,
    String? message,
  }) async {
    try {
      final url = Uri.parse('$_base/api/v1/listings/classes/$listingId/enquiries/');
      final body = {
        'attendee_name': attendeeName,
        'mobile': mobile,
        if (studentAge != null) 'student_age': studentAge,
        // Optional preferred batch. Unchanged by the trim, and still not
        // surfaced in the enquiry sheet — a customer who wants a particular
        // batch says so in the message.
        if (batchId != null) 'batch_id': batchId,
        if (message != null && message.isNotEmpty) 'message': message,
      };

      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(body),
      ).timeout(_timeout);

      final resBody = jsonDecode(res.body) as Map<String, dynamic>;
      
      if (res.statusCode == 201 || (resBody['success'] == true)) {
        return;
      }
      
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
