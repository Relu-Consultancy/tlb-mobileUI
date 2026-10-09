import 'package:flutter/material.dart';

import '../widgets/login_sheet.dart' show showWelcomeBackDialog;
import '../widgets/whatsapp_auth_card.dart';
import 'otp_verification_screen.dart';
import 'whatsapp_signup_screen.dart';

/// Log in with a WhatsApp number: the 6-digit code is sent on WhatsApp.
///
/// A separate screen from the email login — that one is unchanged. An
/// unregistered number is refused (purpose `login`), not signed up.
class WhatsAppLoginScreen extends StatelessWidget {
  const WhatsAppLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WhatsAppAuthCard(
      title: 'Login with WhatsApp',
      subtitle: "We'll send a 6-digit code to your WhatsApp.",
      purpose: 'login',
      onSent: (phone) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            identifier: phone,
            identifierType: 'phone',
            onExistingUser: showWelcomeBackDialog,
            isLoginFlow: true,
          ),
        ),
      ),
      switchPrompt: 'New here? ',
      switchAction: 'Signup with WhatsApp',
      onSwitch: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WhatsAppSignupScreen()),
      ),
    );
  }
}
