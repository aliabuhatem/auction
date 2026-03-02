import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
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
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) context.go('/home');
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
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
                    const Text(AppStrings.appName,
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.textPrimary)),
                  ]),
                  const SizedBox(height: 40),
                  Text(AppStrings.welcomeBack,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  const Text(AppStrings.loginSubtitle, style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 32),
                  // Email
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: AppStrings.email, prefixIcon: Icon(Icons.email_outlined)),
                    validator: (v) => v!.contains('@') ? null : AppStrings.emailInvalid,
                  ),
                  const SizedBox(height: 16),
                  // Password
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: AppStrings.password,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => v!.length >= 6 ? null : AppStrings.passwordTooShort,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: () {}, child: const Text(AppStrings.forgotPassword)),
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
                            : const Text(AppStrings.login, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Divider
                  const Row(children: [
                    Expanded(child: Divider()),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text(AppStrings.continueWith, style: TextStyle(color: Colors.grey))),
                    Expanded(child: Divider()),
                  ]),
                  const SizedBox(height: 16),
                  // Google
                  OutlinedButton.icon(
                    onPressed: () => context.read<AuthBloc>().add(GoogleLoginRequested()),
                    icon: const Icon(Icons.g_mobiledata, size: 24, color: Colors.red),
                    label: const Text(AppStrings.google),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, AppDimensions.buttonHeight)),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: TextButton(
                      onPressed: () => context.push('/auth/register'),
                      child: const Text(AppStrings.noAccount),
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
}
