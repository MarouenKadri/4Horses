import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_design_system.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Modèle pays
// ─────────────────────────────────────────────────────────────────────────────

class CountryCode {
  final String flag;
  final String name;
  final String dialCode;
  final int maxDigits;
  final String hint;

  const CountryCode({
    required this.flag,
    required this.name,
    required this.dialCode,
    required this.maxDigits,
    required this.hint,
  });
}

const kCountries = [
  CountryCode(
    flag: '🇫🇷',
    name: 'France',
    dialCode: '+33',
    maxDigits: 10,
    hint: '06 12 34 56 78',
  ),
  CountryCode(
    flag: '🇧🇪',
    name: 'Belgique',
    dialCode: '+32',
    maxDigits: 9,
    hint: '047 01 23 45',
  ),
  CountryCode(
    flag: '🇨🇭',
    name: 'Suisse',
    dialCode: '+41',
    maxDigits: 9,
    hint: '076 123 45 67',
  ),
  CountryCode(
    flag: '🇹🇳',
    name: 'Tunisie',
    dialCode: '+216',
    maxDigits: 8,
    hint: '20 123 456',
  ),
  CountryCode(
    flag: '🇲🇦',
    name: 'Maroc',
    dialCode: '+212',
    maxDigits: 9,
    hint: '06 12 34 56 7',
  ),
  CountryCode(
    flag: '🇩🇿',
    name: 'Algérie',
    dialCode: '+213',
    maxDigits: 9,
    hint: '055 123 45 67',
  ),
  CountryCode(
    flag: '🇸🇳',
    name: 'Sénégal',
    dialCode: '+221',
    maxDigits: 9,
    hint: '77 123 45 67',
  ),
  CountryCode(
    flag: '🇨🇮',
    name: "Côte d'Ivoire",
    dialCode: '+225',
    maxDigits: 10,
    hint: '07 12 34 56 78',
  ),
  CountryCode(
    flag: '🇬🇧',
    name: 'Royaume-Uni',
    dialCode: '+44',
    maxDigits: 10,
    hint: '07911 12 34 56',
  ),
  CountryCode(
    flag: '🇩🇪',
    name: 'Allemagne',
    dialCode: '+49',
    maxDigits: 11,
    hint: '015 112 345 67',
  ),
  CountryCode(
    flag: '🇪🇸',
    name: 'Espagne',
    dialCode: '+34',
    maxDigits: 9,
    hint: '612 34 56 78',
  ),
  CountryCode(
    flag: '🇮🇹',
    name: 'Italie',
    dialCode: '+39',
    maxDigits: 10,
    hint: '312 345 67 89',
  ),
  CountryCode(
    flag: '🇨🇦',
    name: 'Canada',
    dialCode: '+1',
    maxDigits: 10,
    hint: '514 123 45 67',
  ),
  CountryCode(
    flag: '🇺🇸',
    name: 'États-Unis',
    dialCode: '+1',
    maxDigits: 10,
    hint: '212 345 67 89',
  ),
  CountryCode(
    flag: '🇲🇺',
    name: 'Maurice',
    dialCode: '+230',
    maxDigits: 8,
    hint: '5123 4567',
  ),
  CountryCode(
    flag: '🇨🇲',
    name: 'Cameroun',
    dialCode: '+237',
    maxDigits: 9,
    hint: '620 123 456',
  ),
  CountryCode(
    flag: '🇲🇱',
    name: 'Mali',
    dialCode: '+223',
    maxDigits: 8,
    hint: '76 12 34 56',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Formateur téléphone : groupes de 2, limité à maxDigits
// ─────────────────────────────────────────────────────────────────────────────

class PhoneFormatter extends TextInputFormatter {
  final int maxDigits;
  const PhoneFormatter(this.maxDigits);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue value,
  ) {
    final digits = value.text.replaceAll(RegExp(r'[^0-9]'), '');
    final capped = digits.length > maxDigits
        ? digits.substring(0, maxDigits)
        : digits;
    final buf = StringBuffer();
    for (int i = 0; i < capped.length; i++) {
      if (i > 0 && i % 2 == 0) buf.write(' ');
      buf.write(capped[i]);
    }
    final result = buf.toString();
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet sélecteur de pays
// ─────────────────────────────────────────────────────────────────────────────

class CountryPickerSheet extends StatefulWidget {
  final CountryCode selected;
  final ValueChanged<CountryCode> onSelected;
  const CountryPickerSheet({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<CountryPickerSheet> {
  String _query = '';

  List<CountryCode> get _filtered => _query.isEmpty
      ? kCountries
      : kCountries
            .where(
              (c) =>
                  c.name.toLowerCase().contains(_query.toLowerCase()) ||
                  c.dialCode.contains(_query),
            )
            .toList();

  @override
  Widget build(BuildContext context) {
    return AppScrollableSheet(
      title: 'Choisir un pays',
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (context, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              autofocus: true,
              decoration: AppInputDecorations.searchField(
                context,
                hintText: 'Rechercher…',
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: context.colors.border),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final c = _filtered[i];
                final isSelected =
                    c.dialCode == widget.selected.dialCode &&
                    c.name == widget.selected.name;
                return ListTile(
                  leading: Text(c.flag, style: const TextStyle(fontSize: 24)),
                  title: Text(
                    c.name,
                    style: context.text.bodyMedium?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  trailing: Text(
                    c.dialCode,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.textTertiary,
                    ),
                  ),
                  onTap: () => widget.onSelected(c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
