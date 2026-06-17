import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_review_model.dart';
import 'auth_http.dart';

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

  // 7.1 List reviews
  static Future<ApiReviewPage> fetchReviews(
    String listingId, {
    int page = 1,
    int pageSize = 10,
    String ordering = '-created_at',
    int? rating,
  }) async {
    final queryParams = <String, String>{
      'page': '$page',
      'page_size': '$pageSize',
      'ordering': ordering,
      if (rating != null) 'rating': '$rating',
    };
    final uri = Uri.parse('$_base/api/v1/listings/$listingId/reviews/').replace(queryParameters: queryParams);
    final res = await http.get(uri, headers: _publicHeaders()).timeout(_timeout);
    if (res.statusCode == 404) return ApiReviewPage.empty(listingId);
    if (res.statusCode != 200) throw Exception('Failed to load reviews (${res.statusCode})');
    final body = _decodeAny(res.body);
    if (body is Map<String, dynamic> &&
        body['success'] == true &&
        body['data'] is Map<String, dynamic>) {
      return ApiReviewPage.fromJson(body['data'] as Map<String, dynamic>);
    }
    if (body is Map<String, dynamic>) return ApiReviewPage.fromJson(body);
    return ApiReviewPage.empty(listingId);
  }

  // List media attached to a specific review — caller must be the review owner
  static Future<List<ApiReviewMedia>> fetchReviewMedia(String accessToken, int reviewId) async {
    final uri = Uri.parse('$_base/api/v1/reviews/$reviewId/media/');
    final res = await AuthHttp.send((t) => http.get(uri, headers: _authHeaders(t)).timeout(_timeout));
    if (res.statusCode != 200) return [];
    final body = _decodeAny(res.body);
    List? items;
    if (body is List) {
      items = body;
    } else if (body is Map<String, dynamic> && body['data'] is List) {
      items = body['data'] as List;
    }
    return (items ?? [])
        .map((j) => ApiReviewMedia.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  // 7.5 Get my review for a listing
  static Future<ApiReview?> fetchMyReview(String accessToken, String listingId) async {
    final uri = Uri.parse('$_base/api/v1/listings/$listingId/my-review/');
    final res = await AuthHttp.send((t) => http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $t',
    }).timeout(_timeout));
    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) return null;
    final body = _decodeAny(res.body);
    if (body is Map<String, dynamic> && body['success'] == true) {
      final data = body['data'];
      if (data == null) return null;
      return ApiReview.fromJson(data as Map<String, dynamic>);
    }
    if (body is Map<String, dynamic> && body.containsKey('id')) {
      return ApiReview.fromJson(body);
    }
    return null;
  }

  // 7.2 Create review — multipart; images (max 5, ≤5 MB each), videos (max 2, ≤100 MB each)
  static Future<ApiReview> createReview(
    String accessToken,
    String listingId, {
    required int rating,
    String comment = '',
    List<File> images = const [],
    List<File> videos = const [],
  }) async {
    final uri = Uri.parse('$_base/api/v1/listings/$listingId/reviews/');
    final res = await AuthHttp.send((t) async {
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $t'
        ..headers['Accept'] = 'application/json'
        ..fields['rating'] = '$rating'
        ..fields['comment'] = comment;
      for (final img in images) {
        request.files.add(await http.MultipartFile.fromPath('images', img.path));
      }
      for (final vid in videos) {
        request.files.add(await http.MultipartFile.fromPath('videos', vid.path));
      }
      final streamed = await request.send().timeout(_timeout);
      return http.Response.fromStream(streamed);
    });
    final body = _decodeAny(res.body);
    if (res.statusCode == 201 || res.statusCode == 200) {
      if (body is Map<String, dynamic> && body['data'] is Map<String, dynamic>) {
        return ApiReview.fromJson(body['data'] as Map<String, dynamic>);
      }
      if (body is Map<String, dynamic> && body.containsKey('id')) {
        return ApiReview.fromJson(body);
      }
    }
    final errMsg = _extractError(body) ?? 'Failed to submit review (${res.statusCode})';
    throw Exception(errMsg);
  }

  // 7.3 Update review — all fields optional; remove_media_ids[] sent as repeated multipart fields
  static Future<ApiReview> updateReview(
    String accessToken,
    int reviewId, {
    required int rating,
    String comment = '',
    List<File> newImages = const [],
    List<File> newVideos = const [],
    List<int> removeMediaIds = const [],
  }) async {
    final uri = Uri.parse('$_base/api/v1/reviews/$reviewId/');
    final res = await AuthHttp.send((t) async {
      final request = http.MultipartRequest('PATCH', uri)
        ..headers['Authorization'] = 'Bearer $t'
        ..headers['Accept'] = 'application/json'
        ..fields['rating'] = '$rating'
        ..fields['comment'] = comment;
      for (final id in removeMediaIds) {
        // Repeated field — each ID sent as a separate multipart text part
        request.files.add(http.MultipartFile.fromBytes('remove_media_ids[]', utf8.encode('$id')));
      }
      for (final img in newImages) {
        request.files.add(await http.MultipartFile.fromPath('images', img.path));
      }
      for (final vid in newVideos) {
        request.files.add(await http.MultipartFile.fromPath('videos', vid.path));
      }
      final streamed = await request.send().timeout(_timeout);
      return http.Response.fromStream(streamed);
    });
    final body = _decodeAny(res.body);
    if (res.statusCode == 200) {
      if (body is Map<String, dynamic> && body['data'] is Map<String, dynamic>) {
        return ApiReview.fromJson(body['data'] as Map<String, dynamic>);
      }
      if (body is Map<String, dynamic> && body.containsKey('id')) {
        return ApiReview.fromJson(body);
      }
    }
    final errMsg = _extractError(body) ?? 'Failed to update review (${res.statusCode})';
    throw Exception(errMsg);
  }

  // Customer reviews — GET /api/v1/customer/reviews/
  static Future<List<ApiReview>> fetchCustomerReviews(
    String accessToken, {
    int page = 1,
    int pageSize = 50,
    String ordering = 'newest',
  }) async {
    final uri = Uri.parse('$_base/api/v1/customer/reviews/').replace(
      queryParameters: {
        'page': '$page',
        'page_size': '$pageSize',
        'ordering': ordering,
      },
    );
    final res = await AuthHttp.send((t) => http.get(uri, headers: _authHeaders(t)).timeout(_timeout));
    if (res.statusCode == 401) throw Exception('Session expired. Please log in again.');
    if (res.statusCode != 200) throw Exception('Failed to load your reviews (${res.statusCode})');
    final body = _decodeAny(res.body);
    List? items;
    if (body is List) {
      items = body;
    } else if (body is Map<String, dynamic>) {
      final inner = body['data'];
      if (inner is List) {
        items = inner;
      } else if (inner is Map<String, dynamic>) {
        // {"success":true,"data":{"results":[...]}}
        items = inner['results'] as List?;
      } else {
        // {"results":[...]}
        items = body['results'] as List?;
      }
    }
    return (items ?? [])
        .map((j) => ApiReview.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  // 7.4 Delete review
  static Future<void> deleteReview(String accessToken, int reviewId) async {
    final uri = Uri.parse('$_base/api/v1/reviews/$reviewId/');
    final res = await AuthHttp.send((t) => http.delete(uri, headers: _authHeaders(t)).timeout(_timeout));
    if (res.statusCode == 204 || res.statusCode == 200) return;
    final body = _decodeAny(res.body);
    final errMsg = _extractError(body) ?? 'Failed to delete review (${res.statusCode})';
    throw Exception(errMsg);
  }

  // 7.6 Upload media to an existing review
  static Future<ApiReviewMedia> uploadMedia(
    String accessToken,
    int reviewId,
    File image,
  ) async {
    final uri = Uri.parse('$_base/api/v1/reviews/$reviewId/media/');
    final res = await AuthHttp.send((t) async {
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $t'
        ..headers['Accept'] = 'application/json';
      request.files.add(await http.MultipartFile.fromPath('file', image.path));
      final streamed = await request.send().timeout(_timeout);
      return http.Response.fromStream(streamed);
    });
    final body = _decodeAny(res.body);
    if (res.statusCode == 201 || res.statusCode == 200) {
      if (body is Map<String, dynamic> && body['data'] is Map<String, dynamic>) {
        return ApiReviewMedia.fromJson(body['data'] as Map<String, dynamic>);
      }
      if (body is Map<String, dynamic> && body.containsKey('id')) {
        return ApiReviewMedia.fromJson(body);
      }
    }
    final errMsg = _extractError(body) ?? 'Failed to upload media (${res.statusCode})';
    throw Exception(errMsg);
  }

  // 7.7 Delete media from a review
  static Future<void> deleteMedia(String accessToken, int reviewId, int mediaId) async {
    final uri = Uri.parse('$_base/api/v1/reviews/$reviewId/media/$mediaId/');
    final res = await AuthHttp.send((t) => http.delete(uri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $t',
    }).timeout(_timeout));
    if (res.statusCode == 204 || res.statusCode == 200) return;
    final body = _decodeAny(res.body);
    final errMsg = _extractError(body) ?? 'Failed to delete media (${res.statusCode})';
    throw Exception(errMsg);
  }

  /// Safely decodes a JSON body to a Map or List; returns null for a non-JSON
  /// payload (HTML error page, empty body) so callers fall through to their
  /// error path instead of throwing an uncaught FormatException.
  static dynamic _decodeAny(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
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
