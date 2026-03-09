import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/auth_state.dart';
import '../core/responsive.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFFFFC107), size: 22),
      suffixIcon: suffix,
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFC107), width: 2),
      ),
    );
  }

  void _onSignup() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms & Conditions')),
      );
      return;
    }

    // Simulate signup → log the user in and go to home
    AuthState.login(name: name, phone: phone);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account created successfully! 🎉')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Header illustration
                Center(
                  child: Icon(
                    Icons.person_add_rounded,
                    size: 80,
                    color: const Color(0xFF5C6BC0).withOpacity(0.8),
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                Center(
                  child: Text(
                    'Create Account ✨',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 22),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Sign up to discover amazing events for kids!',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 28),

                // Full Name
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration(
                    hint: 'Full Name',
                    icon: Icons.person_outline,
                  ),
                  style: GoogleFonts.poppins(fontSize: 14),
                ),

                const SizedBox(height: 14),

                // Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    hint: 'Email Address',
                    icon: Icons.email_outlined,
                  ),
                  style: GoogleFonts.poppins(fontSize: 14),
                ),

                const SizedBox(height: 14),

                // Phone
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration(
                    hint: 'Phone Number',
                    icon: Icons.phone_outlined,
                  ),
                  style: GoogleFonts.poppins(fontSize: 14),
                ),

                const SizedBox(height: 14),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _inputDecoration(
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    suffix: GestureDetector(
                      onTap: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                  style: GoogleFonts.poppins(fontSize: 14),
                ),

                const SizedBox(height: 14),

                // Confirm Password
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  decoration: _inputDecoration(
                    hint: 'Confirm Password',
                    icon: Icons.lock_outline,
                    suffix: GestureDetector(
                      onTap: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      child: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                  style: GoogleFonts.poppins(fontSize: 14),
                ),

                const SizedBox(height: 16),

                // Terms checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreedToTerms,
                        onChanged: (val) =>
                            setState(() => _agreedToTerms = val ?? false),
                        activeColor: const Color(0xFFFFC107),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2196F3),
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2196F3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Sign Up button
                SizedBox(
                  width: double.infinity,
                  height: Responsive.h(context, 50, min: 44),
                  child: ElevatedButton(
                    onPressed: _onSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: const Color(0xFF1A1A2E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Sign Up',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // OR divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade400)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade400)),
                  ],
                ),

                const SizedBox(height: 18),

                // Continue with Google
                SizedBox(
                  width: double.infinity,
                  height: Responsive.h(context, 46, min: 40),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      AuthState.login(name: 'Google User');
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Signed in with Google!')),
                      );
                    },
                    icon: Text(
                      'G',
                      style: TextStyle(
                        fontSize: Responsive.sp(context, 18),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFFC107),
                      ),
                    ),
                    label: Text(
                      'Continue with Google',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Already have account? Login
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFFC107),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
