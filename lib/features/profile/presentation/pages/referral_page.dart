// lib/features/profile/presentation/pages/referral_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';

class ReferralPage extends StatefulWidget {
  const ReferralPage({super.key});

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  String? _code;
  int _referred = 0;
  double _earned = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists) {
      setState(() => _loading = false);
      return;
    }
    final data = doc.data()!;

    String? code = data['referralCode'] as String?;
    if (code == null || code.isEmpty) {
      // Generate and persist a code.
      code = _generateCode(uid);
      await doc.reference.update({'referralCode': code});
    }

    // Count referrals.
    final refSnap = await FirebaseFirestore.instance
        .collection('referrals')
        .where('referrerId', isEqualTo: uid)
        .get();

    setState(() {
      _code = code;
      _referred = refSnap.docs.length;
      _earned = _referred * 5.0; // €5 per referral
      _loading = false;
    });
  }

  String _generateCode(String uid) {
    final base = uid.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    return base.length >= 6 ? base.substring(0, 6) : base.padRight(6, '0');
  }

  Future<void> _copy() async {
    if (_code == null) return;
    await Clipboard.setData(ClipboardData(text: _code!));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code gekopieerd!')),
      );
    }
  }

  void _share() {
    if (_code == null) return;
    Share.share(
      'Gebruik mijn code $_code bij Vakantieveilingen en ontvang €5 biedingstegoed! 🎉\n\nhttps://vakantieveilingen.nl',
      subject: 'Gratis €5 biedingstegoed',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vrienden uitnodigen')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Header illustration
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.people_alt_rounded,
                        size: 60,
                        color: AppColors.primaryRed,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Nodig vrienden uit!',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Jij én je vriend ontvangen €5 biedingstegoed\nzodra je vriend zich registreert.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textSecondary, height: 1.5),
                    ),

                    const SizedBox(height: 32),

                    // Referral code card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Jouw uitnodigingscode',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.primaryRed, width: 2),
                            ),
                            child: Text(
                              _code ?? '------',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 6,
                                color: AppColors.primaryRed,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _copy,
                                  icon:
                                      const Icon(Icons.copy_rounded, size: 18),
                                  label: const Text('Kopiëren'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _share,
                                  icon:
                                      const Icon(Icons.share_rounded, size: 18),
                                  label: const Text('Delen'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Stats row
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.group_rounded,
                            value: '$_referred',
                            label: 'Uitgenodigd',
                            color: AppColors.info,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.account_balance_wallet_rounded,
                            value: '€ ${_earned.toStringAsFixed(0)}',
                            label: 'Verdiend',
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // How it works
                    const _HowItWorks(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w900, color: color)),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  static const _steps = [
    _Step(
      number: '1',
      title: 'Deel je code',
      body:
          'Deel je persoonlijke code met vrienden via WhatsApp, mail of social media.',
    ),
    _Step(
      number: '2',
      title: 'Vriend registreert',
      body:
          'Je vriend downloadt de app en voert jouw code in tijdens de registratie.',
    ),
    _Step(
      number: '3',
      title: 'Beiden profiteren',
      body: 'Jullie ontvangen allebei €5 biedingstegoed. Bied mee en win!',
    ),
  ];

  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hoe werkt het?',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        ..._steps.map((s) => _StepTile(step: s)),
      ],
    );
  }
}

class _Step {
  final String number, title, body;
  const _Step({required this.number, required this.title, required this.body});
}

class _StepTile extends StatelessWidget {
  final _Step step;
  const _StepTile({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primaryRed,
              shape: BoxShape.circle,
            ),
            child: Text(step.number,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                Text(step.body,
                    style: const TextStyle(
                        color: AppColors.textSecondary, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
