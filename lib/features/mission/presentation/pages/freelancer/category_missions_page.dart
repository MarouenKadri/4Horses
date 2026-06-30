import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../data/models/mission.dart';
import '../../mission_provider.dart';
import '../../widgets/cards/variants/mission_browse_card.dart';
import '../../widgets/shared/mission_shared_widgets.dart';
import 'freelancer_mission_detail_page.dart';

enum _TimeFilter { all, today, thisWeek }

class CategoryMissionsPage extends StatefulWidget {
  final ServiceCategory category;

  const CategoryMissionsPage({super.key, required this.category});

  @override
  State<CategoryMissionsPage> createState() => _CategoryMissionsPageState();
}

class _CategoryMissionsPageState extends State<CategoryMissionsPage> {
  _TimeFilter _filter = _TimeFilter.all;

  List<Mission> _apply(List<Mission> all) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    var list = all
        .where((m) =>
            (m.status == MissionStatus.waitingCandidates ||
                m.status == MissionStatus.candidateReceived) &&
            m.categoryId == widget.category.id)
        .toList();

    if (_filter == _TimeFilter.today) {
      list = list.where((m) {
        final d = DateTime(m.date.year, m.date.month, m.date.day);
        return d == today;
      }).toList();
    } else if (_filter == _TimeFilter.thisWeek) {
      final weekEnd = today.add(const Duration(days: 7));
      list = list.where((m) {
        final d = DateTime(m.date.year, m.date.month, m.date.day);
        return !d.isBefore(today) && d.isBefore(weekEnd);
      }).toList();
    }

    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  Future<void> _refresh() => context.read<MissionProvider>().refresh();

  @override
  Widget build(BuildContext context) {
    final allMissions = context.watch<MissionProvider>().publicMissions;
    final appliedIds = context
        .watch<MissionProvider>()
        .freelancerMissions
        .map((m) => m.id)
        .toSet();
    final missions = _apply(allMissions);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: context.colors.background,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              color: context.colors.textPrimary,
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.category.name,
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.colors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  '${missions.length} mission${missions.length > 1 ? 's' : ''}',
                  style: context.text.labelSmall?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: _buildChips(),
            ),
          ),
        ],
        body: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.inkDark,
          child: missions.isEmpty
              ? ListView(
                  children: [
                    SizedBox(
                      height: 320,
                      child: EmptyState(
                        icon: widget.category.icon,
                        title: 'Aucune mission en ${widget.category.name}',
                        subtitle:
                            'Revenez plus tard, de nouvelles missions arrivent chaque jour.',
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  itemCount: missions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final mission = missions[index];
                    return MissionBrowseCard(
                      mission: mission,
                      isApplied: appliedIds.contains(mission.id),
                      onTap: () => Navigator.push(
                        context,
                        slideUpRoute(
                          page: FreelancerMissionDetailPage(mission: mission),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildChips() {
    final filters = [
      (_TimeFilter.all, 'Toutes'),
      (_TimeFilter.today, "Aujourd'hui"),
      (_TimeFilter.thisWeek, 'Cette semaine'),
    ];

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: filters.map((entry) {
          final (filter, label) = entry;
          final isSelected = _filter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.inkDark : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected ? AppColors.inkDark : AppColors.gray50,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.inkDark,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
