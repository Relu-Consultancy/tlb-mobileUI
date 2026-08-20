import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../models/api_booking_model.dart';
import '../models/api_refund.dart';
import '../providers/auth_state.dart';
import '../services/booking_service.dart';
import '../widgets/app_refresh_indicator.dart';
import 'help_centre_screen.dart';

/// Tracks the real status of money coming back after a booking is cancelled.
///
/// The lifecycle is `requested → processing → settled`, with `failed` branching
/// off. Only `settled` means the customer actually has their money — refunds
/// are asynchronous at the payment provider and `processing` can last days, so
/// nothing here says "Refunded" before then.
class RefundTrackingScreen extends StatefulWidget {
  final ApiBookingItem booking;

  const RefundTrackingScreen({super.key, required this.booking});

  @override
  State<RefundTrackingScreen> createState() => _RefundTrackingScreenState();
}

class _RefundTrackingScreenState extends State<RefundTrackingScreen> {
  late ApiBookingItem _booking;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
  }

  ApiRefund? get _refund => _booking.refund;

  /// Re-reads the booking so an in-flight refund can advance while the
  /// customer is looking at it. Failures leave the current data on screen —
  /// stale status beats an error page over data we already have.
  Future<void> _refresh() async {
    final token = AuthState.accessToken;
    if (token == null || _refreshing) return;
    setState(() => _refreshing = true);
    try {
      final fresh = await BookingService.getBookingDetail(
        token: token,
        bookingId: _booking.id,
      );
      if (!mounted) return;
      setState(() => _booking = fresh);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Couldn't refresh just now. Showing the last known status.",
            style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13)),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.lightGray,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context, _booking),
        ),
        title: Text(
          'Refund Status',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 18),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: AppRefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [
            if (_refund == null)
              _NoRefundCard(booking: _booking)
            else ...[
              _AmountCard(booking: _booking, refund: _refund!),
              const SizedBox(height: 16),
              _StatusBanner(refund: _refund!),
              const SizedBox(height: 16),
              _RefundTimeline(refund: _refund!),
              const SizedBox(height: 16),
              _FootNote(refund: _refund!),
              if (_refund!.status.isFailed) ...[
                const SizedBox(height: 16),
                _HelpCta(booking: _booking),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ── Presentation helpers ─────────────────────────────────────────────────────

/// Colour, label and explanation for each status, kept in one place so the
/// banner, the timeline and the entry row can't drift apart.
class _StatusStyle {
  final Color color;
  final Color soft;
  final IconData icon;
  final String label;
  final String detail;

  const _StatusStyle(
      this.color, this.soft, this.icon, this.label, this.detail);

  static _StatusStyle of(RefundStatus status) {
    switch (status) {
      case RefundStatus.settled:
        return const _StatusStyle(
          Color(0xFF16A34A),
          Color(0xFFE8F6EC),
          Icons.check_circle,
          'Refund complete',
          'The money is back with you. If your statement still looks short, '
              'check with your bank — some take a day to display it.',
        );
      case RefundStatus.failed:
        return const _StatusStyle(
          Color(0xFFDC2626),
          Color(0xFFFDECEC),
          Icons.error_outline,
          'Refund failed',
          "The refund couldn't be completed. Our team needs to look into "
              'this — please raise a request and we\'ll sort it out.',
        );
      case RefundStatus.requested:
        return const _StatusStyle(
          Color(0xFF2563EB),
          Color(0xFFE8F0FE),
          Icons.schedule,
          'Refund requested',
          "We're sending your refund to the bank now. This usually moves on "
              'within a few minutes.',
        );
      case RefundStatus.processing:
      case RefundStatus.unknown:
        return const _StatusStyle(
          Color(0xFF2563EB),
          Color(0xFFE8F0FE),
          Icons.sync,
          'Refund in progress',
          'Your bank is processing the refund. This usually takes 3–7 days '
              'depending on your payment method.',
        );
    }
  }
}

String _money(double? amount, String currency) {
  if (amount == null) return '—';
  final symbol = currency.toUpperCase() == 'INR' ? '₹' : '$currency ';
  return '$symbol${amount.toStringAsFixed(2)}';
}

String _formatDate(DateTime? d) {
  if (d == null) return '';
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final local = d.toLocal();
  final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final meridiem = local.hour < 12 ? 'AM' : 'PM';
  return '${local.day} ${months[local.month - 1]} ${local.year}, '
      '$hour12:$minute $meridiem';
}

BoxDecoration _cardDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.7),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );

// ── Cards ────────────────────────────────────────────────────────────────────

/// Shown when the booking carries no refund at all — cancelled before payment,
/// or still active.
class _NoRefundCard extends StatelessWidget {
  final ApiBookingItem booking;

  const _NoRefundCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 44, color: Colors.grey.shade400),
          const SizedBox(height: 14),
          Text(
            'No refund on this booking',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 16),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Nothing has been sent back for ${booking.bookingReference}. '
            'This happens when a booking is cancelled before payment, or '
            'is still active.',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 13),
              color: Colors.grey.shade700,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// The headline figure plus what it belongs to.
class _AmountCard extends StatelessWidget {
  final ApiBookingItem booking;
  final ApiRefund refund;

