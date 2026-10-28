import 'package:flutter/material.dart';
import '../widgets/legal_doc.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocScaffold(
      title: 'Terms of Service',
      lastUpdated: 'Last updated on August 01, 2026',
      children: const [
        LegalHeading('Acceptance of Terms'),
        LegalParagraph(
          'These Terms of Service ("Terms") govern your access to and use of '
          'the TLB website, mobile application, and related services '
          '(collectively, the "Platform").',
        ),
        LegalParagraph(
          'By accessing or using the Platform, you agree to be bound by these '
          'Terms and enter into a legally binding agreement with TLB '
          'Technologies Private Limited ("TLB," "we," "us," or "our"). If you '
          'do not agree with these Terms, you must not use the Platform.',
        ),
        LegalHeading('Eligibility'),
        LegalParagraph(
          'You must be at least 18 years old, or the age of majority in your '
          'jurisdiction, to use certain features of the Platform.',
        ),
        LegalHeading('User Accounts'),
        LegalParagraph('When creating an account, you agree to:'),
        LegalBullets([
          'Provide accurate information',
          'Maintain the security of your credentials',
          'Notify us of unauthorized access',
          'Accept responsibility for activities conducted through your account',
        ]),
        LegalHeading('Services'),
        LegalParagraph('TLB may provide:'),
        LegalBullets([
          'Event discovery',
          'Ticket bookings',
          'Venue reservations',
          'Membership services',
          'Promotional campaigns',
          'Other digital experiences and offerings',
        ]),
        LegalHeading('Bookings & Payments'),
        LegalParagraph(
          'All bookings are subject to availability and confirmation. Prices, '
          'fees, and taxes are displayed at checkout and may change without '
          'notice. Payments are processed securely through our authorised '
          'payment partners.',
        ),
        LegalHeading('Cancellations & Refunds'),
        LegalParagraph(
          'Cancellation and refund eligibility depends on the policy of the '
          'specific listing or organizer. Please review the applicable policy '
          'before completing a booking.',
        ),
        LegalHeading('Contact Us'),
        LegalParagraph(
          'For any questions about these Terms, contact us at '
          'support@thelittlebroadway.com.',
        ),
      ],
    );
  }
}
