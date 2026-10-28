import 'package:flutter/foundation.dart' show kDebugMode;
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
  /// The code exactly as it was validated — and so exactly as it is sent to
  /// initiate. It used to be upper-cased here, so a code validated as typed
  /// ("save10") went to initiate as "SAVE10"; a case-sensitive lookup there
  /// misses it and the order is created for the full amount.
  String? _appliedCoupon;
  double _discount = 0; // discount amount from validation
  bool _validatingCoupon = false;
  String? _couponError;

  /// Subtotal after any applied coupon discount (never below zero).
  double get _effectiveSubtotal {
    final v = widget.subtotal - _discount;
    return v < 0 ? 0 : v;
  }

  /// What the customer is actually charged.
  ///
  /// This used to add a hard-coded 8.26% "Booking Fee" invented in the app.
  /// The backend knows nothing about it: initiate returns the real amount and
  /// creates the Razorpay order for that, so the screen advertised a total
  /// 8.26% higher than what would be taken — on a 500 ticket, 541.30 shown
  /// against 500.00 charged. Until the API returns a fee, the total is the
  /// subtotal.
  double get _totalAmount => _effectiveSubtotal;

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
        _appliedCoupon = code;
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
      if (kDebugMode) {
        debugPrint('Booking initiated -> amount=${resp.amount} '
            'original=${resp.originalAmount} discount=${resp.discountAmount} '
            'coupon_sent=$_appliedCoupon coupon_applied=${resp.couponApplied} '
            'screen_total=$_totalAmount');
      }

      // A free booking — a free listing, or a coupon covering the whole
      // amount — is confirmed and marked paid by initiate itself: status
      // "confirmed", no Razorpay order, amount 0. There is nothing to pay or
      // verify, so go straight to the confirmation screen. (This used to fall
      // through to the "no order id" guard below and show a payment error for
      // a booking that had in fact succeeded.)
      if (resp.status.toLowerCase() == 'confirmed') {
        if (!mounted) return;
        _openConfirmation(
          bookingReference: resp.bookingReference,
          bookingId: resp.bookingId,
        );
        return;
      }

      // Razorpay charges what the backend's order is for, not what this screen
      // shows. If a coupon was shown as applied but the order came back for
      // more, say so before opening checkout instead of silently charging the
      // undiscounted amount.
      if (_appliedCoupon != null && resp.amount > _totalAmount + 0.5) {
        if (!mounted) return;
        final payAnyway = await showAppConfirmDialog(
          context,
          title: 'Coupon not applied',
          message: "Your coupon couldn't be applied to this booking, so the "
              'payment would be ₹${resp.amount.toStringAsFixed(2)} instead of '
              '₹${_totalAmount.toStringAsFixed(2)}. '
              'Do you want to pay the full amount?',
          confirmLabel: 'Pay ₹${resp.amount.toStringAsFixed(0)}',
          icon: Icons.local_offer_outlined,
        );
        if (!payAnyway || !mounted) return;
      }

      // Razorpay's checkout is a native activity. Handed an empty order id or
      // a zero amount it opens and renders nothing — a black screen with no
      // error, no back affordance and nothing in the Flutter logs. Refuse the
      // handoff instead, so the failure is legible.
      final orderId = resp.razorpayOrderId.trim();
      // round(), not toInt(): the product is a double, so a total like
      // 1234.35 lands on 123434.99999999999 and truncation sends a paise less
      // than the order is for. Razorpay rejects an amount that does not match
      // the order, which surfaces only as its generic "something went wrong".
      final amountPaise = (resp.amount * 100).round();
      if (orderId.isEmpty || amountPaise <= 0) {
        if (kDebugMode) {
          debugPrint('Razorpay handoff refused — '
              'order_id="$orderId" amount=$amountPaise '
              'currency=${resp.currency} status=${resp.status}');
        }
        if (mounted) {
          AppSnackBar.error(
            context,
            "Payment couldn't be started for this booking. "
            'Please try again, or contact support if it keeps happening.',
          );
        }
        return;
      }

      final options = <String, dynamic>{
        'key': AppConfig.razorpayKeyId,
        'order_id': orderId,
        'amount': amountPaise, // Razorpay expects paise
        'currency': resp.currency,
        'name': 'TLB Events',
        'description': resp.bookingReference,
        'prefill': {
          'contact': AuthState.userPhone ?? '',
          'email': AuthState.userEmail ?? '',
        },
        'theme': {'color': '#FFCC00'},
      };

      if (kDebugMode) {
        debugPrint('Razorpay open -> order_id=$orderId amount=$amountPaise '
            'currency=${resp.currency} key=${AppConfig.razorpayKeyId}');
      }
      try {
        _razorpay.open(options);
      } catch (e) {
        // open() throwing leaves nothing on screen — say so.
        if (kDebugMode) debugPrint('Razorpay open() failed: $e');
        if (mounted) {
          AppSnackBar.error(
            context, "Couldn't open the payment screen. Please try again.");
        }
      }
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

      _openConfirmation(
        bookingReference: confirmed.bookingReference,
        bookingId: confirmed.id,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // close loader
      // Payment went through Razorpay but backend verification failed.
      // Show a recoverable error — user can contact support with their ref.
      _showVerificationFailureDialog(_pendingBookingRef ?? bookingId);
    }
  }

  /// The success screen for this booking type. Shared by the paid path (after
  /// verify-payment) and the free path (confirmed directly by initiate).
  void _openConfirmation({
    required String bookingReference,
    required String bookingId,
  }) {
    final Widget screen;
    if (widget.bookingType == 'venue') {
      screen = VenueBookingConfirmedScreen(
        event: widget.event,
        selectedDate: widget.selectedDate,
        selectedTime: widget.selectedTime,
        bookingReference: bookingReference,
        bookingId: bookingId,
      );
    } else if (widget.bookingType == 'program' ||
        widget.bookingType == 'class') {
      screen = ProgramBookingConfirmedScreen(
        event: widget.event,
        selectedDate: widget.selectedDate,
        selectedTime: widget.selectedTime,
        bookingReference: bookingReference,
        bookingType: widget.bookingType,
        bookingId: bookingId,
      );
    } else {
      screen = BookingConfirmedScreen(
        event: widget.event,
        selectedDate: widget.selectedDate,
        selectedTime: widget.selectedTime,
        bookingReference: bookingReference,
        bookingId: bookingId,
      );
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Razorpay's own sheet says only "Something went wrong". The code and the
    // error payload name the real reason — an order/key mismatch, an amount
    // that does not match the order, an expired order — so log them rather
    // than discarding the one diagnostic available.
    if (kDebugMode) {
      debugPrint('Razorpay payment error: code=${response.code} '
          'message=${response.message} error=${response.error}');
    }

    final msg = (response.message?.isNotEmpty == true)
        ? response.message!
        // code 2 is a deliberate cancel; anything else is a real failure.
        : (response.code == 2
            ? 'Payment cancelled.'
            : 'Payment failed. Please try again.');
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
                      _totalAmount <= 0
                          ? 'Confirm Booking'
                          : 'Pay ₹${_totalAmount.toStringAsFixed(2)}',
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
              'Coupon (${_appliedCoupon!.toUpperCase()})',
              '−₹${_discount.toStringAsFixed(0)}',
              valueColor: const Color(0xFF22C55E),
            ),
          ],
          const SizedBox(height: 8),
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
                "'${_appliedCoupon!.toUpperCase()}' applied",
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
