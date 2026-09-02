import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/phone_validation.dart';
import '../core/responsive.dart';
import '../models/api_event_model.dart';
import '../models/event_model.dart';
import 'date_time_selection_screen.dart';
import 'review_pay_screen.dart';

/// Height of every field in the Attendee Details form, and the padding that
/// produces it. The three fields are read as one column, so they share their
/// vertical metrics as well as the horizontal ones on [IndianDialPrefix].
const double _kFieldHeight = 52;
const EdgeInsets _kFieldContentPadding =
    EdgeInsets.only(left: 0, right: 14, top: 15, bottom: 15);

/// Material's InputDecorator inserts a fixed gap between `prefixIcon` and the
/// input that no decoration property exposes. A plain Text beside an icon has
/// no such gap, so the age dropdown and the "+91" — both plain Rows — sit that
/// much further left than a TextField's placeholder. Taking it back out of the
/// icon's own padding lands all three on one column. Measured, not guessed,
/// and pinned by TC_S_TB_ALIGN so a Flutter upgrade that changes it fails
/// loudly rather than drifting.
const double _kDecoratorPrefixGap = 4;

class TicketBookingScreen extends StatefulWidget {
  final EventModel event;
  final String selectedDate;
  final String selectedTime;
  final List<ApiEventTicket>? apiTickets;
  final String bookingType;
  final int? batchId;

  /// The real event window, carried through from DateTimeSelectionScreen so
  /// the pencil "Edit" button below can reopen that exact same screen.
  /// Without these, editing fell back to DateTimeSelectionScreen's dummy-data
  /// path (a fixed 6 fake days from today with placeholder hourly slots)
  /// instead of the real multi-day, real-hours screen the customer had
  /// actually just used.
  final DateTime? eventDateTime;
  final DateTime? eventEndDateTime;

  const TicketBookingScreen({
    super.key,
    required this.event,
    this.selectedDate = 'Saturday, March 21',
    this.selectedTime = '3:00 PM',
    this.apiTickets,
    this.bookingType = 'event',
    this.batchId,
    this.eventDateTime,
    this.eventEndDateTime,
  });

  @override
  State<TicketBookingScreen> createState() => _TicketBookingScreenState();
}

class _TicketBookingScreenState extends State<TicketBookingScreen> {
  late List<Map<String, dynamic>> _tickets;

  // Attendee form controllers
  final _childNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  String? _selectedAge;

  int get _totalTickets =>
      _tickets.fold(0, (sum, t) => sum + (t['count'] as int));

  int get _subtotal {
    int total = 0;
    for (final t in _tickets) {
      total += (t['price'] as int) * (t['count'] as int);
    }
    return total;
  }

  bool get _isFormComplete =>
      _totalTickets > 0 &&
      _childNameController.text.trim().isNotEmpty &&
      _selectedAge != null &&
      // Was only a non-empty check, so a half-typed number could reach payment.
      IndianPhone.isValid(_parentPhoneController.text);

  void _addTicket(int index) {
    setState(() {
      _tickets[index]['count'] = (_tickets[index]['count'] as int) + 1;
    });
  }

  void _initTickets() {
    final api = widget.apiTickets;
    if (api != null && api.isNotEmpty) {
      _tickets = api
          .map((t) => <String, dynamic>{
                'ticketId': t.id,
                'name': t.name,
                'price': t.price.toInt(),
                'count': 0,
                'available': t.availableQuantity,
              })
          .toList();
    } else {
      final base = widget.event.price?.toInt() ?? 360;
      _tickets = [
        {'name': 'Standard', 'price': base, 'count': 0},
        {'name': 'VIP (Special Treat)', 'price': (base * 3).clamp(500, 5000), 'count': 0},
        {'name': 'Early Bird', 'price': (base * 0.8).round(), 'count': 0},
      ];
    }
  }

  // Total available spots across all ticket types (null when no API data)
  int? get _totalAvailableSpots {
    if (_tickets.isEmpty || !_tickets.first.containsKey('available')) return null;
    return _tickets.fold(0, (sum, t) => sum! + (t['available'] as int));
  }

