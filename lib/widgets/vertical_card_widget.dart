import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerticalCardWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final String reviewCount;
  final String location;
  final String buttonText;
  final String? price;
  final String? badgeText;
  final VoidCallback? onTapBtn;

  const VerticalCardWidget({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.reviewCount,
    required this.location,
    required this.buttonText,
    this.price,
    this.badgeText,
    this.onTapBtn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75 > 320 ? 320 : MediaQuery.of(context).size.width * 0.75,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Area
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  imagePath,
                  height: 200, // kept as aspect fallback
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              if (badgeText != null)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4A55A2), // Dark Blue badge
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      badgeText!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          // Content Area
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.people_alt_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (index) => const Icon(Icons.star, size: 14, color: Colors.amber),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      reviewCount,
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (price != null)
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: price,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                            TextSpan(
                              text: ' / child',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox(),
                    
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: onTapBtn ?? () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFCC00), // Yellow
                          foregroundColor: const Color(0xFF1A1A2E),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        child: Text(
                          buttonText,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
