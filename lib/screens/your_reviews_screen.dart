import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class YourReviewsScreen extends StatelessWidget {
  const YourReviewsScreen({super.key});

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
          'Your Reviews',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: _dummyReviews.isEmpty
            ? _buildEmptyState()
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _dummyReviews.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final review = _dummyReviews[index];
                  return _buildReviewCard(review);
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No Reviews Yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your reviews will appear here after\nyou attend and review an event.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event info row
          Row(
            children: [
              // Event image thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 56,
                  height: 56,
                  color: const Color(0xFFE0E0E0),
                  child: Image.asset(
                    review['image'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.event,
                      color: Colors.grey,
                      size: 28,
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
                      review['eventName'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      review['date'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              // Edit icon
              IconButton(
                icon: Icon(Icons.edit_outlined, size: 18, color: Colors.grey.shade400),
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Star rating
          Row(
            children: List.generate(5, (i) {
              return Icon(
                i < (review['rating'] as int) ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 20,
                color: i < (review['rating'] as int)
                    ? const Color(0xFFFFC107)
                    : Colors.grey.shade300,
              );
            }),
          ),

          const SizedBox(height: 10),

          // Review text
          Text(
            review['text'] as String,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 8),

          // Helpful count
          Row(
            children: [
              Icon(Icons.thumb_up_alt_outlined, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(
                '${review['helpful']} people found this helpful',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _dummyReviews => [
        {
          'eventName': 'Halloween Party 2025',
          'image': 'assets/images/halloween_party.png',
          'rating': 5,
          'date': 'Feb 28, 2025',
          'text':
              'Absolutely amazing event! The decorations were top-notch and my kids had a blast. The storytelling session was the highlight. Would definitely recommend!',
          'helpful': 12,
        },
        {
          'eventName': 'World Storytelling Day',
          'image': 'assets/images/story_telling.png',
          'rating': 4,
          'date': 'Feb 20, 2025',
          'text':
              'Great event with wonderful storytellers. The venue was a bit crowded but the overall experience was really enjoyable. Kids loved every minute of it.',
          'helpful': 8,
        },
        {
          'eventName': 'Art & Craft Workshop',
          'image': 'assets/images/kids_party_banner.png',
          'rating': 5,
          'date': 'Feb 15, 2025',
          'text':
              'Such a creative and fun workshop! The instructors were patient and encouraging. My daughter made a beautiful painting that we framed at home.',
          'helpful': 15,
        },
        {
          'eventName': 'Summer Dance Camp',
          'image': 'assets/images/story_telling.png',
          'rating': 3,
          'date': 'Feb 10, 2025',
          'text':
              'The dance camp was okay. The choreography was interesting but the session felt a bit short. Would have liked more time for practice.',
          'helpful': 3,
        },
      ];
}
