import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart'; // for WeatherIcon, ShimmerBox, etc.

class ForecastScreen extends ConsumerStatefulWidget {
  const ForecastScreen({super.key});

  @override
  ConsumerState<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends ConsumerState<ForecastScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(forecastProvider);
  }

  @override
  Widget build(BuildContext context) {
    final forecastAsync = ref.watch(forecastProvider);
    final loc = ref.watch(locationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Forecast', style: AppText.h3(context)),
            const SizedBox(height: 2),
            Text(
              loc.locationName,
              style: AppText.caption(
                context,
              ).copyWith(color: AppColors.textSecondary(context)),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Open-Meteo',
              style: AppText.caption(
                null,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: AppText.h4(null),
          unselectedLabelStyle: AppText.body(null),
          tabs: const [
            Tab(text: '24 Hours'),
            Tab(text: '10 Days'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: forecastAsync.when(
          loading: () => const _ForecastLoading(),
          error: (err, stack) => const _ForecastError(),
          data: (forecast) {
            return Column(
              children: [
                _CacheNotice(isFromCache: forecast.isFromCache),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _HourlyView(hourly: forecast.hourly),
                      _DailyView(daily: forecast.daily),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ForecastLoading extends StatelessWidget {
  const _ForecastLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ShimmerBox(height: 90, radius: 16),
        SizedBox(height: 12),
        ShimmerBox(height: 90, radius: 16),
        SizedBox(height: 12),
        ShimmerBox(height: 90, radius: 16),
      ],
    );
  }
}

class _ForecastError extends StatelessWidget {
  const _ForecastError();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 40, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                'Unable to load forecast.\nPull down to retry.',
                textAlign: TextAlign.center,
                style: AppText.body(
                  context,
                ).copyWith(color: AppColors.textMuted(context)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CacheNotice extends StatelessWidget {
  final bool isFromCache;

  const _CacheNotice({required this.isFromCache});

  @override
  Widget build(BuildContext context) {
    if (!isFromCache) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.amber.withValues(alpha: 0.18),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing last saved forecast. Pull down to refresh when you are online.',
              style: AppText.caption(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyView extends StatelessWidget {
  final List<HourlyForecast> hourly;

  const _HourlyView({required this.hourly});

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) {
      return const Center(child: Text('No hourly data'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: hourly.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final h = hourly[index];
        final timeLabel = index == 0 ? 'Now' : _formatTime(h.time);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: AppDecorations.card(context),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Text(timeLabel, style: AppText.body(context)),
              ),
              const SizedBox(width: 8),
              WeatherIcon(
                condition: h.condition,
                size: 28,
                color: AppColors.textPrimary(context),
              ),
              const SizedBox(width: 12),
              Text(
                '${h.temperatureC.toStringAsFixed(0)}°',
                style: AppText.h3(context),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rain ${h.rainProbability.toStringAsFixed(0)}%',
                    style: AppText.caption(context),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Wind ${h.windSpeedKph.toStringAsFixed(0)} km/h',
                    style: AppText.caption(context),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

class _DailyView extends StatelessWidget {
  final List<DailyForecast> daily;

  const _DailyView({required this.daily});

  @override
  Widget build(BuildContext context) {
    if (daily.isEmpty) {
      return const Center(child: Text('No daily data'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: daily.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final d = daily[index];
        final label = _formatDay(d.date);

        final min = d.tempMinC;
        final max = d.tempMaxC;
        final range = (max - min).abs() < 0.1 ? 1.0 : (max - min).abs();
        final value = ((max - min) / range).clamp(0.0, 1.0);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: AppDecorations.card(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: AppText.body(
                      context,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    '${max.toStringAsFixed(0)}°',
                    style: AppText.body(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: value,
                backgroundColor: AppColors.cardAlt(context),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    'Min ${min.toStringAsFixed(0)}°',
                    style: AppText.caption(context),
                  ),
                  const Spacer(),
                  Text(
                    'Rain ${d.rainProbability.toStringAsFixed(0)}% · ${d.rainfallMm.toStringAsFixed(1)} mm',
                    style: AppText.caption(context),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDay(DateTime d) {
    // Simple DD/MM label; can be replaced by intl DateFormat later
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
  }
}
