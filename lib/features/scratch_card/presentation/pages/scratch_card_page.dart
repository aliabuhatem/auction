import 'package:flutter/material.dart';
import 'package:scratcher/scratcher.dart';
import 'package:confetti/confetti.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import 'package:share_plus/share_plus.dart';

class ScratchCardPage extends StatefulWidget {
  const ScratchCardPage({super.key});
  @override
  State<ScratchCardPage> createState() => _ScratchCardPageState();
}

class _ScratchCardPageState extends State<ScratchCardPage> {
  final _confettiController = ConfettiController(duration: const Duration(seconds: 4));
  final _scratchKey = GlobalKey<ScratcherState>();
  bool _revealed = false;
  String _prize = '€5 tegoed';
  final int _streakDays = 3;
  final bool _canScratch = true;

  static const _prizes = ['€5 tegoed', '€10 tegoed', 'Gratis veiling', 'Extra kraskaart', '€2 tegoed'];

  @override
  void initState() {
    super.initState();
    _prizes.shuffle();
    _prize = _prizes.first;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(AppStrings.scratchCard, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Star background
          Positioned.fill(child: _buildBackground()),
          // Content
          Column(
            children: [
              const SizedBox(height: 16),
              _buildStreakCounter(),
              const SizedBox(height: 32),
              // Scratch card
              Center(child: _buildScratchCard()),
              const SizedBox(height: 32),
              if (!_revealed) ...[
                const Text(AppStrings.scratchToReveal, style: TextStyle(color: Colors.white70, fontSize: 15)),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => Share.share('Probeer Vakantieveilingen! Download de app en win geweldige prijzen.'),
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: const Text(AppStrings.shareForExtra, style: TextStyle(color: Colors.white)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white30), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                ),
              ] else ...[
                const Text(AppStrings.congratulations, style: TextStyle(color: AppColors.accentGold, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Je hebt $_prize gewonnen!', style: const TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: () {}, child: const Text('Prijs claimen')),
              ],
            ],
          ),
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 40,
              colors: const [AppColors.primaryRed, AppColors.accentGold, Colors.white, Colors.blue],
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
        boxShadow: [BoxShadow(color: AppColors.accentGold.withOpacity(0.5), blurRadius: 30, spreadRadius: 2)],
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
                  if (v >= 45 && !_revealed) {
                    setState(() => _revealed = true);
                    _confettiController.play();
                  }
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
          Text(_prize, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildCantScratch() {
    return Container(
      color: Colors.grey[800],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule, color: Colors.white54, size: 48),
          SizedBox(height: 12),
          Text(AppStrings.comeBackTomorrow, textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildStreakCounter() {
    return Column(
      children: [
        const Text(AppStrings.streakTitle, style: TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(7, (i) {
            final done = i < _streakDays;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? AppColors.accentGold : Colors.white10,
                boxShadow: done ? [BoxShadow(color: AppColors.accentGold.withOpacity(0.5), blurRadius: 8)] : null,
              ),
              child: Center(child: Text('${i + 1}', style: TextStyle(color: done ? Colors.black : Colors.white30, fontWeight: FontWeight.bold, fontSize: 13))),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBackground() {
    return CustomPaint(painter: _StarPainter());
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.08);
    for (int i = 0; i < 50; i++) {
      final x = (i * 73.7 + 10) % size.width;
      final y = (i * 137.3 + 20) % size.height;
      canvas.drawCircle(Offset(x, y), (i % 3 + 1).toDouble(), paint);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}
