import 'package:flutter/material.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../data/models/mission.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📊 Status Timeline — stepper de progression de mission
/// ═══════════════════════════════════════════════════════════════════════════

const _kAccent = AppColors.primary;

const _kTimelineLabels = ['Mission', 'Confirmée', 'En cours', 'Fin'];

const _kSpecialStatuses = {
  MissionStatus.cancelled,
  MissionStatus.inDispute,
  MissionStatus.expired,
  MissionStatus.draft,
};

class StatusTimeline extends StatelessWidget {
  final MissionStatus status;
  const StatusTimeline({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    if (_kSpecialStatuses.contains(status)) {
      return _SpecialStatusBanner(status: status);
    }
    return _TimelineTrack(currentStatus: status);
  }
}

// ─── Bannière statuts spéciaux ────────────────────────────────────────────────

class _SpecialStatusBanner extends StatelessWidget {
  final MissionStatus status;
  const _SpecialStatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      MissionStatus.cancelled => AppColors.error,
      MissionStatus.inDispute => AppColors.error,
      _ => context.colors.textTertiary,
    };

    return Container(
      padding: AppInsets.h16v12,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(status.icon, color: color, size: 20),
          AppGap.w12,
          Text(
            status.label,
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Track de la timeline ─────────────────────────────────────────────────────

class _TimelineTrack extends StatelessWidget {
  final MissionStatus currentStatus;
  const _TimelineTrack({required this.currentStatus});

  int get _currentIndex {
    return switch (currentStatus) {
      MissionStatus.waitingCandidates ||
      MissionStatus.candidateReceived ||
      MissionStatus.pendingAcceptance => 0,
      MissionStatus.confirmed || MissionStatus.onTheWay => 1,
      MissionStatus.inProgress => 2,
      MissionStatus.completionRequested ||
      MissionStatus.completed ||
      MissionStatus.paymentHeld ||
      MissionStatus.awaitingRelease ||
      MissionStatus.closed => 3,
      _ => 0,
    };
  }

  /// La dernière étape reste affichée (case pleine) une fois `closed`, mais
  /// ne doit plus pulser : la mission est réellement terminée, il n'y a plus
  /// rien en attente (contrairement à completionRequested/awaitingRelease).
  bool get _isFinalStatusSettled => currentStatus == MissionStatus.closed;

  @override
  Widget build(BuildContext context) {
    final currentIdx = _currentIndex;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            // Même gabarit de titre que « Description » plus bas
            Text('Progression', style: context.missionSectionTitleStyle),
            const Spacer(),
            Text(
              '${currentIdx + 1}/${_kTimelineLabels.length}',
              style: context.text.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
        AppGap.h14,
        // Pleine largeur : étapes fixes, connecteurs flexibles
        Row(
          children: List.generate(_kTimelineLabels.length * 2 - 1, (i) {
            if (i.isOdd) {
              final stepIndex = i ~/ 2;
              final isDone = stepIndex < currentIdx;
              return Expanded(child: _Connector(done: isDone));
            }
            final stepIndex = i ~/ 2;
            final isLastStep = stepIndex == _kTimelineLabels.length - 1;
            final isSettledLastStep = isLastStep && _isFinalStatusSettled;
            return _TimelineStep(
              label: _kTimelineLabels[stepIndex],
              isDone: stepIndex < currentIdx || isSettledLastStep,
              isCurrent: stepIndex == currentIdx && !isSettledLastStep,
            );
          }),
        ),
      ],
    );
  }
}

// ─── Étape individuelle ───────────────────────────────────────────────────────

class _TimelineStep extends StatefulWidget {
  final String label;
  final bool isDone;
  final bool isCurrent;
  const _TimelineStep({
    required this.label,
    required this.isDone,
    required this.isCurrent,
  });

  @override
  State<_TimelineStep> createState() => _TimelineStepState();
}

class _TimelineStepState extends State<_TimelineStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    if (widget.isCurrent) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _TimelineStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrent && !oldWidget.isCurrent) {
      _ctrl.repeat(reverse: true);
      return;
    }
    if (!widget.isCurrent && oldWidget.isCurrent) {
      _ctrl
        ..stop()
        ..value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.isCurrent
            ? AnimatedBuilder(
                animation: _anim,
                builder: (_, __) =>
                    Transform.scale(scale: _anim.value, child: _buildCircle()),
              )
            : _buildCircle(),
        AppGap.h6,
        SizedBox(
          width: 56,
          child: Text(
            widget.label,
            style: context.text.labelSmall?.copyWith(
              fontSize: AppFontSize.tiny,
              fontWeight: widget.isCurrent || widget.isDone
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: widget.isCurrent
                  ? context.colors.textPrimary
                  : widget.isDone
                  ? context.colors.textSecondary
                  : context.colors.textTertiary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCircle() {
    if (widget.isDone) {
      return Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(color: _kAccent, shape: BoxShape.circle),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 9),
      );
    }
    if (widget.isCurrent) {
      return Container(
        width: 16,
        height: 16,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: context.colors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: _kAccent.withValues(alpha: 0.32)),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(color: _kAccent, shape: BoxShape.circle),
        ),
      );
    }
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.surface,
        border: Border.all(color: context.colors.divider, width: 1.4),
      ),
    );
  }
}

// ─── Connecteur horizontal ────────────────────────────────────────────────────

class _Connector extends StatelessWidget {
  final bool done;
  const _Connector({required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.5,
      margin: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        color: done ? _kAccent : context.colors.divider,
        borderRadius: BorderRadius.circular(AppRadius.micro),
      ),
    );
  }
}
