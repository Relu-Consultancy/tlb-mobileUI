import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../core/booked_events_state.dart';
import 'booking_detail_screen.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFC107),
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Your Bookings',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: const Color(0xFF1A1A2E),
            unselectedLabelColor: Colors.grey.shade600,
            labelStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            indicatorColor: const Color(0xFF1A1A2E),
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Ongoing'),
              Tab(text: 'Past Booking'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OngoingTab(),
            _PastTab(),
          ],
        ),
      ),
    );
  }
}

class _OngoingTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<BookingEntry>>(
      valueListenable: BookedEventsState.bookings,
      builder: (context, allBookings, _) {
        final ongoing = allBookings
            .where((b) => b.status == 'Confirmed' || b.status == 'Pending')
            .toList();

        if (ongoing.isEmpty) {
          return _emptyState('No ongoing bookings');
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: ongoing.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) =>
              _BookingCard(booking: ongoing[index]),
        );
      },
    );
  }
}

class _PastTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<BookingEntry>>(
      valueListenable: BookedEventsState.bookings,
      builder: (context, allBookings, _) {
        final past =
            allBookings.where((b) => b.status == 'Completed').toList();

        if (past.isEmpty) {
          return _emptyState('No past bookings');
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: past.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _BookingCard(booking: past[index]),
        );
      },
    );
  }
}

Widget _emptyState(String message) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.event_busy, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}

class _BookingCard extends StatelessWidget {
  final BookingEntry booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final event = booking.event;
    final statusColor = _statusColor(booking.status);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingDetailScreen(booking: booking),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.asset(
                event.imagePath,
                width: Responsive.w(context, 85, min: 65),
                height: Responsive.w(context, 85, min: 65),
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A2E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            booking.status,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            event.venue,
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey.shade600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 3),
                        Text(
                          booking.date,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return const Color(0xFF4CAF50);
      case 'Pending':
        return const Color(0xFFFFC107);
      case 'Completed':
        return Colors.grey;
      default:
        return const Color(0xFF4CAF50);
    }
  }
}
