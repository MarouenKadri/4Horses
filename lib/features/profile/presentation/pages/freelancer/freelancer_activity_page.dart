import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../app/widgets/app_segmented_tab_bar.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../profile_provider.dart';
import 'freelancer_activity/activity_tab.dart';
import 'freelancer_activity/my_publications_tab.dart';

class FreelancerActivityPage extends StatefulWidget {
  /// Onglet initial : 0 = activité, 1 = mes publications.
  final int initialTab;

  const FreelancerActivityPage({super.key, this.initialTab = 0});

  @override
  State<FreelancerActivityPage> createState() => _FreelancerActivityPageState();
}

class _FreelancerActivityPageState extends State<FreelancerActivityPage> {
  late int _selectedTabIndex = widget.initialTab;

  final _hourlyRateController = TextEditingController();
  final _bioController = TextEditingController();
  String _locationAddress = '';
  final Set<String> _selectedSkills = {};

  final List<Map<String, dynamic>> _allSkills = const [
    {'label': 'Ménage', 'icon': Icons.cleaning_services_rounded},
    {'label': 'Jardinage', 'icon': Icons.grass_rounded},
    {'label': 'Bricolage', 'icon': Icons.handyman_rounded},
    {'label': 'Repassage', 'icon': Icons.iron_rounded},
    {'label': 'Plomberie', 'icon': Icons.plumbing_rounded},
    {'label': 'Électricité', 'icon': Icons.electrical_services_rounded},
    {'label': 'Peinture', 'icon': Icons.format_paint_rounded},
    {'label': 'Déménagement', 'icon': Icons.local_shipping_rounded},
    {'label': 'Courses', 'icon': Icons.shopping_cart_rounded},
    {'label': 'Garde d\'enfants', 'icon': Icons.child_care_rounded},
    {'label': 'Aide aux personnes âgées', 'icon': Icons.elderly_rounded},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<ProfileProvider>().profile;
      if (profile == null) return;
      if (profile.address != null) {
        _locationAddress = profile.address!;
      }
      if (profile.hourlyRate != null) {
        _hourlyRateController.text = profile.hourlyRate!.toStringAsFixed(0);
      }
      _bioController.text = profile.bio ?? '';
      _selectedSkills
        ..clear()
        ..addAll(profile.serviceCategories);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _hourlyRateController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final provider = context.read<ProfileProvider>();
    final profile = provider.profile;
    if (profile == null) {
      Navigator.pop(context);
      return;
    }

    final updated = profile.copyWith(
      address: _locationAddress,
      bio: _bioController.text.trim(),
      hourlyRate: double.tryParse(_hourlyRateController.text.trim()),
      serviceCategories: _selectedSkills.toList(),
    );

    final error = await provider.updateProfile(updated);
    if (!mounted || error != null) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<ProfileProvider>().isSaving;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
        titleWidget: Text(
          _tabTitle,
          style: context.profilePageTitleStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      bottomNavigationBar: _selectedTabIndex == 0
          ? AppActionFooter(
              child: AppButton(
                label: 'Enregistrer',
                variant: ButtonVariant.black,
                isLoading: isSaving,
                onPressed: isSaving ? null : _saveProfile,
              ),
            )
          : null,
      body: Column(
        children: [
          const SizedBox(height: 10),
          AppSegmentedTabBar(
            selectedIndex: _selectedTabIndex,
            onChanged: (index) => setState(() => _selectedTabIndex = index),
            tabs: const [
              AppSegmentedTab(
                icon: Icons.trending_up_rounded,
                label: 'Activité',
              ),
              AppSegmentedTab(
                icon: Icons.auto_stories_rounded,
                label: 'Mes publications',
              ),
            ],
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: _AnimatedTabPane(
                    visible: _selectedTabIndex == 0,
                    child: FreelancerActivityTab(
                      hourlyRateController: _hourlyRateController,
                      bioController: _bioController,
                      allSkills: _allSkills,
                      selectedSkills: _selectedSkills,
                      locationLatLng: null,
                      locationAddress: _locationAddress,
                      onSkillToggle: (label) => setState(
                        () => _selectedSkills.contains(label)
                            ? _selectedSkills.remove(label)
                            : _selectedSkills.add(label),
                      ),
                      onRateChanged: () => setState(() {}),
                      onLocationChanged: (_, address) =>
                          setState(() => _locationAddress = address),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: _AnimatedTabPane(
                    visible: _selectedTabIndex == 1,
                    child: const FreelancerMyPublicationsTab(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _tabTitle => switch (_selectedTabIndex) {
    1 => 'Mes publications',
    _ => 'Mon activité',
  };
}

class _AnimatedTabPane extends StatelessWidget {
  final bool visible;
  final Widget child;

  const _AnimatedTabPane({required this.visible, required this.child});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        opacity: visible ? 1 : 0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          offset: visible ? Offset.zero : const Offset(0.02, 0),
          child: child,
        ),
      ),
    );
  }
}
