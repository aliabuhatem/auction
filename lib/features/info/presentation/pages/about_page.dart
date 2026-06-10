// lib/features/info/presentation/pages/about_page.dart
import 'package:flutter/material.dart';
import '../widgets/info_scaffold.dart';

/// Static "Over ons" page.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoScaffold(
      title: 'Over ons',
      children: [
        InfoHeader(
          icon: Icons.diamond_outlined,
          title: 'Bied mee en bepaal zelf je prijs',
          subtitle:
              'Wij brengen elke dag de mooiste belevenissen, vakanties en '
              'producten naar je toe — voor een prijs die jij bepaalt.',
        ),
        InfoSection(
          title: 'Onze missie',
          body:
              'Wij geloven dat genieten niet duur hoeft te zijn. Daarom veilen '
              'we dagelijks dagjes uit, hotels, wellness, vakanties en topproducten '
              'tegen scherpe prijzen. Door mee te bieden bepaal je zelf wat je '
              'betaalt en maak je kans op flinke kortingen.',
        ),
        InfoSection(
          title: 'Hoe het begon',
          body:
              'Wat begon als een klein platform voor scherpe deals, groeide uit '
              'tot een van de bekendste veilingsites van Nederland. Inmiddels '
              'vertrouwen honderdduizenden bieders ons elke dag opnieuw.',
        ),
        InfoSection(
          title: 'Veilig & betrouwbaar',
          body:
              'Betalen doe je veilig via Mollie met iDEAL of creditcard. Al onze '
              'aanbieders worden zorgvuldig geselecteerd, zodat je altijd kunt '
              'rekenen op kwaliteit en service.',
        ),
        InfoSection(
          title: 'Vragen?',
          body:
              'Ons klantenserviceteam staat voor je klaar. Bekijk de '
              'veelgestelde vragen of neem direct contact met ons op via de '
              'klantenservicepagina.',
        ),
      ],
    );
  }
}
