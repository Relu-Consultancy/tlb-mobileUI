import '../core/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../core/app_snackbar.dart';
import '../core/qr_payload.dart';
import '../providers/auth_state.dart';
import 'booking_service.dart';

/// One-shot: fetch ticket JSON for [bookingId], build a PDF, and open the
/// system share sheet so the user can save / send / print it.
///
/// Shows blocking spinner + error snackbars. Safe to call from any widget.
class TicketPdfService {
  TicketPdfService._();

  static Future<void> downloadAndShare(
    BuildContext context, {
    required String bookingId,
  }) async {
    final token = AuthState.accessToken;
    if (token == null) {
      AppSnackBar.error(context, 'Please log in to download your ticket.');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
          ),
        ),
      ),
    );

    try {
      final ticketData = await BookingService.fetchTicketData(
        token: token,
        bookingId: bookingId,
      );

      final pdfBytes = await _buildPdf(ticketData);

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // close spinner

      final ref = (ticketData['booking_reference'] as String?)?.trim();
      final filename = ref != null && ref.isNotEmpty
          ? 'tlb_ticket_$ref.pdf'
          : 'tlb_ticket.pdf';

      await Printing.sharePdf(bytes: pdfBytes, filename: filename);
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      AppSnackBar.error(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // ── PDF builder ──────────────────────────────────────────────────────────

  static Future<Uint8List> _buildPdf(Map<String, dynamic> data) async {
    final doc = pw.Document();

    final title = _asString(data['listing_title']) ??
        _asString(data['title']) ??
        'Booking Ticket';
    final ref = _asString(data['booking_reference']) ?? '';
    final listing =
        data['listing'] is Map ? data['listing'] as Map<String, dynamic> : null;
    final listingId = _firstNonEmpty([
      _asString(data['listing_id']),
      _asString(listing?['id']),
    ]);
    final bookingType = _asString(data['booking_type'])?.toUpperCase() ?? '';
    final dateLabel = _firstNonEmpty([
      _asString(data['date']),
      _asString(data['start_date']),
      _asString(data['show_date']),
    ]);
    final timeLabel = _firstNonEmpty([
      _asString(data['time']),
      _asString(data['start_time']),
      _asString(data['show_time']),
    ]);
    final venue = _firstNonEmpty([
      _asString(data['venue']),
      _asString(data['location']),
      _asString(data['address']),
    ]);
    final city = _asString(data['city']);
    final customer = data['customer'] is Map
        ? data['customer'] as Map<String, dynamic>
        : null;
    final customerName = _firstNonEmpty([
      _asString(customer?['name']),
      _asString(data['customer_name']),
    ]);
    final customerEmail = _firstNonEmpty([
      _asString(customer?['email']),
      _asString(data['customer_email']),
    ]);
    final lineItems = _parseLineItems(data['line_items']);
    final totalAmount = _firstNonEmpty([
      _asString(data['total_amount']),
      _asString(data['amount']),
    ]);

    // Was data['qr_code'] — the API's field is qr_code_b64, so the PDF
    // shipped without a QR too. Shared with the on-screen ticket.
    final qrBytes = QrPayload.decode(QrPayload.extract(data));
    final coverBytes = await _maybeFetchImage(
      _firstNonEmpty([
        _asString(data['cover_url']),
        _asString(data['listing_cover']),
        _asString(data['cover']),
      ]),
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header band
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFFFCC00),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'TLB Booking Confirmed',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFF1A1A2E),
                      ),
                    ),
                    if (bookingType.isNotEmpty)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 4),
                        child: pw.Text(
                          bookingType,
                          style: pw.TextStyle(
                            fontSize: 11,
                            color: PdfColor.fromInt(0xFF1A1A2E),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              pw.SizedBox(height: 18),

              if (coverBytes != null) ...[
                pw.ClipRRect(
                  horizontalRadius: 10,
                  verticalRadius: 10,
                  child: pw.Image(
                    pw.MemoryImage(coverBytes),
                    fit: pw.BoxFit.cover,
                    height: 180,
                    width: double.infinity,
                  ),
                ),
                pw.SizedBox(height: 16),
              ],

              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 14),

              if (ref.isNotEmpty)
                _row('Booking Reference', ref, mono: true, accent: true),
              if (listingId != null) _row('Listing ID', listingId, mono: true),
              if (dateLabel != null) _row('Date', dateLabel),
              if (timeLabel != null) _row('Time', timeLabel),
              if (venue != null) _row('Venue', venue),
              if (city != null) _row('City', city),
              if (customerName != null) _row('Attendee', customerName),
              if (customerEmail != null) _row('Email', customerEmail),

              if (lineItems.isNotEmpty) ...[
                pw.SizedBox(height: 14),
                pw.Text(
                  'Items',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                ...lineItems.map((item) => pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Row(
                        children: [
                          pw.Expanded(child: pw.Text(item.label)),
                          pw.Text(item.value),
                        ],
                      ),
                    )),
              ],

              if (totalAmount != null) ...[
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFF5F6FA),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Total',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        totalAmount.startsWith('₹') || totalAmount.startsWith('Rs')
                            ? totalAmount
                            : '₹$totalAmount',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],

              pw.Spacer(),

              if (qrBytes != null)
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: PdfColor.fromInt(0xFFDDDDDD)),
                          borderRadius: const pw.BorderRadius.all(
                              pw.Radius.circular(8)),
                        ),
                        child: pw.Image(
                          pw.MemoryImage(qrBytes),
                          width: 140,
                          height: 140,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'Scan this QR at the venue',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColor.fromInt(0xFF6B6B6B),
                        ),
                      ),
                    ],
                  ),
                ),

              pw.SizedBox(height: 14),
              pw.Center(
                child: pw.Text(
                  'thelittlebroadway.com  ·  tickets@thelittlebroadway.com',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColor.fromInt(0xFF9CA3AF),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _row(String label, String value,
      {bool mono = false, bool accent = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 11,
                color: PdfColor.fromInt(0xFF6B6B6B),
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: accent
                    ? PdfColor.fromInt(0xFF3B82F6)
                    : PdfColor.fromInt(0xFF1A1A2E),
                letterSpacing: mono ? 0.6 : 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Parsing helpers ──────────────────────────────────────────────────────

  static String? _asString(Object? v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static String? _firstNonEmpty(Iterable<String?> values) {
    for (final v in values) {
      if (v != null && v.isNotEmpty) return v;
    }
    return null;
  }

  static List<_LineItem> _parseLineItems(Object? raw) {
    if (raw is! List) return const [];
    final out = <_LineItem>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      final label = _firstNonEmpty([
        _asString(entry['title']),
        _asString(entry['name']),
        _asString(entry['ticket_name']),
        _asString(entry['package_name']),
      ]);
      final qty = _asString(entry['quantity']);
      final price = _asString(entry['price']) ?? _asString(entry['amount']);
      if (label == null) continue;
      final qtyLabel = qty != null ? '× $qty' : '';
      final priceLabel = price != null ? '  ₹$price' : '';
      out.add(_LineItem(label: label, value: '$qtyLabel$priceLabel'.trim()));
    }
    return out;
  }

  static Future<Uint8List?> _maybeFetchImage(String? url) async {
    if (url == null || url.isEmpty) return null;
    try {
      final resp = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) return resp.bodyBytes;
    } catch (e) {
      debugPrint('Cover image fetch failed: $e');
    }
    return null;
  }
}

class _LineItem {
  final String label;
  final String value;
  const _LineItem({required this.label, required this.value});
}
