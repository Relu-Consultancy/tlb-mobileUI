import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../core/app_config.dart';
import '../core/app_snackbar.dart';
import '../core/responsive.dart';
import '../models/api_booking_model.dart';
import '../models/event_model.dart';
import '../providers/auth_state.dart';
import '../services/booking_service.dart';
import '../services/coupon_service.dart';
import '../widgets/app_loader.dart';
import '../widgets/app_dialog.dart';
import 'booking_confirmed_screen.dart';
import 'venue_booking_confirmed_screen.dart';
import 'program_booking_confirmed_screen.dart';

class ReviewPayScreen extends StatefulWidget {
  final EventModel event;
  final String selectedDate;
  final String selectedTime;
  final String ticketDetails;
  final double subtotal;
  final List<Map<String, dynamic>> lineItems;
  final Map<String, dynamic> attendee;
  final String bookingType;
  final int? batchId;
  // Venue-specific
  final int? slotId;
  final int? packageId;
  final int? guestCount;
  final String? specialRequests;

  const ReviewPayScreen({
    super.key,
    required this.event,
    required this.selectedDate,
    required this.selectedTime,
    required this.ticketDetails,
    required this.subtotal,
    required this.lineItems,
    required this.attendee,
    this.bookingType = 'event',
    this.batchId,
    this.slotId,
    this.packageId,
    this.guestCount,
    this.specialRequests,
  });

  @override
  State<ReviewPayScreen> createState() => _ReviewPayScreenState();
}

class _ReviewPayScreenState extends State<ReviewPayScreen> {
  late final Razorpay _razorpay;
  bool _isInitiating = false;
  String? _pendingBookingId;
  String? _pendingBookingRef;

  // ── Coupon state ──
  final TextEditingController _couponCtrl = TextEditingController();
  String? _appliedCoupon; // the validated code, or null
  double _discount = 0; // discount amount from validation
  bool _validatingCoupon = false;
  String? _couponError;

  /// Subtotal after any applied coupon discount (never below zero).
  double get _effectiveSubtotal {
    final v = widget.subtotal - _discount;
    return v < 0 ? 0 : v;
  }

