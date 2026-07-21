import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/design/app_design_system.dart';
import '../../../payment_methods_provider.dart';
import '../../../../data/models/payment_method.dart';
import '../../widgets/shared/payment_common_widgets.dart';

class ClientFinanceMethodsTab extends StatelessWidget {
  const ClientFinanceMethodsTab({super.key});

  void _showCardOptions(BuildContext context, PaymentMethod card) {
    final provider = context.read<PaymentMethodsProvider>();
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      child: AppActionSheet(
        title: '${card.brand} •••• ${card.last4}',
        children: [
          if (!card.isDefault)
            AppActionSheetItem(
              icon: Icons.star_outline_rounded,
              title: 'Définir par défaut',
              onTap: () {
                Navigator.pop(context);
                provider.setDefault(card.id);
              },
            ),
          if (!card.isDefault)
            const Divider(
              height: 1,
              indent: 20,
              endIndent: 20,
              color: AppColors.whiteAlpha12,
            ),
          AppActionSheetItem(
            icon: Icons.delete_outline_rounded,
            title: 'Supprimer la carte',
            destructive: true,
            onTap: () {
              Navigator.pop(context);
              showAppBottomSheet(
                context: context,
                wrapWithSurface: false,
                child: PaymentDeleteConfirmSheet(
                  title: 'Supprimer la carte ?',
                  subtitle:
                      '${card.brand} •••• ${card.last4} sera supprimée définitivement.',
                  onConfirm: () => provider.removeCard(card.id),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddCardSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      child: AddCardSheet(
        onCardAdded: (brand, last4, expiry) {
          context.read<PaymentMethodsProvider>().addCard(
            brand: brand,
            last4: last4,
            expiry: expiry,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cards = context.watch<PaymentMethodsProvider>().cards;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        const PaymentSectionLabel('MES CARTES'),
        AppGap.h10,
        if (cards.isEmpty)
          AppEmptyStateBlock(
            icon: Icons.credit_card_off_rounded,
            title: 'Aucune carte enregistrée',
            message:
                'Ajoutez une carte pour réserver plus vite vos prochaines missions.',
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 34),
            action: AppButton(
              label: 'Ajouter une carte',
              icon: Icons.add_rounded,
              variant: ButtonVariant.black,
              onPressed: () => _showAddCardSheet(context),
            ),
          )
        else ...[
          Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              children: [
                ...cards.asMap().entries.expand(
                  (entry) => [
                    _CardRow(
                      card: entry.value,
                      onTap: () => _showCardOptions(context, entry.value),
                    ),
                    if (entry.key < cards.length - 1)
                      Divider(
                        height: 1,
                        indent: 68,
                        color: context.colors.divider,
                      ),
                  ],
                ),
              ],
            ),
          ),
          AppGap.h10,
          PaymentAddButton(
            label: 'Ajouter une carte',
            onTap: () => _showAddCardSheet(context),
          ),
        ],
        AppGap.h16,
        const PaymentInfoNote(
          icon: Icons.lock_outline_rounded,
          body:
              'Chiffrement SSL · BYRSA ne stocke jamais vos numéros de carte complets.',
        ),
      ],
    );
  }
}

class _CardRow extends StatelessWidget {
  final PaymentMethod card;
  final VoidCallback onTap;

  const _CardRow({required this.card, required this.onTap});

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
                Icons.credit_card_rounded,
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
                        '${card.brand} •••• ${card.last4}',
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      if (card.isDefault) ...[
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
                          child: Text(
                            'Défaut',
                            style: context.text.labelSmall?.copyWith(
                              fontSize: 10,
                              color: context.colors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  AppGap.h2,
                  Text(
                    'Expire ${card.expiry}',
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
