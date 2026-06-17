import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/app_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../core/app_snackbar.dart';
import '../providers/auth_state.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class EditProfileScreen extends StatefulWidget {
  /// When true, shows onboarding UI (no back, "Skip" option, post-save goes to HomeScreen).
  final bool isOnboarding;

  const EditProfileScreen({super.key, this.isOnboarding = false});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();

  String? _gender;
  DateTime? _birthdate;
  bool _loading = false;
  bool _fetchingProfile = false;
  bool _prefetchFailed = false;

  // Country code picker state — defaults to India
  (String, String, String) _selectedCountry = _countryCodes[0];

  static const _countryCodes = [
    ('+91',  '🇮🇳', 'India'),
    ('+1',   '🇺🇸', 'United States'),
    ('+1',   '🇨🇦', 'Canada'),
    ('+44',  '🇬🇧', 'United Kingdom'),
    ('+971', '🇦🇪', 'United Arab Emirates'),
    ('+65',  '🇸🇬', 'Singapore'),
    ('+61',  '🇦🇺', 'Australia'),
    ('+60',  '🇲🇾', 'Malaysia'),
    ('+966', '🇸🇦', 'Saudi Arabia'),
    ('+974', '🇶🇦', 'Qatar'),
    ('+973', '🇧🇭', 'Bahrain'),
    ('+968', '🇴🇲', 'Oman'),
    ('+92',  '🇵🇰', 'Pakistan'),
    ('+880', '🇧🇩', 'Bangladesh'),
    ('+94',  '🇱🇰', 'Sri Lanka'),
    ('+977', '🇳🇵', 'Nepal'),
    ('+49',  '🇩🇪', 'Germany'),
    ('+33',  '🇫🇷', 'France'),
    ('+39',  '🇮🇹', 'Italy'),
    ('+34',  '🇪🇸', 'Spain'),
    ('+81',  '🇯🇵', 'Japan'),
    ('+82',  '🇰🇷', 'South Korea'),
    ('+86',  '🇨🇳', 'China'),
    ('+55',  '🇧🇷', 'Brazil'),
    ('+27',  '🇿🇦', 'South Africa'),
    ('+234', '🇳🇬', 'Nigeria'),
    ('+254', '🇰🇪', 'Kenya'),
    ('+20',  '🇪🇬', 'Egypt'),
  ];

  static const _genders = [
    ('male', 'Male'),
    ('female', 'Female'),
    ('other', 'Other'),
    ('prefer_not_to_say', 'Prefer not to say'),
  ];

  @override
  void initState() {
    super.initState();
    _prefillFromAuthState();
    _fetchAndPrefill();
  }

  Future<void> _fetchAndPrefill() async {
    final token = AuthState.accessToken;
    if (token == null) return;
    setState(() => _fetchingProfile = true);
    try {
      final result = await AuthService.getProfile(accessToken: token);
      if (!mounted) return;
      if (result['success'] == true) {
        final profile = result['profile'] as Map<String, dynamic>;
        AuthState.updateProfileData(profile);
        _prefillFromAuthState();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _prefetchFailed = true);
      AppSnackBar.error(context, 'Could not load your profile data. Please review your details before saving.');
    } finally {
      if (mounted) setState(() => _fetchingProfile = false);
    }
  }

  void _prefillFromAuthState() {
    final profile = AuthState.userData?['profile'] as Map<String, dynamic>?;
    if (profile == null) return;
    _firstNameCtrl.text = profile['first_name'] as String? ?? '';
    _lastNameCtrl.text = profile['last_name'] as String? ?? '';
    final raw = profile['phone_number'] as String? ?? '';
    if (raw.startsWith('+')) {
      // Match longest dial code first so '+1' doesn't shadow '+1xxx' variants
      final sorted = [..._countryCodes]..sort((a, b) => b.$1.length.compareTo(a.$1.length));
      bool found = false;
      for (final c in sorted) {
        if (raw.startsWith(c.$1)) {
          _selectedCountry = _countryCodes.firstWhere(
            (x) => x.$1 == c.$1 && x.$2 == c.$2,
            orElse: () => c,
          );
          _phoneCtrl.text = raw.substring(c.$1.length).trim();
          found = true;
          break;
        }
      }
      if (!found) _phoneCtrl.text = raw;
    } else {
      _phoneCtrl.text = raw;
    }
    _regionCtrl.text = profile['region'] as String? ?? '';
    final g = profile['gender'] as String?;
    if (g != null && _genders.any((e) => e.$1 == g)) _gender = g;
    final bd = profile['birthdate'] as String?;
    if (bd != null && bd.isNotEmpty) {
      try { _birthdate = DateTime.parse(bd); } catch (_) {}
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _regionCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} / ${d.month.toString().padLeft(2, '0')} / ${d.year}';

  String _isoDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthdate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryLight),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthdate = picked);
  }

  Future<void> _onSave() async {
    final firstName = _firstNameCtrl.text.trim();
    if (firstName.isEmpty) {
      AppSnackBar.show(context, 'First name is required');
      return;
    }

    final token = AuthState.accessToken;
    if (token == null) {
      AppSnackBar.error(context, 'Session expired. Please log in again.');
      return;
    }

    setState(() => _loading = true);

    final result = await AuthService.updateProfile(
      accessToken: token,
      firstName: firstName,
      lastName: _lastNameCtrl.text.trim().isNotEmpty ? _lastNameCtrl.text.trim() : null,
      phoneNumber: _phoneCtrl.text.trim().isNotEmpty
          ? '${_selectedCountry.$1}${_phoneCtrl.text.trim().replaceAll(RegExp(r'[\s\-()]'), '')}'
          : null,
      gender: _gender,
      birthdate: _birthdate != null ? _isoDate(_birthdate!) : null,
      region: _regionCtrl.text.trim().isNotEmpty ? _regionCtrl.text.trim() : null,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success'] == true) {
      AuthState.updateProfileData(result['profile'] as Map<String, dynamic>);
      if (widget.isOnboarding) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        AppSnackBar.success(context, 'Profile updated!');
        Navigator.pop(context);
      }
    } else {
      AppSnackBar.error(context, result['message'] ?? 'Update failed. Try again.');
    }
  }

  Future<void> _skip() async {
    final firstName = _firstNameCtrl.text.trim();
    if (firstName.isEmpty) {
      AppSnackBar.show(
        context,
        'Please enter your first name to continue.',
      );
      return;
    }

    // Save only the first name so the home greeting works immediately and
    // the walkthrough that fires on the next screen can read it. Other
    // fields are intentionally left for the user to fill later.
    setState(() => _loading = true);
    final token = AuthState.accessToken;
    if (token != null) {
      final result = await AuthService.updateProfile(
        accessToken: token,
        firstName: firstName,
      );
      if (result['success'] == true && result['profile'] is Map) {
        AuthState.updateProfileData(
          Map<String, dynamic>.from(result['profile'] as Map),
        );
      }
    }

    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isOnboarding,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: !widget.isOnboarding,
          leading: widget.isOnboarding
              ? null
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
          centerTitle: true,
          title: Text(
            widget.isOnboarding ? 'Complete Your Profile' : 'Edit Profile',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 18),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          actions: widget.isOnboarding
              ? [
                  TextButton(
                    onPressed: (_loading || _fetchingProfile) ? null : _skip,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 14),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2F80ED),
                      ),
                    ),
                  ),
                ]
              : null,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (widget.isOnboarding) ...[
                Text(
                  "Let's set up your profile so we can personalise your experience.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 13),
                    color: Colors.grey.shade500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              if (_prefetchFailed) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFB300), width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile data could not be loaded',
                              style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), fontWeight: FontWeight.w500, color: const Color(0xFFE65100)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Fields may be empty or outdated. Please fill them in carefully before saving.',
                              style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11.5), color: const Color(0xFF7A4000), height: 1.4),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () {
                                setState(() => _prefetchFailed = false);
                                _fetchAndPrefill();
                              },
                              child: Text(
                                'Tap to retry',
                                style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11.5), fontWeight: FontWeight.w500, color: const Color(0xFFE65100), decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ── Basic Info ──
              _buildSection(
                title: 'Basic Information',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('First Name *'),
                            _buildTextField(controller: _firstNameCtrl, hint: 'First name'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Last Name'),
                            _buildTextField(controller: _lastNameCtrl, hint: 'Last name'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Phone Number'),
                  _buildPhoneField(),
                  const SizedBox(height: 16),

                  _buildLabel('Gender'),
                  _buildDropdown(
                    value: _gender,
                    hint: 'Select gender',
                    items: _genders.map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2))).toList(),
                    onChanged: (v) => setState(() => _gender = v),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Date of Birth'),
                  _buildDateField(),
                  const SizedBox(height: 16),

                  _buildLabel('Region / City'),
                  _buildTextField(controller: _regionCtrl, hint: 'e.g. Mumbai'),
                ],
              ),
              const SizedBox(height: 30),

              // ── Save button ──
              SizedBox(
                width: double.infinity,
                height: Responsive.h(context, 50, min: 44),
                child: ElevatedButton(
                  onPressed: (_loading || _fetchingProfile) ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: AppColors.textPrimary,
                    disabledBackgroundColor: AppColors.primaryLight.withOpacity(0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: (_loading || _fetchingProfile)
                      ? const AppLoaderInline(dotSize: 7, spacing: 4, color: AppColors.textPrimary)
                      : Text(
                          widget.isOnboarding ? 'Save & Continue' : 'Update Profile',
                          style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w500),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 14),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: Responsive.sp(context, 12),
          fontWeight: FontWeight.w500,
          color: const Color(0xFF424242),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    final h = Responsive.h(context, 46, min: 40);
    return Container(
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // Country code prefix — tappable
          GestureDetector(
            onTap: _showCountryPicker,
            child: Container(
              height: h,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey.shade300)),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedCountry.$2, style: TextStyle(fontSize: Responsive.sp(context, 18))),
                  const SizedBox(width: 4),
                  Text(
                    _selectedCountry.$1,
                    style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: const Color(0xFF424242)),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey.shade500),
                ],
              ),
            ),
          ),
          // Phone number input
          Expanded(
            child: TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: const Color(0xFF424242)),
              decoration: InputDecoration(
                hintText: 'Phone number',
                hintStyle: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade400),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCountryPicker() async {
    final searchCtrl = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final query = searchCtrl.text.toLowerCase();
          final filtered = _countryCodes
              .where((c) => c.$3.toLowerCase().contains(query) || c.$1.contains(query))
              .toList();
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.62,
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: searchCtrl,
                      autofocus: true,
                      onChanged: (_) => setLocal(() {}),
                      style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14)),
                      decoration: InputDecoration(
                        hintText: 'Search country or code...',
                        hintStyle: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final c = filtered[i];
                        final isSelected = c.$1 == _selectedCountry.$1 && c.$2 == _selectedCountry.$2;
                        return ListTile(
                          dense: true,
                          leading: Text(c.$2, style: TextStyle(fontSize: Responsive.sp(context, 22))),
                          title: Text(c.$3, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14))),
                          trailing: Text(
                            c.$1,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 13),
                              color: isSelected ? const Color(0xFFDE7104) : Colors.grey.shade600,
                              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedTileColor: const Color(0xFFFFF8E1),
                          onTap: () {
                            setState(() => _selectedCountry = c);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    searchCtrl.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      height: Responsive.h(context, 46, min: 40),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: const Color(0xFF424242)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade400),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        height: Responsive.h(context, 46, min: 40),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _birthdate != null ? _formatDate(_birthdate!) : 'Select date of birth',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 13),
                  color: _birthdate != null ? const Color(0xFF424242) : Colors.grey.shade400,
                ),
              ),
            ),
            Icon(Icons.calendar_month_outlined, size: 18, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      height: Responsive.h(context, 46, min: 40),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade400)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500, size: 20),
          style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: const Color(0xFF424242)),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
