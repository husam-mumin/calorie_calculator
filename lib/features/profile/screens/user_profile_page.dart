import 'package:flutter/material.dart';
import 'package:calorie_calculator/l10n/app_localizations.dart';
import '../../../core/db/dao/users_dao.dart';
import '../../../core/db/dao/settings_dao.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  int? _userId;
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  String _gender = 'male';
  String _activity = 'moderate';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = await UsersDao.instance.getFirstUser();
    if (u != null) {
      _userId = u.id;
      _nameCtrl.text = u.name ?? '';
      _ageCtrl.text = (u.age ?? '').toString();
      _heightCtrl.text = (u.height ?? '').toString();
      _weightCtrl.text = (u.weight ?? '').toString();
      _gender = u.gender ?? 'male';
      _activity = u.activityLevel ?? 'moderate';
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = UserProfile(
      id: _userId,
      name: _nameCtrl.text.trim(),
      age: int.tryParse(_ageCtrl.text.trim()),
      gender: _gender,
      height: double.tryParse(_heightCtrl.text.trim()),
      weight: double.tryParse(_weightCtrl.text.trim()),
      activityLevel: _activity,
    );
    await UsersDao.instance.upsert(user);
    // Optional: persist units defaults based on heuristic
    await SettingsDao.instance.setUnits('metric');
    if (!mounted) return;
    final t = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.profile_saved_snackbar)));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.profile_title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: t.profile_name,
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if ((v ?? '').trim().isEmpty) return t.form_name_required;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageCtrl,
                      decoration: InputDecoration(
                        labelText: t.profile_age,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        final s = (v ?? '').trim();
                        if (s.isEmpty) return t.form_required;
                        final n = int.tryParse(s);
                        if (n == null || n <= 0) return t.form_number_invalid;
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _gender,
                      items: [
                        DropdownMenuItem(
                          value: 'male',
                          child: Text(t.profile_gender_male),
                        ),
                        DropdownMenuItem(
                          value: 'female',
                          child: Text(t.profile_gender_female),
                        ),
                      ],
                      onChanged: (v) => setState(() => _gender = v ?? 'male'),
                      decoration: InputDecoration(
                        labelText: t.profile_gender,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _heightCtrl,
                      decoration: InputDecoration(
                        labelText: t.profile_height_cm,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        final s = (v ?? '').trim();
                        if (s.isEmpty) return t.form_required;
                        final n = double.tryParse(s);
                        if (n == null || n <= 0) return t.form_number_invalid;
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _weightCtrl,
                      decoration: InputDecoration(
                        labelText: t.profile_weight_kg,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      validator: (v) {
                        final s = (v ?? '').trim();
                        if (s.isEmpty) return t.form_required;
                        final n = double.tryParse(s);
                        if (n == null || n <= 0) return t.form_number_invalid;
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _activity,
                items: [
                  DropdownMenuItem(
                    value: 'sedentary',
                    child: Text(t.profile_activity_sedentary),
                  ),
                  DropdownMenuItem(
                    value: 'light',
                    child: Text(t.profile_activity_light),
                  ),
                  DropdownMenuItem(
                    value: 'moderate',
                    child: Text(t.profile_activity_moderate),
                  ),
                  DropdownMenuItem(
                    value: 'very',
                    child: Text(t.profile_activity_very),
                  ),
                  DropdownMenuItem(
                    value: 'extra',
                    child: Text(t.profile_activity_extra),
                  ),
                ],
                onChanged: (v) => setState(() => _activity = v ?? 'moderate'),
                decoration: InputDecoration(
                  labelText: t.profile_activity_level,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final ok = _formKey.currentState?.validate() ?? false;
                    if (!ok) return;
                    _save();
                  },
                  icon: const Icon(Icons.save_alt),
                  label: Text(t.common_save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
