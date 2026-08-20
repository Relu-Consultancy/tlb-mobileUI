import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/qr_payload.dart';
import '../core/responsive.dart';
import '../providers/auth_state.dart';
import '../services/booking_service.dart';

/// The real scannable QR for a booking.
///
/// Fetched from `GET /bookings/{id}/ticket/data/`, which returns the code as a
/// base64 PNG under `qr_code`. The endpoint only serves confirmed bookings.
///
/// This replaced a `CustomPainter` that drew random cells from a fixed seed —
/// it looked like a QR but encoded nothing, so it would fail at the gate while
/// appearing perfectly valid on screen. When the real code can't be loaded
/// this says so plainly rather than drawing something reassuring and false.
class BookingQr extends StatefulWidget {
  /// The API booking id (uuid). Null for a booking that only exists locally,
  /// in which case there is no code to fetch.
  final String? bookingId;

  final double size;

  const BookingQr({super.key, required this.bookingId, required this.size});

  @override
  State<BookingQr> createState() => _BookingQrState();
}

class _BookingQrState extends State<BookingQr> {
  Uint8List? _qr;
  String? _qrUrl;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(BookingQr oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookingId != widget.bookingId) _load();
  }

  bool get _canFetch =>
      (widget.bookingId?.isNotEmpty ?? false) && AuthState.accessToken != null;

  Future<void> _load() async {
    if (!_canFetch) {
      setState(() {
        _qr = null;
        _qrUrl = null;
        _loading = false;
        _error = 'unavailable';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await BookingService.fetchTicketData(
        token: AuthState.accessToken!,
        bookingId: widget.bookingId!,
      );

      final raw = QrPayload.extract(data);
      if (raw == null) {
        // The request succeeded but carried no QR. Log what it *did* carry —
        // otherwise a renamed field is indistinguishable from a booking that
        // simply isn't confirmed yet.
        debugPrint('BookingQr: ticket data has no QR field. '
            'keys=${data.keys.toList()}');
      }

      if (!mounted) return;

      // Some deployments hand back a URL instead of an inline base64 payload.
      if (raw != null && QrPayload.isUrl(raw)) {
        setState(() {
          _qrUrl = raw;
          _qr = null;
          _loading = false;
          _error = null;
        });
        return;
      }

      final bytes = QrPayload.decode(raw);
      setState(() {
        _qr = bytes;
        _qrUrl = null;
        _loading = false;
        _error = bytes == null ? 'unavailable' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final url = _qrUrl;
    if (url != null) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
        errorBuilder: (_, __, ___) => _placeholder(context),
      );
    }

    final qr = _qr;
    if (qr != null) {
      return Image.memory(
        qr,
        fit: BoxFit.contain,
        // Keep the module edges crisp when the PNG is scaled to the box —
        // a blurred QR is a QR that won't scan.
        filterQuality: FilterQuality.none,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _placeholder(context),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    final retryable = _canFetch;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE7E7EC)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_2_outlined,
                size: 30, color: Colors.grey.shade400),
            const SizedBox(height: 6),
            Text(
              retryable
                  ? (_error != null && _error != 'unavailable'
                      ? "Couldn't load QR"
                      : 'QR not ready yet')
                  : 'QR not available yet',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 11),
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            if (retryable) ...[
              const SizedBox(height: 2),
              GestureDetector(
                onTap: _load,
                child: Text(
                  'Retry',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 11),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0068E7),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A framed "Scan QR Code" card around [BookingQr].
///
/// The events confirmation embeds its QR inside a ticket-stub layout; the
/// program / class confirmation is a plain card stack, so this gives it the
/// same heading and framing without copying the stub chrome. Renders nothing
/// when there is no booking id to fetch against.
class BookingQrCard extends StatelessWidget {
  final String? bookingId;
  final double size;

  const BookingQrCard({super.key, required this.bookingId, this.size = 150});

  @override
  Widget build(BuildContext context) {
    if (bookingId == null || bookingId!.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Scan QR Code',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 15),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Show this at the venue for check-in',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 11.5),
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(10),
            ),
            child: BookingQr(bookingId: bookingId, size: size),
          ),
        ],
      ),
    );
  }
}
