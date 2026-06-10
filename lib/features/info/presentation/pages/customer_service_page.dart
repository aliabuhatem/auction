// lib/features/info/presentation/pages/customer_service_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../widgets/info_scaffold.dart';

/// Static "Klantenservice" page — FAQ accordion + contact actions.
class CustomerServicePage extends StatelessWidget {
  const CustomerServicePage({super.key});

  // Support contact details (mirrors config/app_settings.supportEmail/Phone).
  static const _supportEmail = 'klantenservice@vakantieveilingen.nl';
  static const _supportPhone = '+31880221700';

  static const _faqs = <(String, String)>[
    (
      'Hoe plaats ik een bod?',
      'Open een veiling, controleer het volgende bod en tik op "Bied nu". '
          'Bieden is gratis — je betaalt alleen als je de veiling wint.',
    ),
    (
      'Wat kost bieden?',
      'Bieden is volledig gratis. Je betaalt uitsluitend het winnende bod '
          'wanneer de veiling op jouw naam eindigt.',
    ),
    (
      'Hoe betaal ik mijn gewonnen veiling?',
      'Na afloop ontvang je een betaalverzoek. Reken veilig af via iDEAL of '
          'creditcard. Je hebt 24 uur om de betaling te voldoen.',
    ),
    (
      'Wanneer ontvang ik mijn voucher?',
      'Direct na een geslaagde betaling staat je voucher klaar onder '
          '"Mijn vouchers", inclusief QR-code om in te leveren.',
    ),
    (
      'Wat is een verlenging?',
      'Wordt er in de laatste minuten geboden, dan verlengt de veiling '
          'automatisch met enkele minuten. Zo krijgt iedereen een eerlijke kans.',
    ),
    (
      'Moet ik reserveren?',
      'Sommige vouchers vereisen een reservering. Dit staat duidelijk vermeld '
          'op de voucher, inclusief de link om te reserveren.',
    ),
  ];

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return InfoScaffold(
      title: 'Klantenservice',
      children: [
        const InfoHeader(
          icon: Icons.support_agent_rounded,
          title: 'Waarmee kunnen we je helpen?',
          subtitle:
              'Bekijk de veelgestelde vragen of neem direct contact met ons op.',
        ),
        Text(
          'Veelgestelde vragen',
          style: TextStyle(
            fontSize: AppDimensions.fontTitle,
            fontWeight: FontWeight.w700,
            color: onSurface,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceL),
        for (final faq in _faqs)
          InfoFaqItem(question: faq.$1, answer: faq.$2),
        const SizedBox(height: AppDimensions.spaceL),
        Text(
          'Direct contact',
          style: TextStyle(
            fontSize: AppDimensions.fontTitle,
            fontWeight: FontWeight.w700,
            color: onSurface,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceL),
        InfoActionTile(
          icon: Icons.mail_outline_rounded,
          label: 'E-mail ons',
          value: _supportEmail,
          onTap: () => _launch(Uri(scheme: 'mailto', path: _supportEmail)),
        ),
        InfoActionTile(
          icon: Icons.phone_outlined,
          label: 'Bel ons',
          value: _supportPhone,
          onTap: () => _launch(Uri(scheme: 'tel', path: _supportPhone)),
        ),
        const SizedBox(height: AppDimensions.spaceL),
        Text(
          'Meer informatie',
          style: TextStyle(
            fontSize: AppDimensions.fontTitle,
            fontWeight: FontWeight.w700,
            color: onSurface,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceL),
        InfoActionTile(
          icon: Icons.help_outline_rounded,
          label: 'Hoe het werkt',
          onTap: () => context.push(AppRoutes.howItWorks),
        ),
        InfoActionTile(
          icon: Icons.privacy_tip_outlined,
          label: 'Privacybeleid',
          onTap: () => context.push(AppRoutes.privacy),
        ),
        InfoActionTile(
          icon: Icons.description_outlined,
          label: 'Algemene voorwaarden',
          onTap: () => context.push(AppRoutes.terms),
        ),
      ],
    );
  }
}
