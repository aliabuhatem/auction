// lib/features/auth/presentation/pages/onboarding_page.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../app/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  static const _slideCount = 3;

  static const _slideGradients = [
    [AppColors.primaryRed, AppColors.primaryDark],
    [Color(0xFF0F3460), Color(0xFF16213E)],
    [Color(0xFF2ECC71), Color(0xFF27AE60)],
  ];

  static const _slideIcons = [
    Icons.gavel_rounded,
    Icons.timer_rounded,
    Icons.emoji_events_rounded,
  ];

  List<_Slide> _slides(BuildContext ctx) => [
    _Slide(
      icon:     _slideIcons[0],
      title:    AppStrings.onboard1Title(ctx),
      body:     AppStrings.onboard1Body(ctx),
      gradient: _slideGradients[0],
    ),
    _Slide(
      icon:     _slideIcons[1],
      title:    AppStrings.onboard2Title(ctx),
      body:     AppStrings.onboard2Body(ctx),
      gradient: _slideGradients[1],
    ),
    _Slide(
      icon:     _slideIcons[2],
      title:    AppStrings.onboard3Title(ctx),
      body:     AppStrings.onboard3Body(ctx),
      gradient: _slideGradients[2],
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    // Request FCM permission on page 3 completion.
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);

    if (mounted) context.go(AppRoutes.login);
  }

  void _next() {
    if (_page < _slideCount - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _skip() => _finish();

  @override
  Widget build(BuildContext context) {
    final slides = _slides(context);
    final isLast = _page == slides.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          // Slides
          PageView.builder(
            controller: _controller,
            itemCount: slides.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _SlideView(slide: slides[i]),
          ),

          // Skip button (hidden on last slide)
          if (!isLast)
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: _skip,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white24,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(AppStrings.skip(context),
                        style: const TextStyle(fontSize: 13)),
                  ),
                ),
              ),
            ),

          // Bottom controls
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Page indicator
                    AnimatedSmoothIndicator(
                      activeIndex: _page,
                      count: slides.length,
                      effect: const WormEffect(
                        dotWidth: 8,
                        dotHeight: 8,
                        activeDotColor: Colors.white,
                        dotColor: Colors.white38,
                        spacing: 8,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // CTA button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: slides[_page].gradient.first,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        child: Text(isLast
                            ? AppStrings.getStarted(context)
                            : AppStrings.next(context)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Slide {
  final IconData icon;
  final String title;
  final String body;
  final List<Color> gradient;
  const _Slide({
    required this.icon,
    required this.title,
    required this.body,
    required this.gradient,
  });
}

class _SlideView extends StatelessWidget {
  final _Slide slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: slide.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Icon container
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(slide.icon, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 48),
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                slide.body,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
              // Space for bottom controls
              const SizedBox(height: 160),
            ],
          ),
        ),
      ),
    );
  }
}
