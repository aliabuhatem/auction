import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/auth_bloc.dart';
import '../../../../app/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email    = TextEditingController();
  final _password = TextEditingController();
  final _formKey  = GlobalKey<FormState>();
  bool _obscure   = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthAuthenticated) {
            final prefs = await SharedPreferences.getInstance();
            final done  = prefs.getBool('onboarding_done') ?? false;
            if (!context.mounted) return;
            context.go(done ? AppRoutes.home : AppRoutes.onboarding);
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.primaryRed, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.gavel, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Text(AppStrings.appName(context),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.textPrimary)),
                  ]),
                  const SizedBox(height: 40),
                  Text(AppStrings.welcomeBack(context),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(AppStrings.loginSubtitle(context), style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 32),
                  // Email
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: AppStrings.email(context), prefixIcon: const Icon(Icons.email_outlined)),
                    validator: (v) => v!.contains('@') ? null : AppStrings.emailInvalid(context),
                  ),
                  const SizedBox(height: 16),
                  // Password
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: AppStrings.password(context),
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => v!.length >= 8 ? null : AppStrings.passwordTooShort(context),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: _forgotPassword, child: Text(AppStrings.forgotPassword(context))),
                  ),
                  const SizedBox(height: 8),
                  // Login button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) => SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        onPressed: state is AuthLoading ? null : _submit,
                        child: state is AuthLoading
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            : Text(AppStrings.login(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Divider
                  Row(children: [
                    const Expanded(child: Divider()),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(AppStrings.continueWith(context), style: const TextStyle(color: Colors.grey))),
                    const Expanded(child: Divider()),
                  ]),
                  const SizedBox(height: 16),
                  // Google
                  OutlinedButton.icon(
                    onPressed: () => context.read<AuthBloc>().add(GoogleLoginRequested()),
                    icon: const Icon(Icons.g_mobiledata, size: 24, color: Colors.red),
                    label: Text(AppStrings.google(context)),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, AppDimensions.buttonHeight)),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: TextButton(
                      onPressed: () => context.push('/auth/register'),
                      child: Text(AppStrings.noAccount(context)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(LoginRequested(email: _email.text.trim(), password: _password.text));
    }
  }

  Future<void> _forgotPassword() async {
    final emailCtrl = TextEditingController(text: _email.text.trim());
    // Pre-compute ALL strings and messenger before any await.
    final dialogTitle   = AppStrings.forgotPasswordTitle(context);
    final emailLabel    = AppStrings.email(context);
    final cancelLabel   = AppStrings.cancel(context);
    final sendLabel     = AppStrings.sendBtn(context);
    final successMsg    = AppStrings.resetLinkSentMsg(context);
    final errorFallback = AppStrings.sendError(context);
    final messenger     = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(dialogTitle),
        content: TextField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: emailLabel,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(sendLabel),
          ),
        ],
      ),
    );

    if (confirmed != true || emailCtrl.text.trim().isEmpty) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailCtrl.text.trim());
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(successMsg), backgroundColor: AppColors.success),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(e.message ?? errorFallback), backgroundColor: AppColors.error),
        );
      }
    }
  }
}
