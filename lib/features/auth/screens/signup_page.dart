import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:calorie_calculator/core/utils/locale_service.dart';
import 'package:calorie_calculator/l10n/app_localizations.dart';
import 'package:calorie_calculator/features/auth/data/user_dao.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  void _toggleLanguage() {
    final current = Localizations.localeOf(context).languageCode;
    final next = current == 'ar' ? const Locale('en') : const Locale('ar');
    LocaleService.instance.setLocale(next);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSignup() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await UserDao.instance.createUser(
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.auth_account_created)));
      Navigator.pop(context); // back to Login
    } on DatabaseException catch (e) {
      final t = AppLocalizations.of(context)!;
      final msg = e.toString().contains('UNIQUE constraint failed')
          ? t.auth_email_in_use
          : t.auth_failed_create;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (_) {
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.auth_unexpected_error)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context)!;
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
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: colorScheme.primary.withValues(
                                  alpha: 0.15,
                                ),
                                child: Icon(
                                  Icons.person_add_alt,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.auth_signup_title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      t.auth_signup_subtitle,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              // Removed language toggle from header; moved to bottom for clarity
                            ],
                          ),
                          const SizedBox(height: 24),

                          TextFormField(
                            controller: _nameCtrl,
                            decoration: InputDecoration(
                              labelText: t.auth_full_name_label,
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (v) => (v == null || v.isEmpty)
                                ? t.form_name_required
                                : null,
                          ),
                          const SizedBox(height: 14),

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

                          TextFormField(
                            controller: _passwordCtrl,
                            decoration: InputDecoration(
                              labelText: t.auth_password_label,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                tooltip: _obscurePass
                                    ? t.auth_password_show
                                    : t.auth_password_hide,
                                icon: Icon(
                                  _obscurePass
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePass = !_obscurePass,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            obscureText: _obscurePass,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return t.form_password_required;
                              }
                              if (v.length < 6) return t.form_password_min;
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _confirmCtrl,
                            decoration: InputDecoration(
                              labelText: t.auth_confirm_password_label,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                tooltip: _obscureConfirm
                                    ? t.auth_password_show
                                    : t.auth_password_hide,
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            obscureText: _obscureConfirm,
                            textInputAction: TextInputAction.done,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return t.form_confirm_required;
                              }
                              if (v != _passwordCtrl.text) {
                                return t.form_passwords_no_match;
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _onSignup(),
                          ),

                          const SizedBox(height: 16),
                          SizedBox(
                            height: 52,
                            child: FilledButton.icon(
                              onPressed: _isLoading ? null : _onSignup,
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
                                  : const Icon(Icons.person_add_alt_1),
                              label: Text(
                                _isLoading
                                    ? t.auth_creating
                                    : t.auth_create_account,
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
                              Text(t.auth_already_have_account),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(t.auth_login),
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
