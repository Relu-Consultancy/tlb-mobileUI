import 'package:flutter/material.dart';
import '../core/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/saved_events_state.dart';
import '../providers/auth_state.dart';
import '../models/event_model.dart';
import '../widgets/app_loader.dart';
import '../widgets/app_refresh_indicator.dart';
import 'event_detail_screen.dart';

class SavedEventsScreen extends StatefulWidget {
  const SavedEventsScreen({super.key});

  @override
  State<SavedEventsScreen> createState() => _SavedEventsScreenState();
}

class _SavedEventsScreenState extends State<SavedEventsScreen> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await SavedEventsState.loadFromApi(silent: false);
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

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
          'Favorites',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 18),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) return const AppLoader();
    if (_error != null) return _buildError(context);

    return AppRefreshIndicator(
      onRefresh: _fetch,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting banner ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder<String?>(
                        valueListenable: AuthState.userName,
                        builder: (context, _, __) {
                          return Text(
                            'Hi ${AuthState.firstName},',
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 22),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1A1A2E),
                            ),
                          );
                        },
                      ),
                      Text(
                        'Here are your saved activities.',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 13),
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'resources- tlb-ui/accounts_page/wishlist.png',
                  width: 110,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.favorite_rounded,
                    size: 64,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              'Saved Activities',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 14),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 10),

            ValueListenableBuilder<List<EventModel>>(
              valueListenable: SavedEventsState.savedEvents,
              builder: (context, saved, _) {
                if (saved.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: Column(
                        children: [
                          Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'No saved activities yet',
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 15),
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap the heart icon on any event to save it',
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 12),
                              color: Colors.grey.shade400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: List.generate(saved.length, (index) {
                      final event = saved[index];
                      final isLast = index == saved.length - 1;
                      return Column(
                        children: [
                          _SavedRow(event: event),
                          if (!isLast)
                            const Divider(height: 1, indent: 16, endIndent: 16),
                        ],
                      );
                    }),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: Color(0xFFCCCCCC)),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 13),
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFCC00),
                foregroundColor: const Color(0xFF1A1A2E),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
              ),
              child: Text('Retry',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedRow extends StatelessWidget {
  final EventModel event;
  const _SavedRow({required this.event});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: event.imagePath.startsWith('http')
                    ? Image.network(
                        event.imagePath,
                        width: 56,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 56,
                          height: 48,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.event, color: Colors.grey),
                        ),
                      )
                    : Image.asset(
                        event.imagePath,
                        width: 56,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 56,
                          height: 48,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.event, color: Colors.grey),
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  event.title,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 14),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
