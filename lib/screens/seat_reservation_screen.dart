import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/event_model.dart';

class SeatReservationScreen extends StatefulWidget {
  final EventModel event;

  const SeatReservationScreen({super.key, required this.event});

  @override
  State<SeatReservationScreen> createState() => _SeatReservationScreenState();
}

class _SeatReservationScreenState extends State<SeatReservationScreen> {
  // Seat layout: 0 = empty gap, 1 = available, 2 = sold, 3 = selected
  late List<List<int>> _seatMap;

  // Seat categories by row
  final Map<String, _SeatCategory> _categories = {
    'VIP': _SeatCategory('VIP', 2500, const Color(0xFFFFB902)),
    'Premium': _SeatCategory('Premium', 1500, const Color(0xFFFF6B6B)),
    'Standard': _SeatCategory('Standard', 800, const Color(0xFF5C6BC0)),
  };

  // Row labels
  final List<String> _rowLabels = [
    'A', 'B', 'C', // VIP
    'D', 'E', 'F', // Premium
    'G', 'H', 'I', 'J', // Standard
  ];

  String _getCategoryForRow(int row) {
    if (row < 3) return 'VIP';
    if (row < 6) return 'Premium';
    return 'Standard';
  }

  @override
  void initState() {
    super.initState();
    _initSeatMap();
  }

  void _initSeatMap() {
    // 10 rows × 12 columns with some gaps and sold seats
    _seatMap = [
      // VIP rows (A-C)
      [0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0],
      [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
      [0, 1, 2, 1, 1, 1, 1, 1, 2, 1, 1, 0],
      // Premium rows (D-F)
      [1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1],
      [1, 1, 2, 2, 1, 1, 1, 1, 2, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      // Standard rows (G-J)
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 2, 2, 1, 1, 2, 2, 1, 1, 1],
    ];
  }

  List<MapEntry<String, int>> get _selectedSeats {
    final selected = <MapEntry<String, int>>[];
    for (int r = 0; r < _seatMap.length; r++) {
      for (int c = 0; c < _seatMap[r].length; c++) {
        if (_seatMap[r][c] == 3) {
          selected.add(MapEntry('${_rowLabels[r]}${c + 1}', r));
        }
      }
    }
    return selected;
  }

  int get _totalPrice {
    int total = 0;
    for (final entry in _selectedSeats) {
      final cat = _getCategoryForRow(entry.value);
      total += _categories[cat]!.price;
    }
    return total;
  }

  void _toggleSeat(int row, int col) {
    if (_seatMap[row][col] == 0 || _seatMap[row][col] == 2) return;
    setState(() {
      if (_seatMap[row][col] == 1) {
        if (_selectedSeats.length >= 6) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maximum 6 seats per booking')),
          );
          return;
        }
        _seatMap[row][col] = 3;
      } else if (_seatMap[row][col] == 3) {
        _seatMap[row][col] = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Seats',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Event info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFFFF8E1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  '${widget.event.venue} • ${widget.event.eventDate ?? 'TBD'} | ${widget.event.eventTime ?? 'TBD'}',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Seat map area
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Stage indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFB902), Color(0xFFFFC107)],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(40),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFB902).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'STAGE',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Seat grid
                  Builder(builder: (context) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    // Dynamic seat size: fits 12 seats + 2 labels + gaps
                    final seatSize = ((screenWidth - 80) / 14).clamp(18.0, 28.0);
                    final seatMargin = (seatSize * 0.06).clamp(1.0, 2.0);

                    return Column(
                      children: List.generate(_seatMap.length, (row) {
                        final cat = _getCategoryForRow(row);
                        final isFirstInCategory = row == 0 || _getCategoryForRow(row - 1) != cat;

                        return Column(
                          children: [
                            if (isFirstInCategory) ...[
                              if (row > 0) const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '${_categories[cat]!.name} - ₹${_categories[cat]!.price}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _categories[cat]!.color,
                                  ),
                                ),
                              ),
                            ],
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Row label
                                  SizedBox(
                                    width: 20,
                                    child: Text(
                                      _rowLabels[row],
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  // Seats
                                  ...List.generate(_seatMap[row].length, (col) {
                                    final seat = _seatMap[row][col];
                                    if (seat == 0) return SizedBox(width: seatSize, height: seatSize);

                                    Color bgColor;
                                    Color borderColor;
                                    IconData? icon;
                                    switch (seat) {
                                      case 1: // available
                                        bgColor = Colors.white;
                                        borderColor = _categories[cat]!.color;
                                        break;
                                      case 2: // sold
                                        bgColor = Colors.grey.shade200;
                                        borderColor = Colors.grey.shade300;
                                        icon = Icons.close;
                                        break;
                                      case 3: // selected
                                        bgColor = _categories[cat]!.color;
                                        borderColor = _categories[cat]!.color;
                                        break;
                                      default:
                                        bgColor = Colors.white;
                                        borderColor = Colors.grey;
                                    }

                                    return GestureDetector(
                                      onTap: () => _toggleSeat(row, col),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        width: seatSize,
                                        height: seatSize,
                                        margin: EdgeInsets.all(seatMargin),
                                        decoration: BoxDecoration(
                                          color: bgColor,
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(6),
                                            bottom: Radius.circular(2),
                                          ),
                                          border: Border.all(color: borderColor, width: 1.5),
                                        ),
                                        child: icon != null
                                            ? Icon(icon, size: seatSize * 0.5, color: Colors.grey)
                                            : seat == 3
                                                ? Icon(Icons.check, size: seatSize * 0.6, color: Colors.white)
                                                : null,
                                      ),
                                    );
                                  }),
                                  const SizedBox(width: 4),
                                  // Row label
                                  SizedBox(
                                    width: 20,
                                    child: Text(
                                      _rowLabels[row],
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    );
                  }),

                  const SizedBox(height: 28),

                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(Colors.white, Colors.grey, 'Available'),
                      const SizedBox(width: 16),
                      _buildLegendItem(const Color(0xFFFFB902), const Color(0xFFFFB902), 'Selected'),
                      const SizedBox(width: 16),
                      _buildLegendItem(Colors.grey.shade200, Colors.grey.shade300, 'Sold'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Category price cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: _categories.entries.map((entry) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: entry.value.color.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: entry.value.color.withOpacity(0.3)),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: entry.value.color,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  entry.value.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1A1A2E),
                                  ),
                                ),
                                Text(
                                  '₹${entry.value.price}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: entry.value.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _selectedSeats.isNotEmpty ? SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selected seats list
              SizedBox(
                height: 28,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _selectedSeats.map((entry) {
                    final cat = _getCategoryForRow(entry.value);
                    return Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _categories[cat]!.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _categories[cat]!.color),
                      ),
                      child: Text(
                        entry.key,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _categories[cat]!.color,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_selectedSeats.length} Seat${_selectedSeats.length > 1 ? 's' : ''} • ₹$_totalPrice',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Booking ${_selectedSeats.length} seat(s) for ₹$_totalPrice'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB902),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      elevation: 0,
                    ),
                    child: Text(
                      'Proceed',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ) : null,
    );
  }

  Widget _buildLegendItem(Color fill, Color border, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: border, width: 1.5),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _SeatCategory {
  final String name;
  final int price;
  final Color color;

  const _SeatCategory(this.name, this.price, this.color);
}
