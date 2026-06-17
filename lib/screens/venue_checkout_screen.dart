import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_snackbar.dart';
import '../core/responsive.dart';
import '../models/api_venue_model.dart';
import '../models/event_model.dart';
import 'review_pay_screen.dart';

class VenueCheckoutScreen extends StatefulWidget {
  final EventModel event;
  final ApiVenueDetail? venueDetail;
  final String childName;
  final String occasion;
  final ApiVenueAvailability? selectedSlot; // resolved by PlanPartyScreen
  final int attendeeCount;

  const VenueCheckoutScreen({
    super.key,
    required this.event,
    required this.venueDetail,
    required this.childName,
    required this.occasion,
    required this.selectedSlot,
    required this.attendeeCount,
  });

  @override
  State<VenueCheckoutScreen> createState() => _VenueCheckoutScreenState();
}

class _VenueCheckoutScreenState extends State<VenueCheckoutScreen> {
  late Map<int, int> _packageQty; // package id → selected quantity

  @override
  void initState() {
    super.initState();
    _packageQty = {};
    final pkgs = widget.venueDetail?.packages ?? [];
    if (pkgs.isNotEmpty) {
      _packageQty[pkgs.first.id] = 1; // pre-select first package
    }
  }

  double get _subtotal {
    final pkgs = widget.venueDetail?.packages ?? [];
    double total = 0;
    for (final pkg in pkgs) {
      total += pkg.price * (_packageQty[pkg.id] ?? 0);
    }
    return total;
  }

  double get _taxes => _subtotal * 0.0826;
  double get _total => _subtotal + _taxes;

  int? get _selectedPackageId {
    for (final e in _packageQty.entries) {
      if (e.value > 0) return e.key;
    }
    return null;
  }

String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  // "06:00:00" → "6:00 AM"
  String _fmtTime(String t) {
    try {
      final parts = t.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final period = h >= 12 ? 'PM' : 'AM';
      final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
      return '$hour:${m.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return t;
    }
  }

  String get _displayDateTime {
    final slot = widget.selectedSlot;
    if (slot == null) return widget.occasion;
    return '${_formatDate(slot.date)}, '
        '${_fmtTime(slot.startTime)} – ${_fmtTime(slot.endTime)}';
  }

