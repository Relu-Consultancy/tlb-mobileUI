import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/booked_events_state.dart';
import 'booking_detail_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _tabIndex = 0;
  final List<String> _tabs = ['Upcoming', 'Past', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Bookings',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // Pill tab bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final active = i == _tabIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tabIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: active ? const Color(0xFFFFB902) : Colors.transparent,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Text(
                          _tabs[i],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                            color: active ? const Color(0xFF1A1A2E) : Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ValueListenableBuilder<List<BookingEntry>>(
              valueListenable: BookedEventsState.bookings,
              builder: (context, allBookings, _) {
                final filtered = _filterBookings(allBookings, _tabIndex);
                if (filtered.isEmpty) {
                  return _buildEmpty(_tabs[_tabIndex]);
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _BookingCard(booking: filtered[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<BookingEntry> _filterBookings(List<BookingEntry> all, int tab) {
    switch (tab) {
      case 0:
        return all.where((b) => b.status == 'Confirmed' || b.status == 'Pending').toList();
      case 1:
        return all.where((b) => b.status == 'Completed').toList();
      case 2:
        return all.where((b) => b.status == 'Cancelled').toList();
      default:
        return all;
    }
  }

  Widget _buildEmpty(String tab) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No $tab Bookings',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingEntry booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final event = booking.event;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookingDetailScreen(booking: booking)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                event.imagePath,
                width: 88,
                height: 88,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 88,
                  height: 88,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.event, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  if (booking.date.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined, size: 13, color: Colors.grey),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            booking.date,
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          event.venue,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // View Ticket button
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BookingDetailScreen(booking: booking)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFFFB902), width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Ticket',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right, size: 16, color: Color(0xFF1A1A2E)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
