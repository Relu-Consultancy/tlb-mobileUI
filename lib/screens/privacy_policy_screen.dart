import 'package:flutter/material.dart';
import '../widgets/legal_doc.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocScaffold(
      title: 'Privacy Policy',
      lastUpdated: 'Last updated on August 01, 2026',
      children: const [
        LegalParagraph(
          'TLB Technologies Private Limited and/or its affiliates ("TLB," '
          '"Company," "we," "us," and "our") respect your privacy and are '
          'committed to protecting it. This Privacy Policy describes:',
        ),
        LegalBullets([
          'The types of information TLB may collect from users who access or '
              'use its websites, mobile applications, and related services '
              '(collectively, the "Services"); and',
          'How TLB collects, uses, stores, protects, and shares such '
              'information.',
        ]),
        LegalParagraph(
          'This Privacy Policy applies only to information collected through '
          'TLB Services, including electronic communications sent through or '
          'in connection with the Services.',
        ),
        LegalParagraph(
          'This Privacy Policy does not apply to information collected by '
          'third parties, including merchants, vendors, event organizers, '
          'payment partners, or social media platforms that may be linked to '
          'or integrated with our Services. We encourage users to review the '
          'privacy policies of such third parties.',
        ),
        LegalParagraph(
          'By accessing or using TLB Services, you acknowledge and agree to '
          'the practices described in this Privacy Policy.',
        ),
        LegalHeading('Information We Collect'),
        LegalParagraph('We may collect the following categories of information:'),
        LegalSubheading('Personal Information'),
        LegalBullets([
          'Full name',
          'Email address',
          'Phone number',
          'Date of birth',
          'Billing and payment details',
          'Location information',
        ]),
        LegalSubheading('Usage Information'),
        LegalBullets([
          'Device and browser details',
          'IP address and approximate location',
          'Pages viewed and features used',
          'Booking and transaction history',
        ]),
        LegalHeading('How We Use Your Information'),
        LegalParagraph('We use the information we collect to:'),
        LegalBullets([
          'Provide, operate, and improve our Services',
          'Process bookings, payments, and confirmations',
          'Communicate updates, reminders, and offers',
          'Personalise your experience',
          'Ensure security and prevent fraud',
        ]),
        LegalHeading('Contact Us'),
        LegalParagraph(
          'If you have any questions about this Privacy Policy, please '
          'contact us at support@thelittlebroadway.com.',
        ),
      ],
    );
  }
}
