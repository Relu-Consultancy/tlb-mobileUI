import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static final List<Map<String, dynamic>> _notifications = [
    {
      'icon': Icons.local_offer_outlined,
      'title': 'Special Offer!',
      'subtitle': 'Get 20% off on all events this weekend. Use code TLB20.',
      'time': '2 hours ago',
      'color': const Color(0xFFFFC107),
    },
    {
      'icon': Icons.event_available,
      'title': 'Booking Confirmed',
      'subtitle': 'Your booking for Halloween Party has been confirmed.',
      'time': '1 day ago',
      'color': const Color(0xFF4CAF50),
    },
    {
      'icon': Icons.campaign_outlined,
      'title': 'New Event Near You',
      'subtitle': 'World Storytelling Day is happening at Embassy Int. Riding School.',
      'time': '2 days ago',
      'color': const Color(0xFF2196F3),
    },
    {
      'icon': Icons.star_outline,
      'title': 'Rate Your Experience',
      'subtitle': 'How was the Kids Party event? Share your feedback.',
      'time': '3 days ago',
      'color': const Color(0xFFFF9800),
    },
    {
      'icon': Icons.card_giftcard,
      'title': 'Referral Bonus',
      'subtitle': 'You earned ₹100 for referring a friend. Keep sharing!',
      'time': '5 days ago',
      'color': const Color(0xFF9C27B0),
    },
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final n = _notifications[index];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (n['color'] as Color).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    n['icon'] as IconData,
                    color: n['color'] as Color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n['title'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        n['subtitle'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        n['time'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
