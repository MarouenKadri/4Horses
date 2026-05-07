import 'package:flutter/material.dart';

import '../../../../../../core/design/app_design_system.dart';
import '../../widgets/shared/payment_common_widgets.dart';

class ClientFinanceActivityTab extends StatefulWidget {
  const ClientFinanceActivityTab({super.key});

  @override
  State<ClientFinanceActivityTab> createState() =>
      _ClientFinanceActivityTabState();
}

class _ClientFinanceActivityTabState extends State<ClientFinanceActivityTab> {
  String _filter = 'Tout';
  final _filters = ['Tout', 'Paiements', 'Remboursements', 'En attente'];

  static const _months = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];

  final List<_Tx> _txs = [
    _Tx(
      type: _T.payment,
      title: 'Ménage appartement',
      sub: 'Thomas R.',
      amount: 55.00,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      pending: false,
      card: 'Visa ···4242',
    ),
    _Tx(
      type: _T.payment,
      title: 'Jardinage — Paris 11e',
      sub: 'Julie M.',
      amount: 40.00,
      date: DateTime.now().subtract(const Duration(days: 1)),
      pending: false,
      card: 'Visa ···4242',
    ),
    _Tx(
      type: _T.refund,
      title: 'Remboursement annulation',
      sub: 'Marc D.',
      amount: 35.00,
      date: DateTime.now().subtract(const Duration(days: 2)),
      pending: false,
      card: 'Visa ···4242',
    ),
    _Tx(
      type: _T.payment,
      title: 'Repassage 2h',
      sub: 'Sarah L.',
      amount: 50.00,
      date: DateTime.now().subtract(const Duration(days: 4)),
      pending: false,
      card: 'Mastercard ···8888',
    ),
    _Tx(
      type: _T.payment,
      title: 'Montage meuble',
      sub: 'Antoine B.',
      amount: 80.00,
      date: DateTime.now().subtract(const Duration(days: 7)),
      pending: false,
      card: 'Visa ···4242',
    ),
    _Tx(
      type: _T.payment,
      title: 'Ménage bureau',
      sub: 'Thomas R.',
      amount: 65.00,
      date: DateTime.now().subtract(const Duration(days: 10)),
      pending: true,
      card: 'Visa ···4242',
    ),
  ];

  List<_Tx> get _filtered => switch (_filter) {
        'Paiements' => _txs
            .where((tx) => tx.type == _T.payment && !tx.pending)
            .toList(),
        'Remboursements' =>
          _txs.where((tx) => tx.type == _T.refund).toList(),
        'En attente' => _txs.where((tx) => tx.pending).toList(),
        _ => _txs,
      };

  double get _totalPaid => _txs
      .where((tx) => tx.type == _T.payment && !tx.pending)
      .fold(0.0, (sum, tx) => sum + tx.amount);

  double get _totalRefunded => _txs
      .where((tx) => tx.type == _T.refund)
      .fold(0.0, (sum, tx) => sum + tx.amount);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final grouped = <String, List<_Tx>>{};
    for (final tx in _filtered) {
      grouped.putIfAbsent(_dateLabel(tx.date), () => []).add(tx);
    }

    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _ClientFiltersHeader(
            month: '${_months[now.month - 1]} ${now.year}',
            totalPaid: _totalPaid,
            totalRefunded: _totalRefunded,
            filters: _filters,
            selected: _filter,
            onFilterChanged: (value) => setState(() => _filter = value),
          ),
        ),
        if (_filtered.isEmpty)
          SliverFillRemaining(child: _buildEmpty(context))
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final key = grouped.keys.elementAt(index);
                  final list = grouped[key]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 8,
                          top: index == 0 ? 0 : 20,
                        ),
                        child: Text(
                          key,
                          style: context.text.labelSmall?.copyWith(
                            color: context.colors.textTertiary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.colors.border),
                        ),
                        child: Column(
                          children: List.generate(
                            list.length,
                            (itemIndex) => Column(
                              children: [
                                _TxTile(
                                  tx: list[itemIndex],
                                  onTap: () =>
                                      _showDetail(context, list[itemIndex]),
                                ),
                                if (itemIndex < list.length - 1)
                                  Divider(
                                    height: 1,
                                    indent: 68,
                                    color: context.colors.divider,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                childCount: grouped.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: context.colors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.border),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 26,
              color: context.colors.textHint,
            ),
          ),
          AppGap.h14,
          Text(
            'Aucune transaction',
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, _Tx tx) {
    final isRefund = tx.type == _T.refund;
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: BoxDecoration(
          color: context.colors.sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            AppGap.h24,
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                shape: BoxShape.circle,
                border: Border.all(color: context.colors.border),
              ),
              child: Icon(
                isRefund
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                size: 22,
                color: context.colors.textSecondary,
              ),
            ),
            AppGap.h14,
            Text(
              '${isRefund ? '+' : '−'}${tx.amount.toStringAsFixed(2)} €',
              style: context.text.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: context.colors.textPrimary,
              ),
            ),
            AppGap.h4,
            Text(
              tx.title,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            AppGap.h8,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: context.colors.border),
              ),
              child: Text(
                tx.pending ? 'En attente (24h)' : isRefund ? 'Remboursé' : 'Payé',
                style: context.text.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.textSecondary,
                ),
              ),
            ),
            AppGap.h24,
            Container(
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.colors.border),
              ),
              child: Column(
                children: [
                  _DetailRow('Prestataire', tx.sub),
                  Divider(height: 1, indent: 16, color: context.colors.divider),
                  _DetailRow('Carte', tx.card),
                  Divider(height: 1, indent: 16, color: context.colors.divider),
                  _DetailRow('Date', _fullDate(tx.date)),
                  Divider(height: 1, indent: 16, color: context.colors.divider),
                  _DetailRow(
                    'Référence',
                    '#${tx.date.millisecondsSinceEpoch.toString().substring(7)}',
                  ),
                ],
              ),
            ),
            AppGap.h20,
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Reçu',
                    variant: ButtonVariant.outline,
                    icon: Icons.receipt_rounded,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                AppGap.w12,
                Expanded(
                  child: AppButton(
                    label: 'Signaler',
                    variant: ButtonVariant.outline,
                    icon: Icons.flag_rounded,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            AppGap.h12,
            AppButton(
              label: 'Fermer',
              variant: ButtonVariant.ghost,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    if (day == today) return "Aujourd'hui";
    if (day == today.subtract(const Duration(days: 1))) return 'Hier';
    if (now.difference(date).inDays < 7) {
      const days = [
        'Lundi',
        'Mardi',
        'Mercredi',
        'Jeudi',
        'Vendredi',
        'Samedi',
        'Dimanche',
      ];
      return days[date.weekday - 1];
    }
    const months = [
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _fullDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
        ' à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _ClientFiltersHeader extends SliverPersistentHeaderDelegate {
  final String month;
  final double totalPaid;
  final double totalRefunded;
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onFilterChanged;

  const _ClientFiltersHeader({
    required this.month,
    required this.totalPaid,
    required this.totalRefunded,
    required this.filters,
    required this.selected,
    required this.onFilterChanged,
  });

  static const double _height = 236;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  bool shouldRebuild(_ClientFiltersHeader oldDelegate) {
    return oldDelegate.selected != selected ||
        oldDelegate.totalPaid != totalPaid ||
        oldDelegate.totalRefunded != totalRefunded;
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: context.colors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, color: context.colors.divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: context.colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Résumé',
                    style: context.text.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  AppGap.h4,
                  Text(
                    month,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  AppGap.h14,
                  _SummaryMetric(
                    label: 'Dépensé',
                    value: '− ${totalPaid.toStringAsFixed(0)} €',
                    valueColor: context.colors.textPrimary,
                  ),
                  AppGap.h10,
                  _SummaryMetric(
                    label: 'Remboursé',
                    value: '+ ${totalRefunded.toStringAsFixed(0)} €',
                    valueColor: AppColors.primary,
                  ),
                  AppGap.h12,
                  Text(
                    'Touchez une ligne pour voir le détail du paiement.',
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.textTertiary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          PaymentFilterPills(
            filters: filters,
            selected: selected,
            onChanged: onFilterChanged,
          ),
          Divider(height: 1, color: context.colors.divider),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: context.text.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _TxTile extends StatelessWidget {
  final _Tx tx;
  final VoidCallback onTap;

  const _TxTile({required this.tx, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isRefund = tx.type == _T.refund;
    final subtitle = tx.pending
        ? '${tx.sub} · Versement au prestataire sous 24h'
        : isRefund
            ? '${tx.sub} · Remboursement reçu'
            : '${tx.sub} · ${tx.card}';

    return PaymentTxTile(
      icon: isRefund
          ? Icons.arrow_downward_rounded
          : Icons.arrow_upward_rounded,
      title: tx.title,
      subtitle: subtitle,
      amount: '${isRefund ? '+' : '−'}${tx.amount.toStringAsFixed(2)} €',
      isPositive: isRefund,
      badge: tx.pending ? 'En attente' : isRefund ? 'Remboursé' : 'Payé',
      badgeColor: tx.pending
          ? context.colors.textTertiary
          : isRefund
              ? AppColors.primary
              : context.colors.textTertiary,
      onTap: onTap,
    );
  }
}

enum _T { payment, refund }

class _Tx {
  final _T type;
  final String title;
  final String sub;
  final String card;
  final double amount;
  final DateTime date;
  final bool pending;

  const _Tx({
    required this.type,
    required this.title,
    required this.sub,
    required this.card,
    required this.amount,
    required this.date,
    required this.pending,
  });
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.textTertiary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: context.text.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
