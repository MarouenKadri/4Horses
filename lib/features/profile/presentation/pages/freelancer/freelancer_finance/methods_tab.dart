import 'package:flutter/material.dart';

import '../../../../../../core/design/app_design_system.dart';
import '../../widgets/shared/payment_common_widgets.dart';
import '../../widgets/shared/user_common_widgets.dart';

class FreelancerFinanceMethodsTab extends StatefulWidget {
  const FreelancerFinanceMethodsTab({super.key});

  @override
  State<FreelancerFinanceMethodsTab> createState() =>
      _FreelancerFinanceMethodsTabState();
}

class _FreelancerFinanceMethodsTabState
    extends State<FreelancerFinanceMethodsTab> {
  void _showIbanOptions(BuildContext context) {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      child: AppActionSheet(
        title: 'Compte de virement SEPA',
        children: [
          AppActionSheetItem(
            icon: Icons.edit_outlined,
            title: 'Modifier l\'IBAN SEPA',
            onTap: () {
              Navigator.pop(context);
              _showEditIbanSheet(context);
            },
          ),
          const Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: AppColors.whiteAlpha12,
          ),
          AppActionSheetItem(
            icon: Icons.delete_outline_rounded,
            title: 'Supprimer le compte',
            destructive: true,
            onTap: () {
              Navigator.pop(context);
              showAppBottomSheet(
                context: context,
                wrapWithSurface: false,
                child: PaymentDeleteConfirmSheet(
                  title: 'Supprimer le compte ?',
                  subtitle:
                      'Le compte SEPA FR76 •••• 1234 sera supprimé définitivement.',
                  onConfirm: () {},
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddIbanSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      child: const _IbanSheet(isEdit: false),
    );
  }

  void _showEditIbanSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      child: const _IbanSheet(isEdit: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        const PaymentSectionLabel('COMPTE DE VIREMENT SEPA'),
        AppGap.h10,
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.colors.border),
          ),
          child: _IbanRow(onTap: () => _showIbanOptions(context)),
        ),
        AppGap.h10,
        PaymentAddButton(
          label: 'Ajouter un IBAN SEPA',
          onTap: () => _showAddIbanSheet(context),
        ),
        AppGap.h16,
        const PaymentInfoNote(
          icon: Icons.autorenew_rounded,
          body:
              'Versement automatique 24h après livraison · compatible Stripe, PayPal, MangoPay.',
        ),
      ],
    );
  }
}

class _IbanRow extends StatelessWidget {
  final VoidCallback onTap;

  const _IbanRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: context.colors.border),
              ),
              child: Icon(
                Icons.account_balance_rounded,
                size: 18,
                color: context.colors.textSecondary,
              ),
            ),
            AppGap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'FR76 •••• 1234',
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      AppGap.w8,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceAlt,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: context.colors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            AppGap.w4,
                            Text(
                              'Actif',
                              style: context.text.labelSmall?.copyWith(
                                fontSize: 10,
                                color: context.colors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppGap.h2,
                  Text(
                    'Jean Dupont · BIC BNPAFRPP',
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.more_horiz_rounded,
              size: 18,
              color: context.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _IbanSheet extends StatelessWidget {
  final bool isEdit;

  const _IbanSheet({required this.isEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: AppFormSheet(
        title: isEdit ? 'Modifier l\'IBAN SEPA' : 'Ajouter un IBAN SEPA',
        color: context.colors.surface,
        footer: Column(
          children: [
            ProfileSheetPrimaryAction(
              label: isEdit ? 'Enregistrer' : 'Ajouter l\'IBAN',
              onPressed: () => Navigator.pop(context),
            ),
            AppGap.h12,
            Center(
              child: ProfileSheetSecondaryAction(
                label: 'Annuler',
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              textCapitalization: TextCapitalization.characters,
              style: TextStyle(
                fontSize: AppFontSize.body,
                color: context.colors.textPrimary,
                letterSpacing: 1.5,
              ),
              decoration:
                  AppInputDecorations.profileField(
                    context,
                    hintText: 'FR76 3000 1007 94...',
                    radius: 18,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 14, right: 10),
                      child: Icon(
                        Icons.account_balance_rounded,
                        size: 16,
                        color: context.colors.textHint,
                      ),
                    ),
                  ).copyWith(
                    labelText: 'IBAN',
                    errorStyle: context.profileErrorStyle,
                  ),
            ),
            AppGap.h10,
            TextFormField(
              textCapitalization: TextCapitalization.characters,
              style: TextStyle(
                fontSize: AppFontSize.body,
                color: context.colors.textPrimary,
              ),
              decoration:
                  AppInputDecorations.profileField(
                    context,
                    hintText: 'BNPAFRPP...',
                    radius: 18,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 14, right: 10),
                      child: Icon(
                        Icons.code_rounded,
                        size: 16,
                        color: context.colors.textHint,
                      ),
                    ),
                  ).copyWith(
                    labelText: 'BIC / SWIFT (optionnel)',
                    errorStyle: context.profileErrorStyle,
                  ),
            ),
            AppGap.h10,
            TextFormField(
              textCapitalization: TextCapitalization.words,
              style: TextStyle(
                fontSize: AppFontSize.body,
                color: context.colors.textPrimary,
              ),
              decoration:
                  AppInputDecorations.profileField(
                    context,
                    hintText: 'Jean Dupont',
                    radius: 18,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 14, right: 10),
                      child: Icon(
                        Icons.person_outline_rounded,
                        size: 16,
                        color: context.colors.textHint,
                      ),
                    ),
                  ).copyWith(
                    labelText: 'Titulaire du compte',
                    errorStyle: context.profileErrorStyle,
                  ),
            ),
            AppGap.h16,
            Row(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 13,
                  color: context.colors.textTertiary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Coordonnées bancaires chiffrées et sécurisées',
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.textTertiary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
