import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/auth_state.dart';
import 'home_screen.dart';

class SignupOtpScreen extends StatefulWidget {
  final String email;
  final String phone;

  const SignupOtpScreen({
    super.key,
    required this.email,
    required this.phone,
  });

  @override
  State<SignupOtpScreen> createState() => _SignupOtpScreenState();
}

class _SignupOtpScreenState extends State<SignupOtpScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  int _resendSeconds = 30;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() => _resendSeconds = 30);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds <= 0) {
        timer.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onVerifyAndProceed() {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit OTP')),
      );
      return;
    }

    // OTP Verified, execute login
    AuthState.login(name: 'New User', phone: widget.phone);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification successful! Welcome to TLB.')),
    );

    // Clear navigation stack and go to Home
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E), size: 20),
            onPressed: () => Navigator.pop(context),
            splashRadius: 24,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Shield / OTP Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  size: 64,
                  color: AppColors.primaryLight, // #FFCC02
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Verify OTP',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                'We have sent a 6-digit verification code to',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.phone}\n${widget.email}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // OTP Digits Row
              LayoutBuilder(
                builder: (context, constraints) {
                  final boxW = ((constraints.maxWidth - 40) / 6).clamp(32.0, 48.0);
                  final boxH = (boxW * 1.18).clamp(38.0, 56.0);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: boxW,
                        height: boxH,
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _otpFocusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A2E),
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AppColors.primaryLight,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            if (val.isNotEmpty && index < 5) {
                              _otpFocusNodes[index + 1].requestFocus();
                            } else if (val.isEmpty && index > 0) {
                              _otpFocusNodes[index - 1].requestFocus();
                            }
                          },
                        ),
                      );
                    }),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Verify & Proceed Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _onVerifyAndProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Verify & Proceed',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Resend Text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive code? ",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  GestureDetector(
                    onTap: _resendSeconds == 0
                        ? () {
                            _startResendTimer();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('OTP sent again!')),
                            );
                          }
                        : null,
                    child: Text(
                      _resendSeconds == 0
                          ? 'Resend'
                          : 'Resend in ${_resendSeconds}s',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _resendSeconds == 0
                            ? AppColors.primaryLight
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
