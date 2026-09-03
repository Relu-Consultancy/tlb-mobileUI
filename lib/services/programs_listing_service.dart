import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/api_category_model.dart';
import '../models/api_program_model.dart';

class ProgramsListingService {
  static const String _base = 'https://tlb-api.reluconsultancy.in';
  static const Duration _timeout = Duration(seconds: 15);

  // ── Metadata ──────────────────────────────────────────────────────────────

  static Future<List<ApiCategory>> fetchProgramCategories() async {
    try {
      final url = Uri.parse('$_base/api/v1/listings/programs/metadata/categories/');
      final res = await http.get(url).timeout(_timeout);

      final dynamic body = jsonDecode(res.body);

      if (res.statusCode == 200) {
        // Handle wrapper vs direct list
        if (body is Map && body.containsKey('success') && body['success'] == true) {
          return (body['data'] as List)
              .map((e) => ApiCategory.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (body is List) {
          return body.map((e) => ApiCategory.fromJson(e as Map<String, dynamic>)).toList();
        }
      }

      throw Exception('Failed to load program categories');
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  static Future<List<ApiProgramTag>> fetchProgramTags() async {
    try {
      final url = Uri.parse('$_base/api/v1/listings/programs/metadata/tags/');
      final res = await http.get(url).timeout(_timeout);
      final dynamic body = jsonDecode(res.body);
      
      if (res.statusCode == 200) {
        if (body is Map && body.containsKey('success') && body['success'] == true) {
          return (body['data'] as List)
              .map((e) => ApiProgramTag.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (body is List) {
          return body.map((e) => ApiProgramTag.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ── Programs Listing ────────────────────────────────────────────────────────

  static Future<ApiProgramsPage> fetchPrograms({
    int page = 1,
    int pageSize = 10,
    String? city,
    int? categoryId,
    String? category, // Sometimes we might only have string from UI
    int? subcategoryId,
    String? subcategory,
    String? programFormat,
    String? deliveryMode,
    int? tagId,
    String? tag,
    int? minAge,
    int? maxAge,
    bool? isFeatured,
    bool? isNewThisWeek,
    bool? isTopRated,
    double? lat,
    double? lng,
    String? search,
  }) async {
    try {
      final params = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
        if (city != null) 'city': city,
        if (categoryId != null) 'category_id': categoryId.toString(),
        if (category != null && categoryId == null) 'category': category, // Fallback
        if (subcategoryId != null) 'subcategory_id': subcategoryId.toString(),
        if (subcategory != null && subcategoryId == null) 'subcategory': subcategory,
        if (programFormat != null) 'program_format': programFormat,
        if (deliveryMode != null) 'delivery_mode': deliveryMode,
        if (tagId != null) 'tag_id': tagId.toString(),
        if (tag != null && tagId == null) 'tag': tag,
        if (minAge != null) 'min_age': minAge.toString(),
        if (maxAge != null) 'max_age': maxAge.toString(),
        if (isFeatured != null) 'is_featured': isFeatured.toString(),
        if (isNewThisWeek != null) 'is_new_this_week': isNewThisWeek.toString(),
        if (isTopRated != null) 'is_top_rated': isTopRated.toString(),
        if (lat != null) 'lat': lat.toString(),
        if (lng != null) 'lng': lng.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final uri = Uri.parse('$_base/api/v1/listings/programs/').replace(queryParameters: params);
      final res = await http.get(uri).timeout(_timeout);

      final body = jsonDecode(res.body) as Map<String, dynamic>;

      if (body.containsKey('success') && body['success'] == true) {
        return ApiProgramsPage.fromJson(body['data'] as Map<String, dynamic>);
      } else if (body.containsKey('results')) {
        return ApiProgramsPage.fromJson(body);
      }

      final rawErr = body['error'];
      final errMsg = rawErr is Map
          ? (rawErr['message'] as String? ?? 'Failed to load programs')
          : (rawErr?.toString() ?? 'Failed to load programs');
      throw Exception(errMsg);
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  // ── Detail ────────────────────────────────────────────────────────────────

  static Future<ApiProgramDetail> fetchProgramDetail(String id) async {
    try {
      final url = Uri.parse('$_base/api/v1/listings/programs/$id/');
      final res = await http.get(url, headers: {'Accept': 'application/json'}).timeout(_timeout);
      
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      
      if (body.containsKey('success') && body['success'] == true) {
        return ApiProgramDetail.fromJson(body['data'] as Map<String, dynamic>);
      } else if (body.containsKey('id')) {
        return ApiProgramDetail.fromJson(body);
      }
      
      if (res.statusCode == 404) throw Exception('Program not found');
      
      final rawErr = body['error'];
      final errMsg = rawErr is Map
          ? (rawErr['message'] as String? ?? 'Failed to load program details')
          : (rawErr?.toString() ?? 'Failed to load program details');
      throw Exception(errMsg);
    } on FormatException {
      throw Exception('Program not found');
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  // ── Enquiry ───────────────────────────────────────────────────────────────

  /// POST /api/v1/listings/programs/{id}/enquire/
  ///
  /// The endpoint was cut back to `attendee_name`, `contact_number`,
  /// `student_age` and `message`. The name field was renamed from
  /// `student_name`; `email` was removed, and with it the old
  /// "contact_number or email, at least one" rule — a phone number is now
  /// simply required. `parent_name`, `batch_id` and `area` are gone too.
  static Future<void> submitEnquiry({
    required String listingId,
    required String attendeeName,
    required String mobile,
    int? studentAge,
    String? message,
  }) async {
    try {
      // Was /enquiries/ (plural) — that route only exists for partners
      // viewing enquiries they've received. The customer-facing route is the
      // singular verb form.
      final url = Uri.parse('$_base/api/v1/listings/programs/$listingId/enquire/');
      final body = {
        'attendee_name': attendeeName,
        // The program schema's contact field is `contact_number`, not
        // `mobile` — that name is only correct for classes and venues.
        // Sending `mobile` here left the field unrecognised, so the number
        // never reached the organiser even once the URL was fixed.
        'contact_number': mobile,
        if (studentAge != null) 'student_age': studentAge,
        'message': message ?? '',
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
