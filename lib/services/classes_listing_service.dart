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

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      
      // The class categories API returns a plain list or a wrapped list? 
      // Based on docs: Returns categories with nested subcategories. 
      // Wait, doc says: 
      // [ { "id": 1, "name": "Music" ... } ] 
      // But standard API might wrap it like { "success": true, "data": [...] }
      // I'll check both.
      if (body.containsKey('success') && body['success'] == true) {
        return (body['data'] as List)
            .map((e) => ApiCategory.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (body is List) {
        return (body as List)
            .map((e) => ApiCategory.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      
      throw Exception(body['error'] ?? 'Failed to load class categories');
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      // In case it was a raw list at root
      try {
        final rawBody = jsonDecode(e.toString());
        if (rawBody is List) {
          return rawBody.map((e) => ApiCategory.fromJson(e as Map<String, dynamic>)).toList();
        }
      } catch (_) {}
      rethrow;
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

  static Future<void> submitEnquiry({
    required String listingId,
    required String studentName,
    required String mobile,
    String? parentName,
    int? studentAge,
    int? batchId,
    String? message,
    String? area,
  }) async {
    try {
      final url = Uri.parse('$_base/api/v1/listings/classes/$listingId/enquiries/');
      final body = {
        'student_name': studentName,
        'mobile': mobile,
        if (parentName != null && parentName.isNotEmpty) 'parent_name': parentName,
        if (studentAge != null) 'student_age': studentAge,
        if (batchId != null) 'batch_id': batchId,
        if (message != null && message.isNotEmpty) 'message': message,
        if (area != null && area.isNotEmpty) 'area': area,
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