  void _onContinueToPayment() {
    if (_subtotal <= 0) {
      AppSnackBar.error(context, 'Please select at least one package.');
      return;
    }
    final slot = widget.selectedSlot;
    if (slot == null) {
      AppSnackBar.error(context, 'No time slot selected.');
      return;
    }

    final pkgs = widget.venueDetail?.packages ?? [];
    final selectedPkgs =
        pkgs.where((p) => (_packageQty[p.id] ?? 0) > 0).toList();
    final ticketDetails = selectedPkgs.isEmpty
        ? 'Venue Booking'
        : selectedPkgs.map((p) => '${_packageQty[p.id]}x ${p.name}').join(', ');

    final specialReq =
        '${widget.occasion} for ${widget.childName}. Attendees: ${widget.attendeeCount}.';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewPayScreen(
          event: widget.event,
          selectedDate: _formatDate(slot.date),
          selectedTime:
              '${_fmtTime(slot.startTime)} – ${_fmtTime(slot.endTime)}',
          ticketDetails: ticketDetails,
          subtotal: _subtotal,
          lineItems: const [],
          attendee: const {},
          bookingType: 'venue',
          slotId: slot.id,
          packageId: _selectedPackageId,
          guestCount: widget.attendeeCount,
          specialRequests: specialReq,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coverUrl = widget.venueDetail?.cover ?? widget.event.imagePath;
    final isCoverNetwork =
        coverUrl.isNotEmpty && coverUrl.startsWith('http');
    final packages = widget.venueDetail?.packages ?? [];

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Checkout',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 17),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Event info card ──────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: isCoverNetwork
                            ? Image.network(
                                coverUrl,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildCoverPlaceholder(),
                              )
                            : coverUrl.isNotEmpty
                                ? Image.asset(
                                    coverUrl,
                                    height: 160,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _buildCoverPlaceholder(),
                                  )
                                : _buildCoverPlaceholder(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.event.title,
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 15),
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _infoRow(
                              Icons.calendar_today_outlined,
                              _displayDateTime,
                            ),
                            const SizedBox(height: 4),
                            _infoRow(
                              Icons.location_on_outlined,
                              widget.event.venue,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF9E6),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.primaryLight,
                                ),
                              ),
                              child: Text(
                                '${widget.attendeeCount} Attendees • ${widget.occasion}',
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 11),
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF8B6A00),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Select Packages ──────────────────────────────────────────
                if (packages.isNotEmpty) ...[
                  Text(
                    'Select Packages',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 15),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...packages.map(
                    (pkg) => _PackageItem(
                      pkg: pkg,
                      qty: _packageQty[pkg.id] ?? 0,
                      onIncrement: () => setState(() {
                        _packageQty[pkg.id] =
                            (_packageQty[pkg.id] ?? 0) + 1;
                      }),
                      onDecrement: () => setState(() {
                        final cur = _packageQty[pkg.id] ?? 0;
                        if (cur > 0) _packageQty[pkg.id] = cur - 1;
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Bill Details ─────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bill Details',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 15),
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _billRow(
                        'Sub Total',
                        '₹${_subtotal.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 8),
                      _billRow(
                        'Taxes & Fees (8.26%)',
                        _subtotal > 0
                            ? '₹${_taxes.toStringAsFixed(2)}'
                            : '—',
                        valueColor: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 12),
                      Divider(color: Colors.grey.shade200, thickness: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total to be paid',
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 14),
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '₹${_total.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 15),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFFFB300),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),

          // ── Sticky bottom CTA ────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _onContinueToPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Pay ₹${_total.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 15),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 1,
                        height: 18,
                        color: AppColors.textPrimary.withOpacity(0.3),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Continue to payment',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 13),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverPlaceholder() => Container(
        height: 160,
        width: double.infinity,
        color: const Color(0xFFE8E8E8),
        child: const Center(
          child: Icon(Icons.place, size: 48, color: Color(0xFFBBBBBB)),
        ),
      );

  Widget _infoRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 12),
                color: Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );

  Widget _billRow(
    String label,
    String value, {
    Color? valueColor,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 13),
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 13),
              fontWeight: FontWeight.w500,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      );

}

// ── Package Item ─────────────────────────────────────────────────────────────

class _PackageItem extends StatelessWidget {
  final ApiVenuePackage pkg;
  final int qty;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _PackageItem({
    required this.pkg,
    required this.qty,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: qty > 0
            ? Border.all(color: AppColors.primaryLight, width: 1.5)
            : Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pkg.name,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 13.5),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (pkg.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 3),
                  Text(
                    pkg.description!,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 11),
                      color: Colors.grey.shade500,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (pkg.durationMinutes != null || pkg.maxGuests != null) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      if (pkg.durationMinutes != null) ...[
                        Icon(Icons.timer_outlined,
                            size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 3),
                        Text(
                          '${pkg.durationMinutes} min',
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 10.5),
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      if (pkg.maxGuests != null) ...[
                        Icon(Icons.people_outline,
                            size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 3),
                        Text(
                          'Up to ${pkg.maxGuests} guests',
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 10.5),
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  '₹${pkg.price.toInt()}',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 14),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (qty == 0)
            GestureDetector(
              onTap: onIncrement,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Add',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 13),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                _QtyButton(icon: Icons.remove, onTap: onDecrement),
                SizedBox(
                  width: 32,
                  child: Text(
                    '$qty',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _QtyButton(icon: Icons.add, onTap: onIncrement),
              ],
            ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: AppColors.textPrimary,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}
