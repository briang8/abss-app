// lib/widgets/shared_widgets.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

// ─── AbssCard ─────────────────────────────────────────────────────────────────
class AbssCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final BoxDecoration? decoration;

  const AbssCard({super.key, required this.child, this.padding, this.onTap, this.decoration});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: decoration ?? AppDecorations.card(context),
      child: child,
    );
    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }
}

// ─── SeverityBadge ────────────────────────────────────────────────────────────
class SeverityBadge extends StatelessWidget {
  final AlertSeverity severity;
  const SeverityBadge({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    final s = AppSeverity.fromString(severity.name);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: s.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(s.label, style: AppText.label(null).copyWith(color: s.color, letterSpacing: 0.8)),
    );
  }
}

// ─── HazardIcon ───────────────────────────────────────────────────────────────
class HazardIcon extends StatelessWidget {
  final AlertType type;
  final double size;
  final Color? color;
  const HazardIcon({super.key, required this.type, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    final ic = switch (type) {
      AlertType.flood      => Icons.water_outlined,
      AlertType.storm      => Icons.thunderstorm_outlined,
      AlertType.drought    => Icons.wb_sunny_outlined,
      AlertType.earthquake => Icons.vibration_outlined,
      AlertType.heatwave   => Icons.thermostat_outlined,
    };
    final c = color ?? switch (type) {
      AlertType.flood      => AppColors.info,
      AlertType.storm      => AppColors.high,
      AlertType.drought    => AppColors.moderate,
      AlertType.earthquake => AppColors.critical,
      AlertType.heatwave   => AppColors.high,
    };
    return Icon(ic, size: size, color: c);
  }
}

// ─── WeatherIcon ──────────────────────────────────────────────────────────────
class WeatherIcon extends StatelessWidget {
  final String condition;
  final double size;
  final Color? color;
  const WeatherIcon({super.key, required this.condition, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    final (ic, dc) = switch (condition) {
      'sunny'  => (Icons.wb_sunny_outlined,    const Color(0xFFF59E0B)),
      'cloudy' => (Icons.cloud_outlined,        const Color(0xFF94A3B8)),
      'rainy'  => (Icons.grain_outlined,        AppColors.info),
      'stormy' => (Icons.thunderstorm_outlined, AppColors.high),
      _        => (Icons.cloud_outlined,        const Color(0xFF94A3B8)),
    };
    return Icon(ic, size: size, color: color ?? dc);
  }
}

// ─── AbssButton ───────────────────────────────────────────────────────────────
class AbssButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isLoading;
  final Color? color;
  final bool outlined;

  const AbssButton({super.key, required this.label, this.onTap, this.icon, this.isLoading = false, this.color, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.primary;
    final disabled = onTap == null && !isLoading;
    return AnimatedOpacity(
      opacity: disabled ? 0.45 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              gradient: (!outlined && !disabled) ? LinearGradient(colors: [bg, bg.withValues(alpha: 0.85)], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
              color: outlined ? Colors.transparent : (disabled ? bg : null),
              borderRadius: BorderRadius.circular(14),
              border: outlined ? Border.all(color: bg, width: 1.5) : null,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: (disabled || isLoading) ? null : onTap,
              splashColor: Colors.white.withValues(alpha: 0.1),
              child: Center(
                child: isLoading
                    ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: outlined ? bg : Colors.white))
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[Icon(icon, size: 18, color: outlined ? bg : Colors.white), const SizedBox(width: 8)],
                          Text(label, style: AppText.button.copyWith(color: outlined ? bg : Colors.white)),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── OfflineSyncBanner ────────────────────────────────────────────────────────
class OfflineSyncBanner extends StatelessWidget {
  final DateTime? lastSync;
  final VoidCallback? onSync;
  const OfflineSyncBanner({super.key, this.lastSync, this.onSync});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = AppColors.moderate.withValues(alpha: isDark ? 0.1 : 0.08);
    final border = AppColors.moderate.withValues(alpha: 0.25);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, size: 14, color: AppColors.moderate),
          const SizedBox(width: 8),
          Expanded(child: Text('Last synced: ${_fmt(lastSync)} · Tap to refresh', style: AppText.caption(null).copyWith(color: AppColors.moderate))),
          if (onSync != null) GestureDetector(onTap: onSync, child: Icon(Icons.refresh_rounded, size: 16, color: AppColors.moderate)),
        ],
      ),
    );
  }

  String _fmt(DateTime? dt) {
    if (dt == null) return 'Never';
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}

// ─── SectionHeader ────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(title, style: AppText.h3(context))),
      if (actionLabel != null)
        GestureDetector(onTap: onAction, child: Text(actionLabel!, style: AppText.caption(null).copyWith(color: AppColors.info))),
    ],
  );
}

// ─── AlertCard ────────────────────────────────────────────────────────────────
class AlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onTap;
  final bool compact;
  const AlertCard({super.key, required this.alert, this.onTap, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final s = AppSeverity.fromString(alert.severity.name);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AbssCard(
      onTap: onTap,
      decoration: compact ? AppDecorations.glowCard(s.color) : AppDecorations.card(context),
      child: Row(
        children: [
          Container(
            width: compact ? 38 : 44, height: compact ? 38 : 44,
            decoration: BoxDecoration(color: s.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: Center(child: HazardIcon(type: alert.type, size: compact ? 18 : 20, color: s.color)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  SeverityBadge(severity: alert.severity),
                  const SizedBox(width: 8),
                  Expanded(child: Text(alert.title, style: AppText.h4(context), overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 4),
                if (!compact) Text(alert.messagePlain, style: AppText.body(context), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.location_on_outlined, size: 11, color: AppColors.textMuted(context)),
                  const SizedBox(width: 2),
                  Text(alert.locationName, style: AppText.caption(context)),
                  const SizedBox(width: 10),
                  Icon(Icons.schedule_outlined, size: 11, color: AppColors.textMuted(context)),
                  const SizedBox(width: 2),
                  Text(_fmtTime(alert.startTime), style: AppText.caption(context)),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: AppColors.textMuted(context), size: 20),
        ],
      ),
    );
  }

  String _fmtTime(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.isNegative) return 'In ${-d.inHours}h';
    if (d.inMinutes < 60) return 'Active now';
    return '${d.inHours}h ago';
  }
}

// ─── ShimmerBox ───────────────────────────────────────────────────────────────
class ShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;
  const ShimmerBox({super.key, this.width, required this.height, this.radius = 8});

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
    _a = Tween<double>(begin: -1, end: 2).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c1 = isDark ? AppColors.darkBorder       : AppColors.lightBorder;
    final c2 = isDark ? AppColors.darkCardAlt       : const Color(0xFFE8EEF4);
    return AnimatedBuilder(
      animation: _a,
      builder: (_, _) => Container(
        width: widget.width, height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            stops: [(_a.value - 0.4).clamp(0.0, 1.0), _a.value.clamp(0.0, 1.0), (_a.value + 0.4).clamp(0.0, 1.0)],
            colors: [c1, c2, c1],
          ),
        ),
      ),
    );
  }
}
