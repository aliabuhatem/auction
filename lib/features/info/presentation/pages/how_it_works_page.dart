// lib/features/info/presentation/pages/how_it_works_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../widgets/info_scaffold.dart';

/// Static "Hoe het werkt" page — the four steps exactly as on the live site.
class HowItWorksPage extends StatelessWidget {
  const HowItWorksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;

    return InfoScaffold(
      title: 'Hoe het werkt',
      children: [
        const InfoHeader(
          icon: Icons.workspace_premium_rounded,
          title: 'Bieden in 4 stappen',
          subtitle:
              'Maak gratis een account, plaats je bod en bepaal zelf je prijs. '
              'Zo simpel werkt het.',
        ),
        const InfoStepCard(
          number: 1,
          title: 'Meld je aan',
          body:
              'Maak gratis een account aan en log in. Klaar om mee te bieden?',
        ),
        const InfoStepCard(
          number: 2,
          title: 'Bied mee',
          body:
              'Veiling op het oog? Plaats het hoogste bod en sleep de veiling '
              'binnen. Hebbes!',
        ),
        const InfoStepCard(
          number: 3,
          title: 'Betaal je veiling',
          body:
              'Betaal je gewonnen veiling eenvoudig via iDEAL of met je '
              'creditcard.',
        ),
        const InfoStepCard(
          number: 4,
          title: 'Have fun',
          body:
              'Download je voucher of reserveer je veiling en geniet van je '
              'winst!',
        ),
        const SizedBox(height: AppDimensions.spaceS),
        if (!loggedIn)
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => context.go(AppRoutes.login),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
              ),
              child: const Text('Maak gratis een account aan'),
            ),
          ),
        const SizedBox(height: AppDimensions.spaceL),
        Center(
          child: TextButton(
            onPressed: () => context.push(AppRoutes.service),
            child: const Text(
              'Belangrijke info & klantenservice',
              style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
