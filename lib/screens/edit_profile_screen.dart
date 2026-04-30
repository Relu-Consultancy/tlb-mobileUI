import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
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
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _guardianNameCtrl = TextEditingController();
  final _institutionNameCtrl = TextEditingController();

  String? _institutionType;
  DateTime? _dateOfBirth;
  bool _loading = false;
  // Computed once in initState — avoids re-fetching external avatar on every keystroke
  late final String? _avatarUrl;

  static const _institutionTypes = [
    ('school', 'School'),
    ('college', 'College'),
    ('university', 'University'),
    ('other', 'Other'),
  ];

  @override
  void initState() {
    super.initState();
    _prefillFromAuthState();
  }

  void _prefillFromAuthState() {
    final profile = AuthState.userData?['profile'] as Map<String, dynamic>?;
    // Cache avatar URL once so build() never re-fetches on keystroke
    final rawAvatar = profile?['avatar_url'] as String?;
    if (rawAvatar != null && rawAvatar.isNotEmpty) {
      _avatarUrl = rawAvatar;
    } else {
      final initials = Uri.encodeComponent(
        ((profile?['first_name'] as String? ?? '').isNotEmpty
            ? profile!['first_name'] as String
            : AuthState.userEmail?.substring(0, 1).toUpperCase() ?? 'U'),
      );
      _avatarUrl = 'https://ui-avatars.com/api/?name=$initials&background=FFCC00&color=1A1A2E&size=200';
    }
    if (profile == null) return;
    _firstNameCtrl.text = profile['first_name'] as String? ?? '';
    _lastNameCtrl.text = profile['last_name'] as String? ?? '';
    _cityCtrl.text = profile['city'] as String? ?? '';
    _stateCtrl.text = profile['state'] as String? ?? '';
    _guardianNameCtrl.text = profile['guardian_name'] as String? ?? '';
    _institutionNameCtrl.text = profile['institution_name'] as String? ?? '';
    final it = profile['institution_type'] as String?;
    if (it != null && _institutionTypes.any((e) => e.$1 == it)) {
      _institutionType = it;
    }
    final dob = profile['date_of_birth'] as String?;
    if (dob != null && dob.isNotEmpty) {
      try {
        _dateOfBirth = DateTime.parse(dob);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _guardianNameCtrl.dispose();
    _institutionNameCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} / ${d.month.toString().padLeft(2, '0')} / ${d.year}';

  String _isoDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFFFCC00)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _onSave() async {
    final firstName = _firstNameCtrl.text.trim();
    if (firstName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('First name is required')),
      );
      return;
    }

    final token = AuthState.accessToken;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please log in again.')),
      );
      return;
    }

    setState(() => _loading = true);

    final result = await AuthService.updateProfile(
      accessToken: token,
      firstName: firstName.isNotEmpty ? firstName : null,
      lastName: _lastNameCtrl.text.trim().isNotEmpty ? _lastNameCtrl.text.trim() : null,
      dateOfBirth: _dateOfBirth != null ? _isoDate(_dateOfBirth!) : null,
      city: _cityCtrl.text.trim().isNotEmpty ? _cityCtrl.text.trim() : null,
      state: _stateCtrl.text.trim().isNotEmpty ? _stateCtrl.text.trim() : null,
      guardianName: _guardianNameCtrl.text.trim().isNotEmpty ? _guardianNameCtrl.text.trim() : null,
      institutionName: _institutionNameCtrl.text.trim().isNotEmpty ? _institutionNameCtrl.text.trim() : null,
      institutionType: _institutionType,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success'] == true) {
      AuthState.updateUserProfile(result['user'] as Map<String, dynamic>);
      if (widget.isOnboarding) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated!')),
        );
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Update failed. Try again.'),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    }
  }

  void _skip() {
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
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E), size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
          centerTitle: true,
          title: Text(
            widget.isOnboarding ? 'Complete Your Profile' : 'Edit Profile',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 18),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          actions: widget.isOnboarding
              ? [
                  TextButton(
                    onPressed: _skip,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ── Avatar ──
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: Responsive.w(context, 90, min: 70),
                      height: Responsive.w(context, 90, min: 70),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                        image: DecorationImage(
                          image: NetworkImage(_avatarUrl ?? 'https://ui-avatars.com/api/?name=U&background=FFCC00&color=1A1A2E&size=200'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF424242)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

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

                  _buildLabel('Date of Birth'),
                  _buildDateField(),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('City'),
                            _buildTextField(controller: _cityCtrl, hint: 'e.g. Mumbai'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('State'),
                            _buildTextField(controller: _stateCtrl, hint: 'e.g. Maharashtra'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Education ──
              _buildSection(
                title: 'Education',
                children: [
                  _buildLabel('Institution Name'),
                  _buildTextField(controller: _institutionNameCtrl, hint: 'School / College name'),
                  const SizedBox(height: 16),

                  _buildLabel('Institution Type'),
                  _buildDropdown(
                    value: _institutionType,
                    hint: 'Select type',
                    items: _institutionTypes.map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2))).toList(),
                    onChanged: (v) => setState(() => _institutionType = v),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Guardian ──
              _buildSection(
                title: 'Guardian Details',
                children: [
                  _buildLabel('Guardian Name'),
                  _buildTextField(controller: _guardianNameCtrl, hint: 'Parent / Guardian name'),
                ],
              ),
              const SizedBox(height: 30),

              // ── Save button ──
              SizedBox(
                width: double.infinity,
                height: Responsive.h(context, 50, min: 44),
                child: ElevatedButton(
                  onPressed: _loading ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCC00),
                    foregroundColor: const Color(0xFF1A1A2E),
                    disabledBackgroundColor: const Color(0xFFFFCC00).withOpacity(0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF1A1A2E),
                          ),
                        )
                      : Text(
                          widget.isOnboarding ? 'Save & Continue' : 'Update Profile',
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
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
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
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
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF424242),
        ),
      ),
    );
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
        style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF424242)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFFCC00), width: 1.5),
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
                _dateOfBirth != null ? _formatDate(_dateOfBirth!) : 'Select date of birth',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: _dateOfBirth != null ? const Color(0xFF424242) : Colors.grey.shade400,
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
          hint: Text(hint, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500, size: 20),
          style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF424242)),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
