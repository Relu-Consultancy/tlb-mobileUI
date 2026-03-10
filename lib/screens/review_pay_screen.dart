import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/event_model.dart';
import '../core/responsive.dart';
import 'payment_screen.dart';

class ReviewPayScreen extends StatelessWidget {
  final EventModel event;
  final String selectedDate;
  final String selectedTime;
  final String ticketDetails;
  final double subtotal;

  const ReviewPayScreen({
    super.key,
    required this.event,
    required this.selectedDate,
    required this.selectedTime,
    required this.ticketDetails,
    required this.subtotal,
  });

  @override
  Widget build(BuildContext context) {
    // Math logic matching design: booking fee + subtotal
    // The design shows subtotal=399, fee=32.96, total=431.96
    // So fee is roughly 8.26% of subtotal.
    final bookingFee = subtotal * 0.0826;
    final totalAmount = subtotal + bookingFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC107), // Solid yellow header
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Review & Pay',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),

              // Booking details card
              Container(
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
                    // Title & Base Price
                    Text(
                      event.title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹${event.price} per ticket',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.shade200, thickness: 1),
                    const SizedBox(height: 16),

                    // Date & Time
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined, color: Color(0xFFFFC107), size: 20),
                        const SizedBox(width: 12),
                        Text(
                          '$selectedDate • $selectedTime',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Location
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Color(0xFFFFC107), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            event.venue,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    
                    // Tickets Details
                    Text(
                      'Tickets',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ticketDetails,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.shade200, thickness: 1),
                    const SizedBox(height: 16),

                    // Pricing Breakdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sub-total',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        Text(
                          '₹${subtotal.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Booking Fee',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        Text(
                          '₹${bookingFee.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.shade200, thickness: 1),
                    const SizedBox(height: 16),

                    // Total Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        Text(
                          '₹${totalAmount.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFFB300), // Darker yellow for emphasis
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentScreen(
                      event: event,
                      amount: totalAmount.toInt(),
                      selectedDate: selectedDate,
                      selectedTime: selectedTime,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFCC00),
                foregroundColor: const Color(0xFF1A1A2E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: Text(
                'Proceed to Pay',
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
}
