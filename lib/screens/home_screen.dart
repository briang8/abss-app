// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';
import '../models/models.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location    = ref.watch(locationProvider);
    final forecast    = ref.watch(forecastProvider);
    final activeAlerts= ref.watch(activeAlertsProvider);
    final profile     = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.card(context),
          onRefresh: () async {
            ref.invalidate(forecastProvider);
            ref.invalidate(alertsProvider);
            ref.read(syncProvider.notifier).markSynced();
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header(location: location.locationName, profile: profile)),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Weather hero
              SliverToBoxAdapter(
                child: forecast.when(
                  data: (f) => _WeatherHero(forecast: f),
                  loading: () => _WeatherHeroSkeleton(),
                  error: (_, _) => _OfflineWeatherHero(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // Active alert banner
              SliverToBoxAdapter(
                child: activeAlerts.when(
                  data: (a) => a.isEmpty ? const SizedBox.shrink() : _ActiveAlertBanner(alert: a.first),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // 24h strip
              SliverToBoxAdapter(
                child: forecast.when(
                  data: (f) => _HourlyStrip(hourly: f.hourly),
                  loading: () => _HourlyStripSkeleton(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // Quick actions
              const SliverToBoxAdapter(child: _QuickActions()),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String location;
  final dynamic profile;
  const _Header({required this.location, required this.profile});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$greeting${profile?.name != null && profile!.name.isNotEmpty ? ", ${profile!.name.split(' ').first}" : ""}', style: AppText.caption(context).copyWith(fontSize: 13)),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(location, style: AppText.h4(context)),
                ]),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border(context))),
            child: Row(children: [
              Icon(Icons.access_time_rounded, size: 12, color: AppColors.textMuted(context)),
              const SizedBox(width: 4),
              Text(DateFormat('HH:mm').format(DateTime.now()), style: AppText.caption(context).copyWith(fontSize: 12)),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─── Weather Hero ─────────────────────────────────────────────────────────────
class _WeatherHero extends StatelessWidget {
  final ForecastModel forecast;
  const _WeatherHero({required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.heroWeather(context),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${forecast.currentTemp.round()}°', style: AppText.display(context)),
                    const SizedBox(height: 4),
                    Text(_conditionLabel(forecast.currentCondition), style: AppText.body(context).copyWith(fontSize: 16)),
                    Text('Feels like ${forecast.feelsLike.round()}°C', style: AppText.caption(context)),
                  ],
                ),
              ),
              WeatherIcon(condition: forecast.currentCondition, size: 72),
            ],
          ),
          const SizedBox(height: 20),
          Row(children: [
            _StatPill(icon: Icons.water_drop_outlined, value: '${forecast.humidity.round()}%', label: 'Humidity'),
            const SizedBox(width: 10),
            _StatPill(icon: Icons.air_rounded, value: '${forecast.windKph.round()} km/h', label: 'Wind'),
            const SizedBox(width: 10),
            _StatPill(icon: Icons.grain_outlined, value: '${forecast.rainProbability.round()}%', label: 'Rain'),
          ]),
        ],
      ),
    );
  }

  String _conditionLabel(String c) => switch (c) {
    'sunny'  => 'Clear skies',
    'cloudy' => 'Overcast',
    'rainy'  => 'Rain likely',
    'stormy' => 'Thunderstorm',
    _        => 'Cloudy',
  };
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatPill({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border(context).withValues(alpha: 0.5)),
        ),
        child: Column(children: [
          Icon(icon, size: 16, color: AppColors.textSecondary(context)),
          const SizedBox(height: 4),
          Text(value, style: AppText.h4(context).copyWith(fontSize: 14)),
          Text(label, style: AppText.caption(context).copyWith(fontSize: 10)),
        ]),
      ),
    );
  }
}

class _WeatherHeroSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    height: 180,
    decoration: AppDecorations.heroWeather(context),
    padding: const EdgeInsets.all(24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const ShimmerBox(width: 100, height: 64, radius: 12),
      const SizedBox(height: 12),
      const ShimmerBox(width: 140, height: 18, radius: 6),
    ]),
  );
}

class _OfflineWeatherHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(24),
    decoration: AppDecorations.card(context),
    child: Row(children: [
      Icon(Icons.wifi_off_rounded, color: AppColors.textMuted(context), size: 32),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Offline – No new forecast', style: AppText.h4(context)),
        const SizedBox(height: 4),
        Text('Connect to internet to refresh.', style: AppText.body(context)),
      ])),
    ]),
  );
}

// ─── Active Alert Banner ──────────────────────────────────────────────────────
class _ActiveAlertBanner extends ConsumerWidget {
  final AlertModel alert;
  const _ActiveAlertBanner({required this.alert});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = AppSeverity.fromString(alert.severity.name);
    return GestureDetector(
      onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 1,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: style.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: style.color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: style.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Center(child: HazardIcon(type: alert.type, size: 18, color: style.color)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  SeverityBadge(severity: alert.severity),
                  const SizedBox(width: 8),
                  Expanded(child: Text(alert.title, style: AppText.h4(context), overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 2),
                Text(alert.locationName, style: AppText.caption(context)),
              ]),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, color: AppColors.textMuted(context), size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── Hourly Strip ─────────────────────────────────────────────────────────────
class _HourlyStrip extends ConsumerWidget {
  final List<HourlyForecast> hourly;
  const _HourlyStrip({required this.hourly});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader(
            title: 'Next 24 hours',
            actionLabel: 'Full forecast →',
            onAction: () => ref.read(bottomNavIndexProvider.notifier).state = 2, // → Forecast tab
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 108,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: hourly.take(24).length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final h = hourly[i];
              final isNow = i == 0;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 72,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  color: isNow ? AppColors.info.withValues(alpha: 0.1) : AppColors.card(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isNow ? AppColors.info.withValues(alpha: 0.4) : AppColors.border(context),
                    width: isNow ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isNow ? 'Now' : DateFormat('HH:mm').format(h.time), style: AppText.caption(context).copyWith(fontSize: 11, color: isNow ? AppColors.info : AppColors.textMuted(context))),
                    WeatherIcon(condition: h.condition, size: 22),
                    Text('${h.tempC.round()}°', style: AppText.h4(context).copyWith(fontSize: 16)),
                    Text('${h.rainProbability.round()}%', style: AppText.caption(context).copyWith(color: AppColors.info, fontSize: 11)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HourlyStripSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: ShimmerBox(width: 120, height: 18, radius: 6)),
      const SizedBox(height: 12),
      SizedBox(
        height: 108,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: 7,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, _) => const ShimmerBox(width: 72, height: 108, radius: 14),
        ),
      ),
    ],
  );
}

// ─── Quick Actions ────────────────────────────────────────────────────────────
class _QuickActions extends ConsumerWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = [
      (icon: Icons.warning_amber_rounded, label: 'View Alerts',      color: AppColors.high,    navIndex: 1),
      (icon: Icons.cloud_outlined,        label: 'Full Forecast',     color: AppColors.info,    navIndex: 2),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Quick actions'),
          const SizedBox(height: 12),
          Row(
            children: actions.map((a) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => ref.read(bottomNavIndexProvider.notifier).state = a.navIndex,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: AppDecorations.card(context),
                    child: Row(children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: a.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                        child: Icon(a.icon, size: 18, color: a.color),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(a.label, style: AppText.h4(context).copyWith(fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis)),
                    ]),
                  ),
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
