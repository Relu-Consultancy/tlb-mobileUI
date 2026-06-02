import 'package:flutter/material.dart';
import '../core/responsive.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
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
            fontSize: Responsive.sp(context, 18),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDF4FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active_outlined,
                    color: Color(0xFF2563EB),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Currently being developed',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 15),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "We're building in-app notifications. You'll see booking "
                  'updates, reminders and announcements here soon.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 12.5),
                    color: Colors.grey.shade600,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      /* ────────────────────────────────────────────────────────────────────
       * ORIGINAL "No Notifications Yet" empty-state design — kept commented
       * out so it can be reinstated the moment the notifications API ships.
       * Restore by replacing the body above with this block.
       *
       * body: Center(
       *   child: Padding(
       *     padding: const EdgeInsets.symmetric(horizontal: 32),
       *     child: Column(
       *       mainAxisSize: MainAxisSize.min,
       *       children: [
       *         Icon(
       *           Icons.notifications_off_outlined,
       *           size: 72,
       *           color: Colors.grey.shade300,
       *         ),
       *         const SizedBox(height: 20),
       *         Text(
       *           'No Notifications Yet',
       *           style: GoogleFonts.poppins(
       *             fontSize: Responsive.sp(context, 18),
       *             fontWeight: FontWeight.w700,
       *             color: const Color(0xFF1A1A2E),
       *           ),
       *         ),
       *         const SizedBox(height: 8),
       *         Text(
       *           "You're all caught up! We'll let you know when something new arrives.",
       *           style: GoogleFonts.poppins(
       *             fontSize: Responsive.sp(context, 13),
       *             color: Colors.grey.shade500,
       *             height: 1.5,
       *           ),
       *           textAlign: TextAlign.center,
       *         ),
       *       ],
       *     ),
       *   ),
       * ),
       *
       * Once the notifications API is wired, this empty state should only
       * show when the fetch succeeds with an empty list. Loading + error
       * states need separate handling at that point.
       * ──────────────────────────────────────────────────────────────────── */
    );
  }
}
