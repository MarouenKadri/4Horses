import 'package:flutter/material.dart';

import '../../../../../app/widgets/app_segmented_tab_bar.dart';
import '../../../../../core/design/app_design_system.dart';
import 'client_finance/activity_tab.dart';
import 'client_finance/methods_tab.dart';

class ClientPaymentMethodsPage extends StatefulWidget {
  const ClientPaymentMethodsPage({super.key});

  @override
  State<ClientPaymentMethodsPage> createState() =>
      _ClientPaymentMethodsPageState();
}

class _ClientPaymentMethodsPageState extends State<ClientPaymentMethodsPage> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
        titleWidget: Text('Finance', style: context.profilePageTitleStyle),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          AppSegmentedTabBar(
            selectedIndex: _selectedTabIndex,
            onChanged: (index) => setState(() => _selectedTabIndex = index),
            tabs: const [
              AppSegmentedTab(label: 'Moyens'),
              AppSegmentedTab(label: 'Activité'),
            ],
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: _AnimatedTabPane(
                    visible: _selectedTabIndex == 0,
                    child: const ClientFinanceMethodsTab(),
                  ),
                ),
                Positioned.fill(
                  child: _AnimatedTabPane(
                    visible: _selectedTabIndex == 1,
                    child: const ClientFinanceActivityTab(),
                  ),
                ),
              ],
            ),
          ),
        ],
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
