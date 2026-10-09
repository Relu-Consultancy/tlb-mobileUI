import 'package:flutter/material.dart';

import '../widgets/whatsapp_auth_card.dart';
import 'home_screen.dart';
import 'otp_verification_screen.dart';
import 'whatsapp_login_screen.dart';

/// Create an account with a WhatsApp number: the 6-digit code is sent on
/// WhatsApp and the account is created when it is verified.
///
/// A separate screen from the email sign-up — that one is unchanged.
class WhatsAppSignupScreen extends StatelessWidget {
  const WhatsAppSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WhatsAppAuthCard(
      title: 'Signup with WhatsApp',
      subtitle: "We'll send a 6-digit code to your WhatsApp.",
      purpose: 'register',
      onSent: (phone) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            identifier: phone,
            identifierType: 'phone',
            // A number that is already registered just signs in. New
            // accounts are handled inside OtpVerificationScreen (→ welcome,
            // then profile setup).
            onExistingUser: (ctx) => Navigator.of(ctx).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            ),
          ),
        ),
      ),
      switchPrompt: 'Already have an account? ',
      switchAction: 'Login with WhatsApp',
      onSwitch: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WhatsAppLoginScreen()),
      ),
    );
  }
}
