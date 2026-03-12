import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/admin_auth_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../app/app_router.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});
  @override State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey      = GlobalKey<FormState>();
  bool  _showPassword = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AdminAuthBloc>().add(AdminLoginRequested(
      email:    _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: BlocListener<AdminAuthBloc, AdminAuthState>(
        listener: (context, state) {
          if (state is AdminAuthenticated) {
            context.go(AppRoutes.adminDashboard);
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color:        AppColors.primaryRed,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: AppColors.primaryRed.withOpacity(0.4), blurRadius: 24, offset: const Offset(0,8))],
                    ),
                    child: const Icon(Icons.gavel_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 20),
                  const Text('Vakantieveilingen',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Admin Dashboard',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                  const SizedBox(height: 40),

                  // Card
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color:        const Color(0xFF1A1D27),
                      borderRadius: BorderRadius.circular(24),
                      border:       Border.all(color: Colors.white.withOpacity(0.07)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Inloggen',
                            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 20),

                          // Email
                          _label('E-mailadres'),
                          _field(
                            controller:  _emailCtrl,
                            hint:        'admin@vakantieveilingen.nl',
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) =>
                              (v == null || !v.contains('@')) ? 'Voer een geldig e-mailadres in' : null,
                          ),
                          const SizedBox(height: 16),

                          // Password
                          _label('Wachtwoord'),
                          _field(
                            controller: _passwordCtrl,
                            hint:       '••••••••',
                            obscure:    !_showPassword,
                            suffix:     IconButton(
                              icon: Icon(
                                _showPassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white30, size: 18,
                              ),
                              onPressed: () => setState(() => _showPassword = !_showPassword),
                            ),
                            validator: (v) =>
                              (v == null || v.length < 6) ? 'Wachtwoord te kort' : null,
                          ),
                          const SizedBox(height: 8),

                          // Error
                          BlocBuilder<AdminAuthBloc, AdminAuthState>(
                            builder: (context, state) {
                              if (state is AdminAuthError) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:        Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border:       Border.all(color: Colors.red.withOpacity(0.3)),
                                  ),
                                  child: Row(children: [
                                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(state.message,
                                      style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
                                  ]),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          const SizedBox(height: 8),

                          // Submit button
                          BlocBuilder<AdminAuthBloc, AdminAuthState>(
                            builder: (context, state) {
                              final loading = state is AdminAuthLoading;
                              return SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: loading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryRed,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: loading
                                    ? const SizedBox(width: 20, height: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text('Inloggen',
                                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Alleen bevoegd personeel heeft toegang',
                    style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(
      color: Color(0xFF8B9CB6), fontSize: 11, fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
    )),
  );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller:   controller,
        obscureText:  obscure,
        keyboardType: keyboardType,
        validator:    validator,
        style:        const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText:      hint,
          hintStyle:     const TextStyle(color: Color(0xFF3D4556), fontSize: 14),
          suffixIcon:    suffix,
          filled:        true,
          fillColor:     const Color(0xFF0F1117),
          border:        OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:   const BorderSide(color: Color(0xFF2A2D3A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:   const BorderSide(color: Color(0xFF2A2D3A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:   const BorderSide(color: AppColors.primaryRed, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:   const BorderSide(color: Colors.redAccent),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          errorStyle: const TextStyle(fontSize: 11),
        ),
      );
}