  double get _bookingFee => _effectiveSubtotal * 0.0826;
  double get _totalAmount => _effectiveSubtotal + _bookingFee;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _couponCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  //  Coupon — validate / preview before booking
  // ─────────────────────────────────────────────────────────────
  Future<void> _applyCoupon() async {
    final code = _couponCtrl.text.trim();
    if (code.isEmpty) return;
    final token = AuthState.accessToken;
    if (token == null) {
      AppSnackBar.error(context, 'Please log in to use a coupon.');
      return;
    }
    if (widget.event.id.isEmpty) {
      setState(() => _couponError = 'Coupons are not available for this listing.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _validatingCoupon = true;
      _couponError = null;
    });

    final result = await CouponService.validate(
      token: token,
      couponCode: code,
      listingId: widget.event.id,
      originalAmount: widget.subtotal,
    );
    if (!mounted) return;

    setState(() {
      _validatingCoupon = false;
      if (result.isValid) {
        _appliedCoupon = code.toUpperCase();
        _discount = result.discountAmount;
        _couponError = null;
      } else {
        _appliedCoupon = null;
        _discount = 0;
        _couponError = result.errorMessage ?? 'This coupon could not be applied.';
      }
    });

    if (result.isValid) {
      AppSnackBar.success(
        context,
        'Coupon applied — you saved ₹${result.discountAmount.toStringAsFixed(0)}!',
      );
    }
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _discount = 0;
      _couponError = null;
      _couponCtrl.clear();
    });
  }

  // ─────────────────────────────────────────────────────────────
  //  Step 1 — Initiate booking, then open Razorpay checkout
  // ─────────────────────────────────────────────────────────────
  Future<void> _onProceedToPay() async {
    final token = AuthState.accessToken;
    if (token == null) {
      AppSnackBar.error(context, 'Please log in to continue.');
      return;
    }
    if (widget.event.id.isEmpty) {
      // Safety net — caller should have gated this at the Book Now button.
      // Hitting this path means the user is on a featured-highlight / dummy
      // card that has no API UUID and therefore can't be initiated.
      AppSnackBar.error(
        context,
        "This listing isn't available for booking yet. Browse the catalog to find one you can book.",
      );
      return;
    }

    setState(() => _isInitiating = true);

    try {
      List<BookingLineItem> lineItems = [];
      List<BookingAttendee> attendees = [];
      int? qty;

      if (widget.bookingType == 'event') {
        lineItems = widget.lineItems
            .where((t) =>
                ((t['count'] as num?)?.toInt() ?? 0) > 0 &&
                t.containsKey('ticketId'))
            .map((t) => BookingLineItem(
                  ticketId: (t['ticketId'] as num?)?.toInt() ?? 0,
                  quantity: (t['count'] as num?)?.toInt() ?? 0,
                ))
            .toList();

        final totalQty = widget.lineItems
            .fold<int>(0, (s, t) => s + ((t['count'] as num?)?.toInt() ?? 0));
        final count = totalQty > 0 ? totalQty : 1;
        final att = widget.attendee;
        attendees = List.generate(
          count,
          (_) => BookingAttendee(
            name: (att['name'] as String? ?? '').isNotEmpty
                ? att['name'] as String
                : 'Guest',
            age: int.tryParse(att['age']?.toString() ?? ''),
            phone: att['phone'] as String?,
          ),
        );
      } else if (widget.bookingType == 'class' ||
          widget.bookingType == 'program') {
        final totalQty =
            widget.lineItems.fold<int>(0, (s, t) => s + (t['count'] as int));
        qty = totalQty > 0 ? totalQty : 1;
        final att = widget.attendee;
        if ((att['name'] as String? ?? '').isNotEmpty) {
          attendees = List.generate(
            qty,
            (_) => BookingAttendee(
              name: att['name'] as String,
              age: int.tryParse(att['age']?.toString() ?? ''),
              phone: att['phone'] as String?,
            ),
          );
        }
      }
      // For 'venue': attendees are optional — only send if attendee data provided
      else if (widget.bookingType == 'venue') {
        final att = widget.attendee;
        if ((att['name'] as String? ?? '').isNotEmpty) {
          attendees = [
            BookingAttendee(
              name: att['name'] as String,
              phone: att['phone'] as String?,
            ),
          ];
        }
      }

      final resp = await BookingService.initiateBooking(
        token: token,
        listingId: widget.event.id,
        bookingType: widget.bookingType,
        couponCode: _appliedCoupon,
        lineItems: lineItems,
        attendees: attendees,
        batchId: widget.batchId,
        quantity: qty,
        slotId: widget.slotId,
        packageId: widget.packageId,
        guestCount: widget.guestCount,
        specialRequests: widget.specialRequests,
      );

      _pendingBookingId = resp.bookingId;
      _pendingBookingRef = resp.bookingReference;

      final options = <String, dynamic>{
        'key': AppConfig.razorpayKeyId,
        'order_id': resp.razorpayOrderId,
        'amount': (resp.amount * 100).toInt(), // Razorpay expects paise
        'currency': resp.currency,
        'name': 'TLB Events',
        'description': resp.bookingReference,
        'prefill': {
          'contact': AuthState.userPhone ?? '',
          'email': AuthState.userEmail ?? '',
        },
        'theme': {'color': '#FFCC00'},
      };

      _razorpay.open(options);
    } catch (e) {
      if (mounted) AppSnackBar.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _isInitiating = false);
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  Step 3 — Verify payment with backend after Razorpay success
  // ─────────────────────────────────────────────────────────────
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final bookingId = _pendingBookingId;
    if (bookingId == null) return;

    final token = AuthState.accessToken;
    if (token == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: AppLoader(message: 'Confirming your booking…'),
      ),
    );

    try {
      final confirmed = await BookingService.verifyPayment(
        token: token,
        bookingId: bookingId,
        razorpayPaymentId: response.paymentId ?? '',
        razorpayOrderId: response.orderId ?? '',
        razorpaySignature: response.signature ?? '',
      );

      if (!mounted) return;
      Navigator.pop(context); // close loader

      if (confirmed.status != 'confirmed' ||
          confirmed.paymentStatus != 'paid') {
        _showVerificationFailureDialog(_pendingBookingRef ?? bookingId);
        return;
      }

      if (widget.bookingType == 'venue') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VenueBookingConfirmedScreen(
              event: widget.event,
              selectedDate: widget.selectedDate,
              selectedTime: widget.selectedTime,
              bookingReference: confirmed.bookingReference,
              bookingId: confirmed.id,
            ),
          ),
        );
      } else if (widget.bookingType == 'program' ||
          widget.bookingType == 'class') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProgramBookingConfirmedScreen(
              event: widget.event,
              selectedDate: widget.selectedDate,
              selectedTime: widget.selectedTime,
              bookingReference: confirmed.bookingReference,
              bookingType: widget.bookingType,
              bookingId: confirmed.id,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BookingConfirmedScreen(
              event: widget.event,
              selectedDate: widget.selectedDate,
              selectedTime: widget.selectedTime,
              bookingReference: confirmed.bookingReference,
              bookingId: confirmed.id,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // close loader
      // Payment went through Razorpay but backend verification failed.
      // Show a recoverable error — user can contact support with their ref.
      _showVerificationFailureDialog(_pendingBookingRef ?? bookingId);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    final msg = (response.message?.isNotEmpty == true)
        ? response.message!
        : 'Payment failed. Please try again.';
    AppSnackBar.error(context, msg);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    AppSnackBar.show(context, 'Redirecting to ${response.walletName}…');
  }

  void _showVerificationFailureDialog(String ref) {
    showAppInfoDialog(
      context,
      title: 'Booking Pending',
      message:
          'Your payment was received but we could not confirm the booking automatically.\n\n'
          'Reference: $ref\n\n'
          'Please contact support and share this reference number.',
      icon: Icons.hourglass_bottom_rounded,
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  UI
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Review & Pay',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 16),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please review your booking details',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 14),
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              _buildBookingCard(),
              const SizedBox(height: 16),
              _buildSecurePaymentNote(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isInitiating ? null : _onProceedToPay,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.textPrimary,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: _isInitiating
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: AppLoaderInline(),
                    )
                  : Text(
                      'Pay ₹${_totalAmount.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 16),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            widget.event.title,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 18),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200, thickness: 1),
          const SizedBox(height: 16),

          // Date & Time
          _iconRow(
            Icons.calendar_month_outlined,
            '${widget.selectedDate} • ${widget.selectedTime}',
          ),
          const SizedBox(height: 12),

          // Location
          _iconRow(Icons.location_on_outlined, widget.event.venue),

          const SizedBox(height: 24),

          // Tickets / Batch
          Text(
            (widget.bookingType == 'program' || widget.bookingType == 'class')
                ? 'Batch Details'
                : 'Tickets',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 16),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.ticketDetails,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 14),
              color: AppColors.textPrimary,
            ),
          ),
          // Attendee row (shown for program/class when data is present)
          if ((widget.bookingType == 'program' ||
                  widget.bookingType == 'class') &&
              (widget.attendee['name'] as String? ?? '').isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade200, thickness: 1),
            const SizedBox(height: 16),
            Text(
              'Attendee',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 16),
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _iconRow(
              Icons.person_outline_rounded,
              '${widget.attendee['name']}  •  Age ${widget.attendee['age']}',
            ),
            if ((widget.attendee['phone'] as String? ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              _iconRow(
                Icons.phone_outlined,
                widget.attendee['phone'] as String,
              ),
            ],
          ],

          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200, thickness: 1),
          const SizedBox(height: 16),

          // Coupon
          _buildCouponSection(),

          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200, thickness: 1),
          const SizedBox(height: 16),

          // Price breakdown
          _priceRow('Sub-total', '₹${widget.subtotal.toStringAsFixed(0)}'),
          if (_discount > 0) ...[
            const SizedBox(height: 8),
            _priceRow(
              'Coupon ($_appliedCoupon)',
              '−₹${_discount.toStringAsFixed(0)}',
              valueColor: const Color(0xFF22C55E),
            ),
          ],
          const SizedBox(height: 8),
          _priceRow('Booking Fee', '₹${_bookingFee.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200, thickness: 1),
          const SizedBox(height: 16),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 16),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '₹${_totalAmount.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 16),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFFFB300),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection() {
    if (_appliedCoupon != null) {
      // Applied state — green confirmation chip with a Remove action.
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF22C55E).withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "'$_appliedCoupon' applied",
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 13.5),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            GestureDetector(
              onTap: _removeCoupon,
              child: Text(
                'Remove',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 12.5),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Input state — code field + Apply button.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _couponError != null
                        ? const Color(0xFFEF4444).withOpacity(0.5)
                        : Colors.transparent,
                  ),
                ),
                child: TextField(
                  controller: _couponCtrl,
                  textCapitalization: TextCapitalization.characters,
                  enabled: !_validatingCoupon,
                  onSubmitted: (_) => _applyCoupon(),
                  decoration: InputDecoration(
                    hintText: 'Have a coupon code?',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 13),
                      color: Colors.grey.shade500,
                    ),
                    prefixIcon: Icon(Icons.local_offer_outlined,
                        size: 18, color: Colors.grey.shade600),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 13.5),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _validatingCoupon ? null : _applyCoupon,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: _validatingCoupon
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Apply',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 13.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ],
        ),
        if (_couponError != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.error_outline,
                  size: 14, color: Color(0xFFEF4444)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _couponError!,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 11.5),
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSecurePaymentNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 6),
        Text(
          'Payments powered by Razorpay — 256-bit SSL secured',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 11),
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  Widget _iconRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFC107), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 14),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _priceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 14),
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 14),
            fontWeight: FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
