import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'location_screen.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _whatsappNotifications = false;
  bool _locationPermission = false;
  bool _notificationPermission = false;

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
          'Account & Settings',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // My Location
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              'My Location',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            subtitle: Text(
              'Sonipat',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LocationScreen()),
            ),
          ),
          const Divider(height: 1),

          // WhatsApp Notifications
          _buildToggleItem(
            title: 'WhatsApp Notifications',
            subtitle: 'Get your ticket details on WhatsApp',
            value: _whatsappNotifications,
            onChanged: (v) => setState(() => _whatsappNotifications = v),
          ),

          // Location Permission
          _buildToggleItem(
            title: 'Location Permission',
            subtitle: 'Allow access to find nearby events',
            value: _locationPermission,
            onChanged: (v) => setState(() => _locationPermission = v),
            activeColor: const Color(0xFFFFC107),
          ),

          // Notification Permission
          _buildToggleItem(
            title: 'Notification Permission',
            subtitle: 'Get updates about new events & offers',
            value: _notificationPermission,
            onChanged: (v) => setState(() => _notificationPermission = v),
          ),

          const Divider(height: 1),

          // Delete Account
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              'Delete Account',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {},
          ),

          // Sign Out
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              'Sign Out',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {},
          ),

          const Spacer(),

          // Footer
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'Share',
                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text('  •  ', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                    Flexible(
                      child: Text(
                        'Rate Us',
                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'Terms & Conditions',
                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text('  •  ', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                    Flexible(
                      child: Text(
                        'Privacy Policy',
                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'App Version: 1.0.0',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color activeColor = const Color(0xFF1A1A2E),
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A2E),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
        activeTrackColor: activeColor.withOpacity(0.4),
      ),
    );
  }
}
