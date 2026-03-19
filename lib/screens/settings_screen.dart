// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';
import 'profile_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final profile  = ref.watch(userProfileProvider);
    final sync     = ref.watch(syncProvider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text('Settings', style: AppText.h2(context)),
              const SizedBox(height: 20),

              // ── Profile card ──────────────────────────────────────────────────
              GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppDecorations.card(context),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 52, height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                profile?.name.isNotEmpty == true ? profile!.name[0].toUpperCase() : 'A',
                                style: AppText.h3(context).copyWith(color: AppColors.primary, fontSize: 22),
                              ),
                            ),
                          ),
                          if (profile?.isVerified == true)
                            Container(
                              width: 18, height: 18,
                              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: AppColors.background(context), width: 1.5)),
                              child: const Icon(Icons.verified_rounded, size: 10, color: Colors.white),
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text(profile?.name.isEmpty != false ? 'ABSS User' : profile!.name, style: AppText.h4(context)),
                              if (profile?.isVerified == true) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.verified_rounded, size: 14, color: AppColors.primary),
                              ],
                            ]),
                            Text(profile?.phone.isEmpty != false ? 'No phone set' : profile!.phone, style: AppText.caption(context)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: AppColors.textMuted(context), size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Appearance ────────────────────────────────────────────────────
              Text('Appearance', style: AppText.h3(context)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: AppDecorations.card(context),
                child: Row(
                  children: [
                    Icon(isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined, size: 20, color: isDark ? AppColors.info : AppColors.moderate),
                    const SizedBox(width: 12),
                    Expanded(child: Text(isDark ? 'Dark Mode' : 'Light Mode', style: AppText.h4(context))),
                    // This Switch now drives ThemeMode on MaterialApp correctly
                    Switch(
                      value: isDark,
                      onChanged: (v) {
                        ref.read(themeProvider.notifier).setTheme(v ? ThemeMode.dark : ThemeMode.light);
                      },
                      activeThumbColor: AppColors.primary,
                      inactiveTrackColor: AppColors.border(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text('Light mode is recommended for outdoor use in bright conditions.', style: AppText.caption(context).copyWith(fontSize: 11)),
              ),

              const SizedBox(height: 24),

              // ── Sync info ─────────────────────────────────────────────────────
              Text('Data', style: AppText.h3(context)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.card(context),
                child: Column(
                  children: [
                    _DataRow(label: 'Forecast source', value: 'Open-Meteo (free, no key required)'),
                    _HDivider(),
                    _DataRow(label: 'Alert source', value: 'Meteo Rwanda / ICPAC (demo)'),
                    _HDivider(),
                    _DataRow(label: 'Last sync', value: sync.lastForecastSync != null ? DateFormat('MMM dd · HH:mm').format(sync.lastForecastSync!) : 'Never'),
                    _HDivider(),
                    _DataRow(label: 'App version', value: '1.0.0'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── How to use ABSS ───────────────────────────────────────────────
              Text('How to use ABSS', style: AppText.h3(context)),
              const SizedBox(height: 12),
              _HelpCard(
                icon: Icons.home_outlined,
                title: 'Home screen',
                body: 'Shows your current weather, temperature and rain probability. The active alert banner appears here when something is happening in your area. Tap it to see details.',
              ),
              const SizedBox(height: 8),
              _HelpCard(
                icon: Icons.warning_amber_outlined,
                title: 'Alerts screen',
                body: 'See all current alerts for your location. Tap any alert to read the full explanation and safety steps. Tap the refresh icon at the top right to pull the latest data.',
              ),
              const SizedBox(height: 8),
              _HelpCard(
                icon: Icons.cloud_outlined,
                title: 'Forecast screen',
                body: 'Switch between 24-Hour and 10-Day tabs. The 24-Hour tab shows hourly temperature, rain chance and wind. The 10-Day tab shows daily highs, lows and rainfall totals. Pull down to refresh.',
              ),
              const SizedBox(height: 8),
              _HelpCard(
                icon: Icons.refresh_rounded,
                title: 'Offline & syncing',
                body: 'Open the app at least once a day while connected so forecasts and alerts stay fresh. A banner appears at the top when a sync is overdue. Tap "Refresh" to update immediately.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  const _DataRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(children: [
      Expanded(child: Text(label, style: AppText.bodyMedium(context).copyWith(fontSize: 14))),
      Flexible(child: Text(value, style: AppText.caption(context).copyWith(fontSize: 12), textAlign: TextAlign.right)),
    ]),
  );
}

class _HDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(height: 1, color: AppColors.border(context));
}

class _HelpCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String body;
  const _HelpCard({required this.icon, required this.title, required this.body});
  @override State<_HelpCard> createState() => _HelpCardState();
}

class _HelpCardState extends State<_HelpCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: AppDecorations.card(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(widget.icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(widget.title, style: AppText.h4(context))),
              AnimatedRotation(
                turns: _open ? 0.5 : 0,
                duration: const Duration(milliseconds: 220),
                child: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted(context), size: 20),
              ),
            ]),
            if (_open) ...[
              const SizedBox(height: 10),
              Text(widget.body, style: AppText.body(context).copyWith(fontSize: 13, height: 1.6)),
            ],
          ],
        ),
      ),
    );
  }
}
