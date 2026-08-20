/// Terms & Conditions attached to a listing.
///
/// The API returns this as a single `terms` object on every listing type
/// (event, class, program, venue):
///
/// ```json
/// "terms": {
///   "content": "User above 12 allowed",
///   "document_url": null,
///   "updated_at": "2026-08-20T09:57:33.252948Z"
/// }
/// ```
///
/// It is `null` when the partner hasn't set any. Classes additionally carry
/// the older `cancellation_policy` / `refund_policy` strings nested under
/// `service`; the other listing types do not have those fields at all.
class ApiListingTerms {
  final String? content;
  final String? documentUrl;
  final DateTime? updatedAt;

  const ApiListingTerms({this.content, this.documentUrl, this.updatedAt});

  /// True when there is something worth opening the sheet for.
  bool get hasContent =>
      (content?.trim().isNotEmpty ?? false) ||
      (documentUrl?.isNotEmpty ?? false);

  /// Reads the `terms` value off a detail payload. Tolerates the field being
  /// absent, explicitly null, or (defensively) a bare string.
  static ApiListingTerms? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) {
      return json.trim().isEmpty ? null : ApiListingTerms(content: json);
    }
    if (json is! Map) return null;
    final terms = ApiListingTerms(
      content: json['content'] as String?,
      documentUrl: json['document_url'] as String?,
      updatedAt: DateTime.tryParse((json['updated_at'] as String?) ?? ''),
    );
    return terms.hasContent ? terms : null;
  }
}
