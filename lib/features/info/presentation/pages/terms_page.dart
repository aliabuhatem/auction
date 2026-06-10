// lib/features/info/presentation/pages/terms_page.dart
import 'package:flutter/material.dart';
import '../widgets/info_scaffold.dart';

/// Static "Algemene voorwaarden" page.
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoScaffold(
      title: 'Algemene voorwaarden',
      children: [
        InfoHeader(
          icon: Icons.gavel_rounded,
          title: 'Algemene voorwaarden',
          subtitle:
              'Door gebruik te maken van de app en mee te bieden, ga je akkoord '
              'met onderstaande voorwaarden.',
        ),
        InfoSection(
          title: '1. Bieden',
          body:
              'Een uitgebracht bod is bindend. Wie aan het einde van de veiling '
              'het hoogste bod heeft uitgebracht, wint de veiling en is verplicht '
              'tot afname. Bieden is gratis; je betaalt alleen het winnende bod.',
        ),
        InfoSection(
          title: '2. Verlenging',
          body:
              'Om sniping te voorkomen kan een veiling automatisch worden '
              'verlengd wanneer er in de laatste minuten wordt geboden. De op dat '
              'moment getoonde eindtijd is leidend.',
        ),
        InfoSection(
          title: '3. Betaling',
          body:
              'Gewonnen veilingen dienen binnen 24 uur te worden betaald via de '
              'aangeboden betaalmethoden. Bij niet-tijdige betaling vervalt de '
              'aanspraak op de veiling en kan deze worden geannuleerd.',
        ),
        InfoSection(
          title: '4. Vouchers',
          body:
              'Na betaling ontvang je een voucher met een geldigheidsduur die op '
              'de voucher staat vermeld. Vouchers zijn persoonsgebonden en kunnen '
              'niet worden ingewisseld voor contant geld.',
        ),
        InfoSection(
          title: '5. Reserveringen',
          body:
              'Voor bepaalde aanbiedingen is een reservering vereist. De '
              'beschikbaarheid is afhankelijk van de aanbieder. Reserveer tijdig '
              'om teleurstelling te voorkomen.',
        ),
        InfoSection(
          title: '6. Aansprakelijkheid',
          body:
              'Wij treden op als bemiddelaar tussen aanbieder en bieder. De '
              'uitvoering van de dienst of levering van het product valt onder de '
              'verantwoordelijkheid van de betreffende aanbieder.',
        ),
        InfoSection(
          title: '7. Wijzigingen',
          body:
              'Wij behouden ons het recht voor deze voorwaarden te wijzigen. De '
              'meest actuele versie is altijd via de app raadpleegbaar.',
        ),
      ],
    );
  }
}
