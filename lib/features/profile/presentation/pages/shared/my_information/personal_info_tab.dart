import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/design/app_design_system.dart';
import '../../../../profile_provider.dart';
import 'my_information_fields.dart';

class PersonalInfoTab extends StatefulWidget {
  const PersonalInfoTab({super.key});

  @override
  State<PersonalInfoTab> createState() => PersonalInfoTabState();
}

class PersonalInfoTabState extends State<PersonalInfoTab> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();
  final _genderCtrl = TextEditingController();
  String? _profileId;
  DateTime? _selectedBirthDate;
  String? _selectedGender;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profile = context.watch<ProfileProvider>().profile;
    if (profile != null && profile.id != _profileId) {
      _profileId = profile.id;
      _firstNameCtrl.text = profile.firstName;
      _lastNameCtrl.text = profile.lastName;
      _selectedBirthDate = profile.birthDate;
      _birthDateCtrl.text = formatBirthDate(profile.birthDate);
      _selectedGender = profile.gender;
      _genderCtrl.text = formatGender(profile.gender);
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _birthDateCtrl.dispose();
    _genderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 116),
        children: [
          ProfileField(
            controller: _firstNameCtrl,
            label: 'Prénom',
            hintText: 'Prénom',
            icon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Champ requis' : null,
          ),
          AppGap.h16,
          ProfileField(
            controller: _lastNameCtrl,
            label: 'Nom',
            hintText: 'Nom',
            icon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Champ requis' : null,
          ),
          AppGap.h16,
          ProfileField(
            controller: _birthDateCtrl,
            label: 'Date de naissance',
            hintText: 'jj/mm/aaaa',
            icon: Icons.cake_outlined,
            readOnly: true,
            showCursor: false,
            enableInteractiveSelection: false,
            onTap: _pickBirthDate,
            suffixIcon: Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: context.colors.textHint,
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Champ requis' : null,
          ),
          AppGap.h16,
          ProfileField(
            controller: _genderCtrl,
            label: 'Genre',
            hintText: 'Sélectionner',
            icon: Icons.wc_outlined,
            readOnly: true,
            showCursor: false,
            enableInteractiveSelection: false,
            onTap: _pickGender,
            suffixIcon: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: context.colors.textHint,
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Champ requis' : null,
          ),
          AppGap.h16,
          const InlineHelper(
            text:
                'Ces informations sont enregistrées directement sur votre profil.',
          ),
        ],
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('fr', 'FR'),
      initialDate: _selectedBirthDate ?? DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _selectedBirthDate = picked;
      _birthDateCtrl.text = formatBirthDate(picked);
    });
  }

  Future<void> _pickGender() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            AppGap.h12,
            ListTile(
              title: const Text('Homme'),
              onTap: () => Navigator.pop(sheetContext, 'homme'),
            ),
            ListTile(
              title: const Text('Femme'),
              onTap: () => Navigator.pop(sheetContext, 'femme'),
            ),
            ListTile(
              title: const Text('Autre'),
              onTap: () => Navigator.pop(sheetContext, 'autre'),
            ),
            AppGap.h8,
          ],
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _selectedGender = selected;
      _genderCtrl.text = formatGender(selected);
    });
  }

  Future<void> submitFromParent() => _submit();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final profileProvider = context.read<ProfileProvider>();
    final current = profileProvider.profile;
    if (current == null) return;

    final updated = current.copyWith(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      birthDate: _selectedBirthDate,
      gender: _selectedGender,
    );
    final err = await profileProvider.updateProfile(updated);
    if (!mounted) return;

    if (err != null) {
      showAppSnackBar(context, err, type: SnackBarType.error);
      return;
    }

    showAppSnackBar(
      context,
      'Informations personnelles mises à jour',
      type: SnackBarType.success,
    );
  }
}
