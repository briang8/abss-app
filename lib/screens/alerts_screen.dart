import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart'; // for ShimmerBox, AlertCard, SeverityBadge, etc. if defined
import '../theme/app_theme.dart';       // for AppText, AppColors, AppDecorations

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Active Alerts',
          style: AppText.h3(context),
        ),
        actions: const [
          _RefreshButton(),
        ],
      ),
      body: alertsAsync.when(
        loading: () => const _AlertsLoading(),
        error: (err, stack) => const _AlertsError(),
        data: (alerts) {
          if (alerts.isEmpty) {
            return const _EmptyAlertsState();
          }
          return _AlertList(alerts: alerts);
        },
      ),
    );
  }
}


class _RefreshButton extends ConsumerStatefulWidget {
  const _RefreshButton();

  @override
  ConsumerState<_RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends ConsumerState<_RefreshButton> {
  bool _showBadge = false;

  Future<void> _handleRefresh() async {
    ref.invalidate(alertsProvider);
    ref.read(syncProvider.notifier).markSynced();

    setState(() {
      _showBadge = true;
    });

    await Future<void>.delayed(const Duration(seconds: 5));

    if (!mounted) return;
    setState(() {
      _showBadge = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: _handleRefresh,
        ),
        if (_showBadge)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Refreshed',
                style: AppText.caption(null).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}


class _AlertsLoading extends StatelessWidget {
  const _AlertsLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const ShimmerBox(
        height: 72,
        radius: 12,
      ),
    );
  }
}

class _AlertsError extends StatelessWidget {
  const _AlertsError();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 40,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to load alerts.\nPull down to retry.',
            textAlign: TextAlign.center,
            style: AppText.body(context).copyWith(
              color: AppColors.textMuted(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAlertsState extends StatelessWidget {
  const _EmptyAlertsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 40,
            color: Colors.green,
          ),
          const SizedBox(height: 8),
          Text(
            'No active alerts',
            style: AppText.body(context).copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


class _AlertList extends StatelessWidget {
  final List<AlertModel> alerts;

  const _AlertList({required this.alerts});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return AlertCard(
          alert: alert,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    AlertDetailScreen(alert: alert),
              ),
            );
          },
        );
      },
    );
  }
}


class AlertDetailScreen extends StatelessWidget {
  final AlertModel alert;

  const AlertDetailScreen({super.key, required this.alert});

  Color _severityColor(BuildContext context) {
    switch (alert.severity) {
      case AlertSeverity.critical:
        return AppColors.critical;
      case AlertSeverity.high:
        return AppColors.high;
      case AlertSeverity.moderate:
        return AppColors.moderate;
      case AlertSeverity.low:
        return AppColors.low;
    }
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = _severityColor(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alert Details',
          style: AppText.h3(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // Hero card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: severityColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      HazardIcon(
                        alert.type,
                        size: 28,
                        color: severityColor,
                      ),
                      const SizedBox(width: 8),
                      SeverityBadge(alert.severity),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    alert.title,
                    style: AppText.h2(context).copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Chip(
                        icon: Icons.place_rounded,
                        label: alert.locationName,
                      ),
                      _Chip(
                        icon: Icons.schedule_rounded,
                        label:
                            '${alert.startTime}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    alert.messagePlain,
                    style: AppText.body(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Safety steps
            Text(
              'Safety steps',
              style: AppText.h3(context).copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            // For now, using generic placeholder steps since
            // detailed steps are not part of the model.
            _SafetyStep(
              index: 1,
              text:
                  'Stay informed through local authorities and trusted channels.',
            ),
            _SafetyStep(
              index: 2,
              text:
                  'Avoid low-lying areas and move to higher ground if flooding is possible.',
            ),
            _SafetyStep(
              index: 3,
              text:
                  'Prepare an emergency kit and keep your phone charged.',
            ),
            const SizedBox(height: 24),

            // Source card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: AppDecorations.card(
                context,
                borderColor:
                    AppColors.border(context),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.verified_outlined,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Source: ${alert.source}',
                      style: AppText.body(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Chip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardAlt(context),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textSecondary(context),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppText.caption(context),
          ),
        ],
      ),
    );
  }
}


class _SafetyStep extends StatelessWidget {
  final int index;
  final String text;

  const _SafetyStep({
    required this.index,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$index',
              style: AppText.caption(null).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppText.body(context),
            ),
          ),
        ],
      ),
    );
  }
}