  @override
  void initState() {
    super.initState();
    _initTickets();
    _childNameController.addListener(() => setState(() {}));
    _parentPhoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _childNameController.dispose();
    _parentPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Checkout',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 17),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Event Info Card ──
            _buildEventInfoCard(event),

            const SizedBox(height: 20),

            // ── 2. Select Ticket ──
            _buildSelectTicketSection(),

            const SizedBox(height: 20),

            // ── 3. Bill Details ──
            _buildBillDetailsSection(),

            const SizedBox(height: 20),

            // ── 5. Attendee Details ──
            _buildAttendeeDetailsSection(),

          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isFormComplete ? () {
                final ticketDetailsString = _tickets
                    .where((t) => (t['count'] as int) > 0)
                    .map((t) => '${t['name']} (₹${t['price']}) × ${t['count']}')
                    .join('\n');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReviewPayScreen(
                      event: event,
                      subtotal: _subtotal.toDouble(),
                      selectedDate: widget.selectedDate,
                      selectedTime: widget.selectedTime,
                      ticketDetails: ticketDetailsString,
                      lineItems: _tickets,
                      attendee: {
                        'name': _childNameController.text.trim(),
                        'age': _selectedAge ?? '0',
                        'phone': _parentPhoneController.text.trim(),
                      },
                      bookingType: widget.bookingType,
                      batchId: widget.batchId,
                    ),
                  ),
                );
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.textPrimary,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade500,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                'Proceed to Pay${_subtotal > 0 ? ' • ₹$_subtotal' : ''}',
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

  /// "7 years", but "1 year" — a bare number in the closed field reads as a
  /// quantity rather than an age.
  static String _ageLabel(String age) => age == '1' ? '1 year' : '$age years';

