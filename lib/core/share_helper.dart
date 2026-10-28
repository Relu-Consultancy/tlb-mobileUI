import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../services/activity_service.dart';

/// Frontend-side share — opens the OS share sheet (WhatsApp, Email, Copy
/// link, AirDrop, etc.) with a short, friendly blurb about a listing.
///
/// We don't currently have a backend "shareable URL" endpoint, so the link
/// is composed from a guessed web pattern. When the marketing site exposes
/// a stable URL scheme, only this helper needs to change — every screen
/// already goes through it.
class ShareHelper {
  ShareHelper._();

  static const _webBase = 'https://thelittlebroadway.com';

  /// [type] — `event`, `class`, `program`, `venue`, or `partner`.
  /// [title] — listing title, used in the share text.
  /// [id]    — UUID of the listing; appended to the URL when available.
  /// [origin] — the Offset (in screen coordinates) of the share button —
  ///           used on iPad to position the share popover. Optional.
  static Future<void> shareListing(
    BuildContext context, {
    required String type,
    required String title,
    String? id,
    Rect? sharePositionOrigin,
  }) async {
    final url = (id != null && id.isNotEmpty)
        ? '$_webBase/${_path(type)}/$id'
        : _webBase;

    final body = StringBuffer()
      ..writeln('Check out "$title" on The Little Broadway')
      ..writeln()
      ..writeln(url)
      ..writeln()
      ..writeln('Discover kids\' classes, programs, events & venues on TLB.');

    // Every share button in the app comes through here, so this is the one
    // place it is reported. Fire-and-forget; never delays the sheet.
    ActivityService.trackShare(type: type, id: id);

    await Share.share(
      body.toString(),
      subject: title,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  static String _path(String type) {
    switch (type) {
      case 'event':
        return 'events';
      case 'class':
        return 'classes';
      case 'program':
        return 'programs';
      case 'venue':
        return 'venues';
      case 'partner':
        return 'partners';
      default:
        return type;
    }
  }
}
