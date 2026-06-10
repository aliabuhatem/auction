// lib/features/info/presentation/pages/privacy_page.dart
import 'package:flutter/material.dart';
import '../widgets/info_scaffold.dart';

/// Static "Privacy" page.
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoScaffold(
      title: 'Privacy',
      children: [
        InfoHeader(
          icon: Icons.lock_outline_rounded,
          title: 'Privacybeleid',
          subtitle:
              'Wij gaan zorgvuldig om met jouw gegevens. Hieronder lees je hoe '
              'we persoonsgegevens verzamelen, gebruiken en beschermen.',
        ),
        InfoSection(
          title: 'Welke gegevens verzamelen we?',
          body:
              'We verwerken de gegevens die je zelf opgeeft bij het aanmaken van '
              'een account (naam, e-mailadres, telefoonnummer) en gegevens over '
              'je biedingen, bestellingen en vouchers. Daarnaast verzamelen we '
              'technische gegevens om de app goed te laten werken.',
        ),
        InfoSection(
          title: 'Waarvoor gebruiken we je gegevens?',
          body:
              'Je gegevens worden gebruikt om biedingen te verwerken, betalingen '
              'af te handelen, vouchers te leveren en je op de hoogte te houden '
              'van veilingen waarop je biedt. Met jouw toestemming sturen we je '
              'ook relevante aanbiedingen en de nieuwsbrief.',
        ),
        InfoSection(
          title: 'Meldingen',
          body:
              'Push-meldingen ontvang je alleen wanneer je daarvoor toestemming '
              'geeft. Je kunt meldingen op elk moment beheren via je '
              'instellingen of de instellingen van je toestel.',
        ),
        InfoSection(
          title: 'Je rechten',
          body:
              'Je hebt het recht om je gegevens in te zien, te corrigeren of te '
              'laten verwijderen. Dit kan via "Mijn gegevens" in de app of door '
              'contact op te nemen met de klantenservice.',
        ),
        InfoSection(
          title: 'Beveiliging',
          body:
              'We nemen passende technische en organisatorische maatregelen om '
              'je gegevens te beschermen tegen verlies en onbevoegde toegang. '
              'Betalingen verlopen versleuteld via onze betaalpartner Mollie.',
        ),
      ],
    );
  }
}
