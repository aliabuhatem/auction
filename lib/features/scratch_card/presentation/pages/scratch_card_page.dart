import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scratcher/scratcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/scratch_card_repository.dart';

class ScratchCardPage extends StatefulWidget {
  const ScratchCardPage({super.key});
  @override
  State<ScratchCardPage> createState() => _ScratchCardPageState();
}

class _ScratchCardPageState extends State<ScratchCardPage> {
  final _confettiController =
      ConfettiController(duration: const Duration(seconds: 4));
  final _scratchKey = GlobalKey<ScratcherState>();

  bool _revealed = false;
  bool _claimed = false;
  bool _loading = true;
  bool _claiming = false;

  String _prize = '';
  int _streakDays = 0;
  bool _canScratch = false;
  String? _userId;

  late final ScratchCardRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = di.sl<ScratchCardRepository>();
    _loadCard();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadCard() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      setState(() => _loading = false);
      return;
    }
    _userId = auth.user.id;
    final result = await _repo.getScratchCardData(_userId!);
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _loading = false),
      (data) => setState(() {
        _canScratch = data['canScratch'] as bool? ?? false;
        _streakDays = data['streakDays'] as int? ?? 0;
        _loading = false;
      }),
    );
  }

  Future<void> _onScratched() async {
    if (_revealed || _userId == null) return;

    // Fetch real prize from repository
    final result = await _repo.revealPrize(_userId!);
    if (!mounted) return;
    result.fold(
      (_) {
        final fallback = ['€5 tegoed', '€2 tegoed', 'Extra kraskaart'];
        fallback.shuffle();
        setState(() {
          _prize = fallback.first;
          _revealed = true;
        });
      },
      (prize) => setState(() {
        _prize = prize;
        _revealed = true;
      }),
    );
    _confettiController.play();
  }

  Future<void> _claimPrize() async {
    if (_userId == null || _claiming || _claimed) return;
    setState(() => _claiming = true);

    final result = await _repo.recordScratch(_userId!, _prize);
    if (!mounted) return;
    result.fold(
      (f) {
        setState(() => _claiming = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Fout: ${f.message}'), backgroundColor: Colors.red),
        );
      },
      (_) {
        setState(() {
          _claiming = false;
          _claimed = true;
          _streakDays++;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 $_prize is toegevoegd aan je wallet!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppStrings.scratchCard(context),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _StarPainter())),
          if (_loading)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else
            Column(
              children: [
                const SizedBox(height: 16),
                _buildStreakCounter(),
                const SizedBox(height: 32),
                Center(child: _buildScratchCard()),
                const SizedBox(height: 32),
                if (!_revealed) ...[
                  Text(
                    _canScratch
                        ? AppStrings.scratchToReveal(context)
                        : AppStrings.comeBackTomorrow(context),
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => Share.share(
                        'Probeer Vakantieveilingen! Download de app en win geweldige prijzen.'),
                    icon:
                        const Icon(Icons.share, color: Colors.white, size: 20),
                    label: Text(
                      AppStrings.shareForExtra(context),
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ] else ...[
                  Text(
                    AppStrings.congratulations(context),
                    style: const TextStyle(
                        color: AppColors.accentGold,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Je hebt $_prize gewonnen!',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  if (_claimed)
                    const Chip(
                      label: Text('Tegoed ontvangen',
                          style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.green,
                    )
                  else
                    ElevatedButton(
                      onPressed: _claiming ? null : _claimPrize,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _claiming
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Text(AppStrings.claimPrize(context)),
                    ),
                ],
              ],
            ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 40,
              colors: const [
                AppColors.primaryRed,
                AppColors.accentGold,
                Colors.white,
                Colors.blue,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScratchCard() {
    return Container(
      width: 290,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentGold.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _canScratch
            ? Scratcher(
                key: _scratchKey,
                brushSize: 35,
                threshold: 45,
                color: const Color(0xFFFFD700),
                onChange: (v) {
                  if (v >= 45 && !_revealed) _onScratched();
                },
                child: _buildPrizeContent(),
              )
            : _buildCantScratch(),
      ),
    );
  }

  Widget _buildPrizeContent() {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            _prize.isEmpty ? '???' : _prize,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildCantScratch() {
    return Container(
      color: Colors.grey[800],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.schedule, color: Colors.white54, size: 48),
          const SizedBox(height: 12),
          Text(
            AppStrings.comeBackTomorrow(context),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCounter() {
    return Column(
      children: [
        Text(
          AppStrings.streakTitle(context),
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(7, (i) {
            final done = i < _streakDays;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? AppColors.accentGold : Colors.white10,
                boxShadow: done
                    ? [
                        BoxShadow(
                          color: AppColors.accentGold.withValues(alpha: 0.5),
                          blurRadius: 8,
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    color: done ? Colors.black : Colors.white30,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.08);
    for (int i = 0; i < 50; i++) {
      final x = (i * 73.7 + 10) % size.width;
      final y = (i * 137.3 + 20) % size.height;
      canvas.drawCircle(Offset(x, y), (i % 3 + 1).toDouble(), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
