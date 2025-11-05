import 'package:flutter/material.dart';
import 'package:calorie_calculator/core/utils/locale_service.dart';
import "package:calorie_calculator/l10n/app_localizations.dart";
import '../../auth/data/user_dao.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  void _toggleLanguage() {
    final current = Localizations.localeOf(context).languageCode;
    final next = current == 'ar' ? const Locale('en') : const Locale('ar');
    LocaleService.instance.setLocale(next);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final ok = await UserDao.instance.validateLogin(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      if (ok) {
        final t = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.auth_logged_in)));
        Navigator.pushReplacementNamed(context, '/app');
      } else {
        final t = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.auth_invalid_credentials)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToSignup() {
    Navigator.pushNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Center the form in the middle of the screen
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ...existing code...
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: colorScheme.primary.withValues(
                                  alpha: 0.15,
                                ),
                                child: Icon(
                                  Icons.local_hospital,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.auth_login_title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      t.auth_login_subtitle,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // ...existing code...
                          TextFormField(
                            controller: _emailCtrl,
                            decoration: InputDecoration(
                              labelText: t.auth_email_label,
                              hintText: t.auth_email_hint,
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return t.form_email_required;
                              }
                              final email = RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              );
                              if (!email.hasMatch(v)) {
                                return t.form_email_invalid;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          // ...existing code...
                          TextFormField(
                            controller: _passwordCtrl,
                            decoration: InputDecoration(
                              labelText: t.auth_password_label,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                tooltip: _obscure
                                    ? t.auth_password_show
                                    : t.auth_password_hide,
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            obscureText: _obscure,
                            textInputAction: TextInputAction.done,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return t.form_password_required;
                              }
                              if (v.length < 6) return t.form_password_min;
                              return null;
                            },
                            onFieldSubmitted: (_) => _onLogin(),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (v) =>
                                    setState(() => _rememberMe = v ?? false),
                              ),
                              Text(t.auth_remember_me),
                              const Spacer(),
                              TextButton(
                                onPressed: () {},
                                child: Text(t.auth_forgot_password),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 52,
                            child: FilledButton.icon(
                              onPressed: _isLoading ? null : _onLogin,
                              icon: _isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        valueColor: AlwaysStoppedAnimation(
                                          colorScheme.onPrimary,
                                        ),
                                      ),
                                    )
                                  : const Icon(Icons.login),
                              label: Text(
                                _isLoading ? t.auth_signing_in : t.auth_sign_in,
                              ),
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(t.auth_no_account),
                              TextButton(
                                onPressed: _goToSignup,
                                child: Text(t.auth_create_one),
                              ),
                            ],
                          ),
                          // Reserve space so bottom language button doesn't overlap
                          const SizedBox(height: 84),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Bottom language button that stays visible above keyboard
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: OutlinedButton.icon(
                onPressed: _toggleLanguage,
                icon: const Icon(Icons.language),
                label: Text(
                  Localizations.localeOf(context).languageCode == 'ar'
                      ? 'English'
                      : 'العربية',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
