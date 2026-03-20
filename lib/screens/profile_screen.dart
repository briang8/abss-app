// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: AppColors.textPrimary(context),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('My Profile', style: AppText.h3(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar + name ──
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            profile.name.isNotEmpty
                                ? profile.name[0].toUpperCase()
                                : 'A',
                            style: AppText.h1(
                              context,
                            ).copyWith(color: AppColors.primary, fontSize: 32),
                          ),
                        ),
                      ),
                      if (profile.isVerified)
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.background(context),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        profile.name.isEmpty ? 'ABSS User' : profile.name,
                        style: AppText.h2(context),
                      ),
                      if (profile.isVerified) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.isVerified ? 'Verified account' : 'Not verified',
                    style: AppText.caption(context).copyWith(
                      color: profile.isVerified
                          ? AppColors.primary
                          : AppColors.moderate,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Info rows ──
            Text('Account details', style: AppText.h3(context)),
            const SizedBox(height: 12),
            Container(
              decoration: AppDecorations.card(context),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: profile.phone.isEmpty ? 'Not set' : profile.phone,
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: profile.homeLocationId.isEmpty
                        ? 'Not set'
                        : profile.homeLocationId,
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.language_outlined,
                    label: 'Language',
                    value: _langLabel(profile.preferredLanguage),
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.wifi_outlined,
                    label: 'Mode',
                    value: profile.registrationType == 'offline'
                        ? 'SMS / Offline'
                        : 'Online',
                  ),
                  if (profile.isVerified && profile.verifiedAt != null) ...[
                    _Divider(),
                    _InfoRow(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Verified',
                      value: DateFormat(
                        'd MMM yyyy',
                      ).format(profile.verifiedAt!),
                      valueColor: AppColors.primary,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Alert preferences ──
            Text('Alert preferences', style: AppText.h3(context)),
            const SizedBox(height: 12),
            Container(
              decoration: AppDecorations.card(context),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected alert types',
                    style: AppText.caption(context).copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  if (profile.alertTypesEnabled.isEmpty)
                    Text('None selected', style: AppText.body(context))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: profile.alertTypesEnabled
                          .map(
                            (t) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Text(
                                t[0].toUpperCase() + t.substring(1),
                                style: AppText.caption(context).copyWith(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _langLabel(String code) => switch (code) {
    'sw' => 'Kiswahili',
    'rw' => 'Kinyarwanda',
    'am' => 'Amharic',
    'fr' => 'Français',
    _ => 'English',
  };
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted(context)),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: AppText.bodyMedium(context))),
        Text(
          value,
          style: AppText.caption(context).copyWith(
            color: valueColor ?? AppColors.textSecondary(context),
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    color: AppColors.border(context),
    margin: const EdgeInsets.symmetric(horizontal: 14),
  );
}
