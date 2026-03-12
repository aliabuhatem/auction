import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _name     = TextEditingController();
  final _email    = TextEditingController();
  final _password = TextEditingController();
  final _confirm  = TextEditingController();
  final _formKey  = GlobalKey<FormState>();
  bool _obscure   = true;

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _password.dispose(); _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: const BackButton(color: AppColors.textPrimary)),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (ctx, state) {
          if (state is AuthAuthenticated) ctx.go('/home');
          if (state is AuthError) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.createAccount(context),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(AppStrings.registerSubtitle(context), style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(labelText: AppStrings.name(context), prefixIcon: const Icon(Icons.person_outline)),
                  validator: (v) => v!.trim().isNotEmpty ? null : AppStrings.fieldRequired(context),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: AppStrings.email(context), prefixIcon: const Icon(Icons.email_outlined)),
                  validator: (v) => v!.contains('@') ? null : AppStrings.emailInvalid(context),
                ),
                const SizedBox(height: 16),
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
                  validator: (v) => v!.length >= 6 ? null : AppStrings.passwordTooShort(context),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirm,
                  obscureText: true,
                  decoration: InputDecoration(labelText: AppStrings.confirmPassword(context), prefixIcon: const Icon(Icons.lock_outlined)),
                  validator: (v) => v == _password.text ? null : AppStrings.passwordsNoMatch(context),
                ),
                const SizedBox(height: 32),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) => SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: state is AuthLoading ? null : _submit,
                      child: state is AuthLoading
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          : Text(AppStrings.register(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: Text(AppStrings.hasAccount(context)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(RegisterRequested(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      ));
    }
  }
}
