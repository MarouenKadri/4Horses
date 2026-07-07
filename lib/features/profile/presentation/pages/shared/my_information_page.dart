import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../app/auth_provider.dart';
import '../../../../../app/widgets/app_segmented_tab_bar.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../profile_provider.dart';
import 'my_information/email_info_tab.dart';
import 'my_information/personal_info_tab.dart';
import 'my_information/phone_info_tab.dart';

class MyInformationPage extends StatefulWidget {
  const MyInformationPage({super.key});

  @override
  State<MyInformationPage> createState() => _MyInformationPageState();
}

class _MyInformationPageState extends State<MyInformationPage> {
  int _selectedTabIndex = 0;
  final _personalTabKey = GlobalKey<PersonalInfoTabState>();
  final _emailTabKey = GlobalKey<EmailInfoTabState>();
  final _phoneTabKey = GlobalKey<PhoneInfoTabState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
        titleWidget: Text(
          'Mes informations',
          style: context.profilePageTitleStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      bottomNavigationBar: _buildBottomAction(context),
      body: Column(
        children: [
          const SizedBox(height: 10),
          AppSegmentedTabBar(
            selectedIndex: _selectedTabIndex,
            onChanged: (index) => setState(() => _selectedTabIndex = index),
            tabs: const [
              AppSegmentedTab(label: 'Personnel'),
              AppSegmentedTab(label: 'Email'),
              AppSegmentedTab(label: 'Téléphone'),
            ],
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: _AnimatedTabPane(
                    visible: _selectedTabIndex == 0,
                    child: PersonalInfoTab(key: _personalTabKey),
                  ),
                ),
                Positioned.fill(
                  child: _AnimatedTabPane(
                    visible: _selectedTabIndex == 1,
                    child: EmailInfoTab(key: _emailTabKey),
                  ),
                ),
                Positioned.fill(
                  child: _AnimatedTabPane(
                    visible: _selectedTabIndex == 2,
                    child: PhoneInfoTab(key: _phoneTabKey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildBottomAction(BuildContext context) {
    final isEmailTab = _selectedTabIndex == 1;
    final loading = _selectedTabIndex == 1
        ? context.watch<AuthProvider>().isLoading
        : context.watch<ProfileProvider>().isSaving;

    return AppActionFooter(
      child: AppButton(
        label: 'Enregistrer',
        variant: ButtonVariant.black,
        isLoading: loading,
        onPressed: loading
            ? null
            : () {
                if (_selectedTabIndex == 0) {
                  _personalTabKey.currentState?.submitFromParent();
                } else if (isEmailTab) {
                  _emailTabKey.currentState?.submitFromParent();
                } else {
                  _phoneTabKey.currentState?.submitFromParent();
                }
              },
      ),
    );
  }
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
