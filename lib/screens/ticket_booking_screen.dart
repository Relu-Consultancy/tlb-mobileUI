import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../models/event_model.dart';
import 'date_time_selection_screen.dart';
import 'payment_screen.dart';

class TicketBookingScreen extends StatefulWidget {
  final EventModel event;
  final String selectedDate;
  final String selectedTime;

  const TicketBookingScreen({
    super.key,
    required this.event,
    this.selectedDate = 'Saturday, March 21',
    this.selectedTime = '3:00 PM',
  });

  @override
  State<TicketBookingScreen> createState() => _TicketBookingScreenState();
}

class _TicketBookingScreenState extends State<TicketBookingScreen> {
  // Ticket data
  final List<Map<String, dynamic>> _tickets = [
    {'name': 'Standard', 'price': 360, 'count': 0},
    {'name': 'VIPs (Special Treat)', 'price': 2000, 'count': 0},
    {'name': 'Weekly combo 1 for 3', 'price': 360, 'count': 0},
  ];

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
      _parentPhoneController.text.trim().isNotEmpty;

  void _addTicket(int index) {
    setState(() {
      _tickets[index]['count'] = (_tickets[index]['count'] as int) + 1;
    });
  }

  @override
  void initState() {
    super.initState();
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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Checkout',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 17),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
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

            // ── 3. Offers ──
            _buildOffersSection(),

            const SizedBox(height: 24),

            // ── 4. Bill Details ──
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentScreen(
                      event: event,
                      amount: _subtotal,
                      selectedDate: widget.selectedDate,
                      selectedTime: widget.selectedTime,
                    ),
                  ),
                );
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFCC00),
                foregroundColor: const Color(0xFF1A1A2E),
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
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

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
            child: Image.asset(
              event.imagePath,
              width: Responsive.w(context, 100, min: 80),
              height: Responsive.h(context, 110, min: 90),
              fit: BoxFit.cover,
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
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        // Go back to date/time selection
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DateTimeSelectionScreen(event: event),
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
                            fontSize: 11, color: Colors.grey.shade600),
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
                            fontSize: 11, color: Colors.grey.shade600),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Only 5 spots left',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
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
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${ticket['price']}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
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
                                minimumSize: const Size(0, 40),
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
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A1A2E),
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
                                      size: 16, color: Color(0xFF1A1A2E)),
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
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1A1A2E),
                                  ),
                                ),
                                IconButton(
                                  constraints: const BoxConstraints(
                                      minWidth: 32, minHeight: 32),
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.add,
                                      size: 16, color: Color(0xFF1A1A2E)),
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
  //  3. Offers
  // ────────────────────────────────────────────────────────────
  Widget _buildOffersSection() {
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
            'Offers',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.local_offer, size: 18, color: Colors.green.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get flat ₹50 off',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      'Save ₹50 with this code',
                      style:
                          GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Text(
                    'Apply',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 13),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {},
            child: Text(
              'View all offers >',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF3B82F6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  4. Bill Details
  // ────────────────────────────────────────────────────────────
  Widget _buildBillDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bill Details',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
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
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            Text(
              '₹$_subtotal',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBillRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
              fontSize: 13, color: const Color(0xFF1A1A2E)),
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
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          // Child name
          TextField(
            controller: _childNameController,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.person_outline,
                  size: 20, color: Colors.grey.shade500),
              hintText: 'Child name',
              hintStyle: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.grey.shade400),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          // Age dropdown
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedAge,
                hint: Row(
                  children: [
                    Icon(Icons.cake_outlined,
                        size: 18, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    Text(
                      'Select age',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.grey.shade400),
                    ),
                  ],
                ),
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down,
                    color: Colors.grey.shade500),
                items: List.generate(18, (i) => '${i + 1}')
                    .map((age) => DropdownMenuItem(
                          value: age,
                          child: Text(age,
                              style: GoogleFonts.poppins(fontSize: 14)),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedAge = value),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Parents contact number
          TextField(
            controller: _parentPhoneController,
            keyboardType: TextInputType.phone,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.phone_outlined,
                  size: 20, color: Colors.grey.shade500),
              hintText: 'Parents contact number',
              hintStyle: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.grey.shade400),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
