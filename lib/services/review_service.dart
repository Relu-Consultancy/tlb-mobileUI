import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_review_model.dart';

class ReviewService {
  static const _base = 'https://tlb-api.reluconsultancy.in';
  static const _timeout = Duration(seconds: 15);

  static Map<String, String> _authHeaders(String token) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  static Map<String, String> _publicHeaders() => {
        'Accept': 'application/json',
      };

  static Future<ApiReviewPage> fetchReviews(String listingId, {int page = 1}) async {
    final uri = Uri.parse('$_base/api/v1/listings/$listingId/reviews/?page=$page');
    final res = await http.get(uri, headers: _publicHeaders()).timeout(_timeout);
    if (res.statusCode == 404) return ApiReviewPage.empty(listingId);
    if (res.statusCode != 200) throw Exception('Failed to load reviews (${res.statusCode})');
    final body = jsonDecode(res.body);
    if (body is Map<String, dynamic> && body['success'] == true) {
      return ApiReviewPage.fromJson(body['data'] as Map<String, dynamic>);
    }
    if (body is Map<String, dynamic>) return ApiReviewPage.fromJson(body);
    return ApiReviewPage.empty(listingId);
  }

  static Future<ApiReview> createReview(String accessToken, String listingId, {required int rating, required String comment}) async {
    final uri = Uri.parse('$_base/api/v1/listings/$listingId/reviews/');
    final res = await http.post(
      uri,
      headers: _authHeaders(accessToken),
      body: jsonEncode({'rating': rating, 'comment': comment}),
    ).timeout(_timeout);
    final body = jsonDecode(res.body);
    if (res.statusCode == 201 || res.statusCode == 200) {
      if (body is Map<String, dynamic> && body['success'] == true) {
        return ApiReview.fromJson(body['data'] as Map<String, dynamic>);
      }
      if (body is Map<String, dynamic> && body.containsKey('id')) {
        return ApiReview.fromJson(body);
      }
    }
    final errMsg = _extractError(body) ?? 'Failed to submit review (${res.statusCode})';
    throw Exception(errMsg);
  }

  static Future<ApiReview> updateReview(String accessToken, int reviewId, {required int rating, required String comment}) async {
    final uri = Uri.parse('$_base/api/v1/reviews/$reviewId/');
    final res = await http.patch(
      uri,
      headers: _authHeaders(accessToken),
      body: jsonEncode({'rating': rating, 'comment': comment}),
    ).timeout(_timeout);
    final body = jsonDecode(res.body);
    if (res.statusCode == 200) {
      if (body is Map<String, dynamic> && body['success'] == true) {
        return ApiReview.fromJson(body['data'] as Map<String, dynamic>);
      }
      if (body is Map<String, dynamic> && body.containsKey('id')) {
        return ApiReview.fromJson(body);
      }
    }
    final errMsg = _extractError(body) ?? 'Failed to update review (${res.statusCode})';
    throw Exception(errMsg);
  }

  static Future<void> deleteReview(String accessToken, int reviewId) async {
    final uri = Uri.parse('$_base/api/v1/reviews/$reviewId/');
    final res = await http.delete(uri, headers: _authHeaders(accessToken)).timeout(_timeout);
    if (res.statusCode == 204 || res.statusCode == 200) return;
    final body = jsonDecode(res.body);
    final errMsg = _extractError(body) ?? 'Failed to delete review (${res.statusCode})';
    throw Exception(errMsg);
  }

  static String? _extractError(dynamic body) {
    if (body is Map<String, dynamic>) {
      final err = body['error'];
      if (err is Map) return err['message'] as String?;
      if (body['detail'] is String) return body['detail'] as String;
    }
    return null;
  }
}