  const _AmountCard({required this.booking, required this.refund});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Refund amount',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 12),
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _money(refund.amount ?? booking.refundAmount, refund.currency),
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 30),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _KeyValue(label: 'Booking', value: booking.listingTitle),
          const SizedBox(height: 8),
          _KeyValue(label: 'Reference', value: booking.bookingReference),
        ],
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  final String label;
  final String value;

  const _KeyValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 84,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 12.5),
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 12.5),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// The current state, stated plainly.
class _StatusBanner extends StatelessWidget {
  final ApiRefund refund;

  const _StatusBanner({required this.refund});

  @override
  Widget build(BuildContext context) {
    final s = _StatusStyle.of(refund.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: s.soft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: s.color.withOpacity(0.25), width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(s.icon, color: s.color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.label,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 15),
                    fontWeight: FontWeight.w600,
                    color: s.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.detail,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 12.5),
                    color: Colors.grey.shade800,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The lifecycle as steps. A failed refund replaces the settled step rather
/// than appending to it — the money never arrived, so showing a pending
/// "Completed" step underneath would misrepresent what happened.
class _RefundTimeline extends StatelessWidget {
  final ApiRefund refund;

  const _RefundTimeline({required this.refund});

  @override
  Widget build(BuildContext context) {
    final status = refund.status;
    final failed = status.isFailed;

    final steps = <_Step>[
      _Step(
        title: 'Refund requested',
        subtitle: 'We sent the refund to your bank',
        at: refund.requestedAt,
        // A refund object exists at all only once it has been requested.
        done: true,
      ),
      _Step(
        title: 'Processing',
        subtitle: 'Your bank is moving the money',
        at: null,
        done: !failed,
        // Where the wait actually happens.
        active: status == RefundStatus.processing ||
            status == RefundStatus.unknown,
      ),
      if (failed)
        _Step(
          // Deliberately not "Refund failed" — the banner above already says
          // that, and repeating it reads as two separate failures.
          title: 'Could not complete',
          subtitle: 'Needs a manual follow-up from our team',
          at: refund.failedAt,
          done: true,
          isError: true,
        )
      else
        _Step(
          title: 'Money returned',
          subtitle: status.isSettled
              ? 'Completed'
              : 'Usually 3–7 days after the request',
          at: refund.settledAt,
          done: status.isSettled,
        ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 15),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < steps.length; i++)
            _TimelineRow(
              step: steps[i],
              isLast: i == steps.length - 1,
            ),
        ],
      ),
    );
  }
}

class _Step {
  final String title;
  final String subtitle;
  final DateTime? at;
  final bool done;
  final bool active;
  final bool isError;

  const _Step({
    required this.title,
    required this.subtitle,
    required this.at,
    required this.done,
    this.active = false,
    this.isError = false,
  });
}

class _TimelineRow extends StatelessWidget {
  final _Step step;
  final bool isLast;

  const _TimelineRow({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    const pending = Color(0xFFCBD5E1);
    final Color color = step.isError
        ? const Color(0xFFDC2626)
        : step.active
            ? const Color(0xFF2563EB)
            : step.done
                ? const Color(0xFF16A34A)
                : pending;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rail: marker plus the connector down to the next step.
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: step.done || step.active ? color : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: step.done && !step.isError
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : step.isError
                        ? const Icon(Icons.priority_high,
                            size: 12, color: Colors.white)
                        : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: step.done && !step.isError ? color : pending,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 12 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 14),
                      fontWeight: FontWeight.w600,
                      color: step.done || step.active
                          ? AppColors.textPrimary
                          : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 12),
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  if (step.at != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      _formatDate(step.at),
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 11.5),
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sets expectations for an in-flight refund; states the settled date once
/// there is one.
class _FootNote extends StatelessWidget {
  final ApiRefund refund;

  const _FootNote({required this.refund});

  @override
  Widget build(BuildContext context) {
    final text = refund.status.isSettled
        ? 'Settled on ${_formatDate(refund.settledAt)}.'
        : refund.status.isFailed
            ? 'Reported failed on ${_formatDate(refund.failedAt)}.'
            : 'Refunds are processed by your bank, so the exact date is out '
                'of our hands. Pull down to check for an update.';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 15, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 12),
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// Only shown on failure — a failed refund needs a human.
class _HelpCta extends StatelessWidget {
  final ApiBookingItem booking;

  const _HelpCta({required this.booking});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HelpCentreScreen()),
        ),
        icon: const Icon(Icons.support_agent, size: 20),
        label: Text(
          'Get help with this refund',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 14),
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// Entry point used on the booking detail screen — a compact row showing the
/// live status that opens the full tracker.
class RefundStatusRow extends StatelessWidget {
  final ApiBookingItem booking;
  final VoidCallback? onReturned;

  const RefundStatusRow({
    super.key,
    required this.booking,
    this.onReturned,
  });

  @override
  Widget build(BuildContext context) {
    final refund = booking.refund;
    if (refund == null) return const SizedBox.shrink();
    final s = _StatusStyle.of(refund.status);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RefundTrackingScreen(booking: booking),
          ),
        );
        onReturned?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: s.soft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: s.color.withOpacity(0.25), width: 0.8),
        ),
        child: Row(
          children: [
            Icon(s.icon, color: s.color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.label,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 14),
                      fontWeight: FontWeight.w600,
                      color: s.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _money(refund.amount ?? booking.refundAmount,
                        refund.currency),
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 12.5),
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: s.color.withOpacity(0.8)),
          ],
        ),
      ),
    );
  }
}