  /// The age field's contents, shared by the placeholder and the selected
  /// value so the row keeps the same shape either way — matching the text
  /// fields around it, whose prefix icon never disappears.
  Widget _ageFieldRow(BuildContext context, String label,
      {bool placeholder = false}) {
    return Row(
      children: [
        // Icon size and gap match the other two fields; at 18 this one sat
        // a couple of pixels off the column they share.
        Icon(Icons.cake_outlined,
            size: IndianDialPrefix.iconSize, color: Colors.grey.shade500),
        const SizedBox(width: IndianDialPrefix.gap),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, placeholder ? 13 : 14),
            color: placeholder ? Colors.grey.shade400 : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _imageFallback(BuildContext context) => Container(
        width: Responsive.w(context, 100, min: 80),
        height: Responsive.h(context, 110, min: 90),
        color: Colors.grey.shade200,
        child: const Icon(Icons.event, size: 30, color: Colors.grey),
      );

  // ────────────────────────────────────────────────────────────
  //  1. Event Info Card — with pencil/edit icon
  // ────────────────────────────────────────────────────────────
  Widget _buildEventInfoCard(EventModel event) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: event.imagePath.startsWith('http')
                ? Image.network(
                    event.imagePath,
                    width: Responsive.w(context, 100, min: 80),
                    height: Responsive.h(context, 110, min: 90),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imageFallback(context),
                  )
                : Image.asset(
                    event.imagePath,
                    width: Responsive.w(context, 100, min: 80),
                    height: Responsive.h(context, 110, min: 90),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imageFallback(context),
                  ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row with pencil icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 15),
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        // Go back to date/time selection. Carrying the real
                        // event window and tickets through — without them
                        // this reopened DateTimeSelectionScreen's dummy-data
                        // fallback (6 fake days from today, placeholder
                        // hourly slots) instead of the real screen the
                        // customer had just used to get here.
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DateTimeSelectionScreen(
                              event: event,
                              apiTickets: widget.apiTickets,
                              eventDateTime: widget.eventDateTime,
                              eventEndDateTime: widget.eventEndDateTime,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: Colors.orange.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${widget.selectedDate}, ${widget.selectedTime}',
                        style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 11), color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event.venue,
                        style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 11), color: Colors.grey.shade600),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (_totalAvailableSpots != null)
                  Text(
                    '$_totalAvailableSpots ${_totalAvailableSpots == 1 ? 'spot' : 'spots'} left',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 12),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFFF6B6B),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  2. Select Ticket
  // ────────────────────────────────────────────────────────────
  Widget _buildSelectTicketSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Ticket',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 16),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(_tickets.length, (index) {
            final ticket = _tickets[index];
            final count = ticket['count'] as int;
            return Column(
              children: [
                if (index > 0)
                  const Divider(height: 24, color: Color(0xFFEEEEEE)),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket['name'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 14),
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${ticket['price']}',
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 13),
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    count == 0
                        ? SizedBox(
                            height: 40,
                            child: OutlinedButton(
                              onPressed: () => _addTicket(index),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade400),
                                minimumSize: const Size(0, 46),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24),
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
                        : Container(
                            height: 36,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  constraints: const BoxConstraints(
                                      minWidth: 32, minHeight: 32),
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.remove,
                                      size: 16, color: AppColors.textPrimary),
                                  onPressed: () {
                                    setState(() {
                                      if (count > 0) {
                                        _tickets[index]['count'] = count - 1;
                                      }
                                    });
                                  },
                                ),
                                Text(
                                  '$count',
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 14),
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                IconButton(
                                  constraints: const BoxConstraints(
                                      minWidth: 32, minHeight: 32),
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.add,
                                      size: 16, color: AppColors.textPrimary),
                                  onPressed: () => _addTicket(index),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  3. Bill Details
  // ────────────────────────────────────────────────────────────
  Widget _buildBillDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bill Details',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 16),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildBillRow(
            'Sub Total (${_totalTickets > 0 ? _totalTickets : 1} x  Ticket)',
            '₹$_subtotal'),
        const SizedBox(height: 8),
        _buildBillRow('Taxes & Fees', '₹0'),
        const Divider(height: 24),
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
              '₹$_subtotal',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 16),
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBillRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade600),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: AppColors.textPrimary),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────
  //  5. Attendee Details — fixed layout
  // ────────────────────────────────────────────────────────────
  Widget _buildAttendeeDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendee Details',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 16),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // Child name
          TextField(
            key: const ValueKey('childNameField'),
            controller: _childNameController,
            style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14)),
            decoration: InputDecoration(
              // Same geometry as the phone field below. Left at Material's
              // default the icon gets a 48x48 box and this placeholder lands
              // several pixels right of the "+91" beneath it.
              prefixIcon: const Padding(
                padding: EdgeInsets.only(
                  left: IndianDialPrefix.inset,
                  right: IndianDialPrefix.gap - _kDecoratorPrefixGap,
                ),
                child: Icon(Icons.person_outline,
                    size: IndianDialPrefix.iconSize, color: Color(0xFF9E9E9E)),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              constraints: const BoxConstraints(minHeight: _kFieldHeight),
              hintText: 'Attendee name',
              hintStyle: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 13), color: Colors.grey.shade400),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: _kFieldContentPadding,
            ),
          ),
          const SizedBox(height: 12),
          // Age dropdown
          Container(
            height: _kFieldHeight,
            padding: const EdgeInsets.only(
                left: IndianDialPrefix.inset, right: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedAge,
                hint: _ageFieldRow(
                  context,
                  'Select age',
                  placeholder: true,
                ),
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down,
                    color: Colors.grey.shade500),
                items: List.generate(18, (i) => '${i + 1}')
                    .map((age) => DropdownMenuItem(
                          value: age,
                          child: Text(age,
                              style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14))),
                        ))
                    .toList(),
                // Without this the closed field renders the raw menu item — a
                // bare number with no icon and no clue it means an age, unlike
                // the two text fields either side of it, which keep their
                // prefix icon whether or not they hold a value.
                selectedItemBuilder: (context) => List.generate(
                  18,
                  (i) => _ageFieldRow(context, _ageLabel('${i + 1}')),
                ),
                onChanged: (value) => setState(() => _selectedAge = value),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Parents contact number
          TextField(
            controller: _parentPhoneController,
            key: const ValueKey('parentPhoneField'),
            keyboardType: TextInputType.phone,
            inputFormatters: IndianPhone.inputFormatters,
            style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14)),
            decoration: InputDecoration(
              // Fixed +91 rather than a picker: this is a local contact number
              // for the organiser, and the app is India-only.
              prefixIcon: const IndianDialPrefix(icon: Icons.phone_outlined),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              errorText: IndianPhone.validate(
                _parentPhoneController.text,
                required: false,
              ),
              hintText: 'Parents contact number',
              hintStyle: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 13), color: Colors.grey.shade400),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              constraints: const BoxConstraints(minHeight: _kFieldHeight),
              contentPadding: _kFieldContentPadding,
            ),
          ),
        ],
      ),
    );
  }
}
