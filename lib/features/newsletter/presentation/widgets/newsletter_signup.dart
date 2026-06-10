// lib/features/newsletter/presentation/widgets/newsletter_signup.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../injection_container.dart' as di;
import '../../data/newsletter_datasource.dart';

/// Self-contained newsletter signup card (home Section 10). Validates the email,
/// writes to the `newsletters` collection, and swaps to a success state.
class NewsletterSignup extends StatefulWidget {
  final String source;
  const NewsletterSignup({super.key, this.source = 'home'});

  @override
  State<NewsletterSignup> createState() => _NewsletterSignupState();
}

class _NewsletterSignupState extends State<NewsletterSignup> {
  final _controller = TextEditingController();
  bool _submitting = false;
  bool _done = false;
  String? _error;

  static final _emailRegex =
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _controller.text.trim();
    if (!_emailRegex.hasMatch(email)) {
      setState(() => _error = AppStrings.emailInvalid(context));
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await di.sl<NewsletterDatasource>().subscribe(email, source: widget.source);
      if (mounted) setState(() => _done = true);
    } catch (_) {
      if (mounted) {
        setState(() => _error = AppStrings.sendError(context));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: AppColors.luxuryGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: AppColors.goldGlow(opacity: 0.25),
      ),
      child: _done ? _success(context) : _form(context),
    );
  }

  Widget _success(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.mark_email_read_rounded,
            color: AppColors.textOnGold, size: AppDimensions.iconL),
        const SizedBox(width: AppDimensions.spaceL),
        Expanded(
          child: Text(
            AppStrings.newsletterSuccess(context),
            style: const TextStyle(
              color: AppColors.textOnGold,
              fontWeight: FontWeight.w700,
              fontSize: AppDimensions.fontL,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _form(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.newsletterTitle(context),
          style: const TextStyle(
            color: AppColors.textOnGold,
            fontWeight: FontWeight.w800,
            fontSize: AppDimensions.fontTitle,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceXS),
        Text(
          AppStrings.newsletterSubtitle(context),
          style: TextStyle(
            color: AppColors.textOnGold.withValues(alpha: 0.85),
            fontSize: AppDimensions.fontM,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceL),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                enabled: !_submitting,
                onSubmitted: (_) => _submit(),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  hintText: AppStrings.emailHintNewsletter(context),
                  hintStyle: const TextStyle(color: AppColors.textHint),
                  errorText: _error,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceL,
                      vertical: AppDimensions.spaceM),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spaceS),
            SizedBox(
              height: AppDimensions.buttonHeightS,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.nearBlack,
                  foregroundColor: AppColors.textOnDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.textOnDark),
                      )
                    : Text(AppStrings.newsletterCta(context)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
