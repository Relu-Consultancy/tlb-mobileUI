import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_search_result_model.dart';
import '../providers/listing_taxonomy_state.dart';

/// The unified keyword search across all four listing types.
///
/// Unlike the per-type browse endpoints' `search` param — a plain substring
/// filter over one type at a time — this endpoint ranks by relevance across
/// title and both descriptions, and is typo-tolerant ("robtics" finds
/// "Weekend Robotics Camp"). That tolerance is the reason results must never
/// be re-filtered client-side against the typed keyword: the winning matches
/// frequently do not contain it.
class SearchService {
  static const _base = 'https://tlb-api.reluconsultancy.in';
  static const _timeout = Duration(seconds: 30);

  /// Searches published listings for [query].
  ///
  /// Pass [type] to narrow to one listing type; omit it to search all four.
  /// No auth — this is a public browse endpoint.
  static Future<ApiSearchPage> search(
    String query, {
    ListingKind? type,
    int page = 1,
    int pageSize = 20,
  }) async {
    // The endpoint answers 400 to a blank `q`, so don't spend a request on it.
    final q = query.trim();
    if (q.isEmpty) {
      return ApiSearchPage(
        count: 0,
        page: page,
        pageSize: pageSize,
        results: const [],
      );
    }

    try {
      final uri = Uri.parse('$_base/api/v1/listings/search/').replace(
        queryParameters: <String, String>{
          'q': q,
          'page': page.toString(),
          'page_size': pageSize.toString(),
          if (type != null) 'listing_type': ApiSearchResult.wireName(type),
        },
      );

      final res = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_timeout);

      // As on every other listing endpoint, a 404 means "nothing matched",
      // not "something broke".
      if (res.statusCode == 404) {
        return ApiSearchPage(
          count: 0,
          page: page,
          pageSize: pageSize,
          results: const [],
        );
      }

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        return ApiSearchPage.fromJson(body['data'] as Map<String, dynamic>);
      }

      final rawErr = body['error'];
      final errMsg = rawErr is Map
          ? (rawErr['message'] as String? ?? 'Search failed')
          : (rawErr?.toString() ?? 'Search failed');
      throw Exception(errMsg);
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }
}
