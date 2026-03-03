import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Offers & Coupons',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _dummyCoupons.length,
          itemBuilder: (context, index) {
            final coupon = _dummyCoupons[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _CouponCard(coupon: coupon),
            );
          },
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _dummyCoupons => [
        {
          'code': 'TLB20OFF',
          'discount': '20% OFF',
          'description': 'Get 20% off on all weekend events',
          'validity': 'Valid till Mar 31, 2025',
          'minOrder': 'Min. order ₹500',
          'color': const Color(0xFFFF6B6B),
          'icon': Icons.celebration,
        },
        {
          'code': 'KIDS100',
          'discount': '₹100 OFF',
          'description': 'Flat ₹100 off on Kids events',
          'validity': 'Valid till Apr 15, 2025',
          'minOrder': 'Min. order ₹300',
          'color': const Color(0xFF5C6BC0),
          'icon': Icons.child_care,
        },
        {
          'code': 'FIRSTBOOK',
          'discount': '30% OFF',
          'description': 'First booking discount for new users',
          'validity': 'Valid till May 1, 2025',
          'minOrder': 'No minimum',
          'color': const Color(0xFF4CAF50),
          'icon': Icons.new_releases_outlined,
        },
        {
          'code': 'SUMMER50',
          'discount': '₹50 OFF',
          'description': 'Summer special on outdoor activities',
          'validity': 'Valid till Jun 30, 2025',
          'minOrder': 'Min. order ₹200',
          'color': const Color(0xFFFF9800),
          'icon': Icons.wb_sunny_outlined,
        },
        {
          'code': 'FAMILY25',
          'discount': '25% OFF',
          'description': 'Family pack discount on group bookings',
          'validity': 'Valid till Apr 30, 2025',
          'minOrder': 'Min. 3 tickets',
          'color': const Color(0xFF9C27B0),
          'icon': Icons.family_restroom,
        },
      ];
}

class _CouponCard extends StatelessWidget {
  final Map<String, dynamic> coupon;
  const _CouponCard({required this.coupon});

  @override
  Widget build(BuildContext context) {
    final color = coupon['color'] as Color;

    return ClipPath(
      clipper: _CouponClipper(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: color.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left colored section
            Container(
              width: 90,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(coupon['icon'] as IconData, color: Colors.white, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    coupon['discount'] as String,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Dashed divider
            _buildDashedDivider(color),

            // Right details section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon['description'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${coupon['validity']} • ${coupon['minOrder']}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Coupon code + copy
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: color.withOpacity(0.3),
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Text(
                              coupon['code'] as String,
                              style: GoogleFonts.spaceMono(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: color,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: coupon['code'] as String));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Coupon code "${coupon['code']}" copied!'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.copy, size: 14, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  'Copy',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  Widget _buildDashedDivider(Color color) {
    return SizedBox(
      width: 1,
      height: 110,
      child: CustomPaint(
        painter: _DashedVerticalPainter(color: color.withOpacity(0.3)),
      ),
    );
  }
}

class _CouponClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const radius = 10.0;
    final path = Path()
      ..addRRect(RRect.fromLTRBR(0, 0, size.width, size.height, const Radius.circular(16)));

    // Cut semi-circles at the left edge where the divider is
    final cutX = 90.0;
    path.addOval(Rect.fromCircle(center: Offset(cutX, 0), radius: radius));
    path.addOval(Rect.fromCircle(center: Offset(cutX, size.height), radius: radius));

    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _DashedVerticalPainter extends CustomPainter {
  final Color color;
  _DashedVerticalPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    double startY = 0;
    const dashHeight = 5.0;
    const gapHeight = 4.0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + gapHeight;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
