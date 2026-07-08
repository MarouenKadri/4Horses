import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../../app/widgets/app_location_picker_map.dart';
import '../../../../../../core/design/app_design_system.dart';
import '../../shared/my_information/my_information_fields.dart';

class FreelancerActivityTab extends StatelessWidget {
  final TextEditingController hourlyRateController;
  final TextEditingController bioController;
  final List<Map<String, dynamic>> allSkills;
  final Set<String> selectedSkills;
  final LatLng? locationLatLng;
  final String locationAddress;
  final ValueChanged<String> onSkillToggle;
  final VoidCallback onRateChanged;
  final void Function(LatLng latlng, String address) onLocationChanged;

  const FreelancerActivityTab({
    super.key,
    required this.hourlyRateController,
    required this.bioController,
    required this.allSkills,
    required this.selectedSkills,
    required this.locationLatLng,
    required this.locationAddress,
    required this.onSkillToggle,
    required this.onRateChanged,
    required this.onLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 116),
      children: [
        _TarifCard(controller: hourlyRateController, onChanged: onRateChanged),
        AppGap.h28,
        _SkillsCard(
          allSkills: allSkills,
          selectedSkills: selectedSkills,
          onToggle: onSkillToggle,
        ),
        AppGap.h28,
        _BioCard(controller: bioController),
        AppGap.h28,
        _LocationMapCard(
          initialLatLng: locationLatLng,
          initialAddress: locationAddress,
          onChanged: onLocationChanged,
        ),
      ],
    );
  }
}

class _LocationMapCard extends StatelessWidget {
  final LatLng? initialLatLng;
  final String initialAddress;
  final void Function(LatLng, String) onChanged;

  const _LocationMapCard({
    required this.initialLatLng,
    required this.initialAddress,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Ma localisation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InlineHelper(
            text:
                'Définissez votre ville ou adresse de base. Les clients à proximité pourront vous trouver.',
          ),
          AppGap.h14,
          AppLocationPickerMap(
            initialLatLng: initialLatLng,
            initialAddress: initialAddress,
            onChanged: (selection) =>
                onChanged(selection.latLng, selection.address),
          ),
        ],
      ),
    );
  }
}

class _TarifCard extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _TarifCard({required this.controller, required this.onChanged});

  @override
  State<_TarifCard> createState() => _TarifCardState();
}

class _TarifCardState extends State<_TarifCard> {
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Tarif horaire',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InlineHelper(
            text: 'Définissez le tarif affiché sur votre profil prestataire.',
          ),
          AppGap.h12,
          ProfileField(
            controller: widget.controller,
            label: 'Tarif horaire',
            hintText: '25',
            icon: Icons.euro_rounded,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) {
              widget.onChanged();
              setState(() {});
            },
            textStyle: context.text.displaySmall,
            prefixIconConstraints: const BoxConstraints(minWidth: 44),
            suffixText: '€ / heure',
            suffixStyle: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.textSecondary,
            ),
          ),
          AppGap.h14,
          Text(
            'Suggestions rapides',
            style: context.text.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          AppGap.h8,
          Wrap(
            spacing: 8,
            children: [15, 20, 25, 30, 35, 50].map((v) {
              final selected = widget.controller.text == '$v';
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.controller.text = '$v';
                  widget.onChanged();
                  setState(() {});
                },
                child: AppPillChip(label: '$v €', selected: selected),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SkillsCard extends StatelessWidget {
  final List<Map<String, dynamic>> allSkills;
  final Set<String> selectedSkills;
  final ValueChanged<String> onToggle;

  const _SkillsCard({
    required this.allSkills,
    required this.selectedSkills,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Compétences',
      trailing: AppTagPill(
        label: '${selectedSkills.length}/${allSkills.length}',
        backgroundColor: context.colors.background,
        foregroundColor: context.colors.textTertiary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        fontSize: AppFontSize.xs,
        fontWeight: FontWeight.w500,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InlineHelper(
            text: 'Choisissez les services que vous proposez aux clients.',
          ),
          AppGap.h12,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allSkills.map((skill) {
              final label = skill['label'] as String;
              final icon = skill['icon'] as IconData;
              final selected = selectedSkills.contains(label);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onToggle(label);
                },
                child: AppPillChip(
                  label: label,
                  icon: icon,
                  selected: selected,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _BioCard extends StatelessWidget {
  final TextEditingController controller;

  const _BioCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Présentation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InlineHelper(
            text:
                'Ce texte est affiché sur votre profil public, sous « Présentation ».',
          ),
          AppGap.h12,
          TextField(
            controller: controller,
            minLines: 4,
            maxLines: 8,
            maxLength: 500,
            style: context.text.bodyMedium?.copyWith(height: 1.5),
            decoration: InputDecoration(
              hintText:
                  'Présentez-vous : votre parcours, vos spécialités, votre façon de travailler…',
              hintStyle: context.text.bodyMedium?.copyWith(
                color: context.colors.textHint,
                height: 1.5,
              ),
              filled: true,
              fillColor: context.colors.surface,
              contentPadding: const EdgeInsets.all(14),
              counterStyle: context.text.labelSmall?.copyWith(
                color: context.colors.textHint,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.colors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section à plat : titre noir sur fond blanc, sans carte-boîte ni
/// pastille d'icône colorée — même langage que les profils et le compte.
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;

  const _SectionCard({required this.title, this.trailing, required this.child});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            title,
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (trailing != null) ...[const Spacer(), trailing!],
        ],
      ),
      AppGap.h10,
      child,
    ],
  );
}
