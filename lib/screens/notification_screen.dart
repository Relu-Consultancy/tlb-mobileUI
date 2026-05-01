import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, dynamic>> _today = [
    {
      'image': 'resources- tlb-ui/tlbAppIcon.png',
      'bgColor': const Color(0xFFFFEDD5),
      'title': 'Limited Time Cashback',
      'subtitle': 'Get upto ',
      'highlight': '₹100',
      'subtitleEnd': ' cashback on selected venues',
      'time': '11:00 AM',
      'isNew': true,
    },
    {
      'image': 'resources- tlb-ui/tlbAppIcon.png',
      'bgColor': const Color(0xFFDCF5E4),
      'title': 'Classes Rescheduled',
      'subtitle': 'Quick Heads Up! Your Robotics Batch is Now 6–8 PM On Friday, May 12th',
      'highlight': '',
      'subtitleEnd': '',
      'time': '08:00 AM',
      'isNew': true,
    },
  ];

  final List<Map<String, dynamic>> _yesterday = [
    {
      'image': 'resources- tlb-ui/tlbAppIcon.png',
      'bgColor': const Color(0xFFFFF3CD),
      'title': "Don't Miss  Weekend250!",
      'subtitle': 'Flat ',
      'highlight': '₹250',
      'subtitleEnd': ' Off Weekend Bookings Valid Sat & Sun Only',
      'time': '11:00 AM',
      'isNew': false,
    },
    {
      'image': 'resources- tlb-ui/tlbAppIcon.png',
      'bgColor': const Color(0xFFE8F5FD),
      'title': 'Inclusive Space Added',
      'subtitle': 'New Sensory – Friendly Venues: Inclusive Bakery At Matunga!',
      'highlight': '',
      'subtitleEnd': '',
      'time': '09:00 AM',
      'isNew': false,
    },
  ];

  int get _newCount => _today.where((n) => n['isNew'] == true).length;

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
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              for (final n in _today) { n['isNew'] = false; }
            }),
            child: Text(
              'Mark All as Read',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFFB902),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            // Summary line
            RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
                children: [
                  const TextSpan(text: 'You have '),
                  TextSpan(
                    text: '$_newCount Notifications',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFFB902),
                    ),
                  ),
                  const TextSpan(text: ' today.'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionLabel('Today'),
            const SizedBox(height: 10),
            ..._today.map((n) => _buildNotifCard(n)),

            const SizedBox(height: 20),
            _buildSectionLabel('Yesterday'),
            const SizedBox(height: 10),
            ..._yesterday.map((n) => _buildNotifCard(n)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A1A2E),
      ),
    );
  }

  Widget _buildNotifCard(Map<String, dynamic> n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: n['bgColor'] as Color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                n['image'] as String,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.notifications_outlined,
                  color: Colors.grey.shade500,
                  size: 22,
                ),
              ),
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
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 3),
                if ((n['highlight'] as String).isNotEmpty)
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(text: n['subtitle'] as String),
                        TextSpan(
                          text: n['highlight'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFFB902),
                          ),
                        ),
                        TextSpan(text: n['subtitleEnd'] as String),
                      ],
                    ),
                  )
                else
                  Text(
                    n['subtitle'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 5),
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
          if (n['isNew'] == true)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFFFB902),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
