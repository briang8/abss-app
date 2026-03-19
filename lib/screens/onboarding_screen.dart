// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';
import '../utils/app_localizations.dart';

// ─── Data ─────────────────────────────────────────────────────────────────────
const _languageEntries = [
  ('English', 'en'), ('Kiswahili', 'sw'), ('Kinyarwanda', 'rw'), ('Amharic', 'am'), ('Français', 'fr'),
];

const _locations = [
  ('kigali_rw',    -1.9441, 30.0619, 'Kigali, Rwanda'),
  ('nairobi_ke',  -1.2921, 36.8219, 'Nairobi, Kenya'),
  ('addis_et',     9.0320, 38.7469, 'Addis Ababa, Ethiopia'),
  ('kampala_ug',   0.3163, 32.5822, 'Kampala, Uganda'),
  ('dar_tz',      -6.7924, 39.2083, 'Dar es Salaam, Tanzania'),
  ('bujumbura_bi',-3.3814, 29.3613, 'Bujumbura, Burundi'),
];

// ── Phone number rules per country ───────────────────────────────────────────
// (dialCode, totalDigitsAfterDial, validFirstDigits, countryName)
const _phoneRules = <String, (String, int, List<String>, String)>{
  'kigali_rw':    ('+250', 9, ['7'], 'Rwanda'),
  'nairobi_ke':   ('+254', 9, ['7', '1'], 'Kenya'),
  'addis_et':     ('+251', 9, ['9', '7'], 'Ethiopia'),
  'kampala_ug':   ('+256', 9, ['7', '8'], 'Uganda'),
  'dar_tz':       ('+255', 9, ['7', '6'], 'Tanzania'),
  'bujumbura_bi': ('+257', 8, ['7', '6', '2'], 'Burundi'),
  'auto':         ('+250', 9, ['7'], ''),
};

(String, int, List<String>, String) _rulesFor(String locId) => _phoneRules[locId] ?? ('+250', 9, ['7'], '');

enum _RegType { online, offline }
enum _VerifStep { idle, codeSent, verified }

// ─── Root ─────────────────────────────────────────────────────────────────────
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override ConsumerState<OnboardingScreen> createState() => _OnboardingState();
}

class _OnboardingState extends ConsumerState<OnboardingScreen> with TickerProviderStateMixin {
  int _step = 0;
  String _langName = 'English';
  String _langCode = 'en';
  String _locId = '';
  String _locName = '';
  double? _locLat, _locLng;
  _RegType? _regType;
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final Set<String> _alertTypes = {'flood', 'storm'};

  late final AnimationController _fadeCtrl;
  late final AnimationController _slideCtrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<Offset>   _slideAnim;

  L10n get _l => L10n.of(_langCode);

  @override
  void initState() {
    super.initState();
    _fadeCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 290));
    _fadeAnim  = CurvedAnimation(parent: _fadeCtrl,  curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _fadeCtrl.forward(); _slideCtrl.forward();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); _slideCtrl.dispose(); _nameCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }

  void _transition(VoidCallback fn) {
    _fadeCtrl.reset(); _slideCtrl.reset();
    setState(fn);
    _fadeCtrl.forward(); _slideCtrl.forward();
  }

  void _next() => _transition(() => _step++);
  void _back() => _transition(() => _step--);

  Future<void> _finish() async {
    final (dial, _, __, ___) = _rulesFor(_locId);
    final fullPhone = '$dial${_phoneCtrl.text.trim()}';
    ref.read(localeProvider.notifier).setCode(_langCode);
    ref.read(locationProvider.notifier).setLocation(_locId, _locName, lat: _locLat, lng: _locLng);
    await ref.read(userRegistrationTypeProvider.notifier).setType(
      _regType == _RegType.offline ? UserRegistrationType.offline : UserRegistrationType.online,
    );
    final profile = UserProfile(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim().isEmpty ? 'ABSS User' : _nameCtrl.text.trim(),
      phone: fullPhone,
      preferredLanguage: _langCode,
      homeLocationId: _locId,
      homeLocationName: _locName,
      registrationType: _regType == _RegType.offline ? 'offline' : 'online',
      notificationOn: true,
      alertTypesEnabled: _alertTypes.toList(),
      isVerified: true,
      verifiedAt: DateTime.now(),
    );
    ref.read(userProfileProvider.notifier).setProfile(profile);
    await ref.read(dailyCheckInProvider.notifier).checkIn();
    await ref.read(onboardingProvider.notifier).complete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            if (_step > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18), color: AppColors.textSecondary(context), onPressed: _back),
                    const Spacer(),
                    Row(children: List.generate(4, (i) {
                      final active = (_step - 1) == i;
                      final done   = (_step - 1) > i;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 22 : 6, height: 6,
                        decoration: BoxDecoration(
                          color: done ? AppColors.primary.withValues(alpha: 0.4) : (active ? AppColors.primary : AppColors.border(context)),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    })),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(position: _slideAnim, child: _buildStep()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _WelcomeStep(l: _l, onStart: _next);
      case 1: return _LanguageStep(l: _l, selected: _langName, onSelect: (n, c) => setState(() { _langName = n; _langCode = c; }), onNext: _next);
      case 2: return _LocationStep(
        l: _l, selectedId: _locId,
        onSelect: (id, name, lat, lng) => setState(() { _locId = id; _locName = name; _locLat = lat; _locLng = lng; }),
        onNext: _next,
      );
      case 3: return _UserTypeStep(l: _l, selected: _regType, onSelect: (t) => setState(() => _regType = t), onNext: _next);
      default:
        return _regType == _RegType.offline
            ? _OfflineSetupStep(l: _l, langCode: _langCode, locId: _locId, phoneCtrl: _phoneCtrl, alertTypes: _alertTypes, onToggle: (t) => setState(() { _alertTypes.contains(t) ? _alertTypes.remove(t) : _alertTypes.add(t); }), onDone: _finish)
            : _OnlineSetupStep(l: _l, langCode: _langCode, locId: _locId, nameCtrl: _nameCtrl, phoneCtrl: _phoneCtrl, onDone: _finish);
    }
  }
}

// ─── Step 0: Welcome ──────────────────────────────────────────────────────────
class _WelcomeStep extends StatelessWidget {
  final L10n l; final VoidCallback onStart;
  const _WelcomeStep({required this.l, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // Text-only logo — no circular icon
          Text('ABSS', style: GoogleFonts.dmSans(fontSize: 52, fontWeight: FontWeight.w900, letterSpacing: 3, color: AppColors.primary)),
          const SizedBox(height: 6),
          Text('Alerts by Stay Safe', style: AppText.caption(context).copyWith(letterSpacing: 1.2, fontSize: 13)),
          const SizedBox(height: 20),
          Text(
            'Know before the storm hits.\nStay safe wherever you are.',
            style: AppText.h2(context).copyWith(height: 1.35, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Real-time climate alerts and forecasts for East Africa — online or offline.',
            style: AppText.body(context).copyWith(fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          _FeatureRow(icon: Icons.notifications_active_outlined, color: AppColors.critical, text: 'Early disaster alerts via push & SMS'),
          const SizedBox(height: 12),
          _FeatureRow(icon: Icons.cloud_queue_outlined,          color: AppColors.info,     text: 'Offline-first weather forecasts'),
          const SizedBox(height: 12),
          _FeatureRow(icon: Icons.language_outlined,             color: AppColors.primary,  text: 'Available in 5 languages'),
          const Spacer(flex: 2),
          AbssButton(label: l.getStarted, onTap: onStart, icon: Icons.arrow_forward_rounded),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon; final Color color; final String text;
  const _FeatureRow({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 20, color: color)),
    const SizedBox(width: 14),
    Expanded(child: Text(text, style: AppText.bodyMedium(context).copyWith(fontSize: 14))),
  ]);
}

// ─── Step 1: Language ─────────────────────────────────────────────────────────
class _LanguageStep extends StatelessWidget {
  final L10n l; final String selected; final void Function(String, String) onSelect; final VoidCallback onNext;
  const _LanguageStep({required this.l, required this.selected, required this.onSelect, required this.onNext});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('Step 1 of 4', style: AppText.caption(context)),
        const SizedBox(height: 6),
        Text(l.chooseLanguage, style: AppText.h2(context)),
        const SizedBox(height: 6),
        Text(l.chooseLanguageSub, style: AppText.body(context)),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.separated(
            itemCount: _languageEntries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final (name, code) = _languageEntries[i];
              final sel = name == selected;
              return _Tile(selected: sel, onTap: () => onSelect(name, code), child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: AppText.bodyMedium(context)),
                  Text(L10n.of(code).cont, style: AppText.caption(context).copyWith(fontSize: 11, color: sel ? AppColors.primary.withValues(alpha: 0.75) : AppColors.textMuted(context))),
                ]),
                const Spacer(),
                if (sel) const Icon(Icons.check_rounded, color: AppColors.primary, size: 20),
              ]));
            },
          ),
        ),
        const SizedBox(height: 16),
        AbssButton(label: l.cont, onTap: onNext),
        const SizedBox(height: 16),
      ],
    ),
  );
}

// ─── Step 2: Location (with real location permission) ─────────────────────────
class _LocationStep extends ConsumerStatefulWidget {
  final L10n l;
  final String selectedId;
  final void Function(String id, String name, double? lat, double? lng) onSelect;
  final VoidCallback onNext;
  const _LocationStep({required this.l, required this.selectedId, required this.onSelect, required this.onNext});

  @override ConsumerState<_LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends ConsumerState<_LocationStep> {
  bool _detecting = false;
  String? _detectError;

  Future<void> _detectLocation() async {
    setState(() { _detecting = true; _detectError = null; });
    try {
      // 1. Check / request permission
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        setState(() { _detecting = false; _detectError = 'Location permission denied. Please choose manually.'; });
        return;
      }

      // 2. Get position
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium, timeLimit: const Duration(seconds: 10));

      // 3. Reverse-geocode
      String name = 'Current Location';
      try {
        final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          name = '${p.locality ?? p.subAdministrativeArea ?? ''}, ${p.country ?? ''}'.trim().replaceAll(RegExp(r'^, |, $'), '');
        }
      } catch (_) {}

      widget.onSelect('auto', name, pos.latitude, pos.longitude);
      setState(() => _detecting = false);
    } catch (e) {
      setState(() { _detecting = false; _detectError = 'Could not detect location. Please choose manually.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Step 2 of 4', style: AppText.caption(context)),
          const SizedBox(height: 6),
          Text(widget.l.setLocation, style: AppText.h2(context)),
          const SizedBox(height: 6),
          Text(widget.l.setLocationSub, style: AppText.body(context)),
          const SizedBox(height: 14),
          // Auto-detect tile
          _Tile(
            selected: widget.selectedId == 'auto',
            onTap: _detectLocation,
            child: Row(children: [
              Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: _detecting ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.info))) : const Icon(Icons.my_location_rounded, size: 18, color: AppColors.info)),
              const SizedBox(width: 12),
              Expanded(child: Text(widget.l.detectLocation, style: AppText.bodyMedium(context))),
              if (widget.selectedId == 'auto') const Icon(Icons.check_rounded, color: AppColors.primary, size: 20),
            ]),
          ),
          if (_detectError != null) ...[
            const SizedBox(height: 6),
            Text(_detectError!, style: AppText.caption(context).copyWith(color: AppColors.critical, fontSize: 12)),
          ],
          const SizedBox(height: 12),
          Text(widget.l.chooseCity, style: AppText.caption(context)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: _locations.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final (id, lat, lng, name) = _locations[i];
                final sel = id == widget.selectedId;
                return _Tile(
                  selected: sel, compact: true,
                  onTap: () => widget.onSelect(id, name, lat, lng),
                  child: Row(children: [
                    Icon(Icons.location_on_outlined, size: 16, color: sel ? AppColors.primary : AppColors.textMuted(context)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(name, style: AppText.bodyMedium(context).copyWith(fontSize: 14))),
                    if (sel) const Icon(Icons.check_rounded, color: AppColors.primary, size: 18),
                  ]),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          AbssButton(label: widget.l.cont, onTap: widget.selectedId.isNotEmpty ? widget.onNext : null),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Step 3: User type ────────────────────────────────────────────────────────
class _UserTypeStep extends StatelessWidget {
  final L10n l; final _RegType? selected; final void Function(_RegType) onSelect; final VoidCallback onNext;
  const _UserTypeStep({required this.l, required this.selected, required this.onSelect, required this.onNext});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 3 of 4', style: AppText.caption(context)),
        const SizedBox(height: 6),
        Text(l.howUseAbss, style: AppText.h2(context)),
        const SizedBox(height: 6),
        Text('Choose how you want to receive alerts.', style: AppText.body(context)),
        const SizedBox(height: 20),
        _TypeCard(selected: selected == _RegType.online, onTap: () => onSelect(_RegType.online), icon: Icons.wifi_rounded, iconColor: AppColors.info, title: l.onlineMode, subtitle: l.onlineModeDesc, bullets: l.onlineBenefits),
        const SizedBox(height: 14),
        _TypeCard(selected: selected == _RegType.offline, onTap: () => onSelect(_RegType.offline), icon: Icons.sms_outlined, iconColor: AppColors.primary, title: l.offlineMode, subtitle: l.offlineModeDesc, bullets: l.offlineBenefits),
        const SizedBox(height: 24),
        AbssButton(label: l.cont, onTap: selected != null ? onNext : null),
      ],
    ),
  );
}

class _TypeCard extends StatelessWidget {
  final bool selected; final VoidCallback onTap; final IconData icon; final Color iconColor;
  final String title; final String subtitle; final String bullets;
  const _TypeCard({required this.selected, required this.onTap, required this.icon, required this.iconColor, required this.title, required this.subtitle, required this.bullets});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: selected ? iconColor.withValues(alpha: 0.06) : AppColors.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: selected ? iconColor.withValues(alpha: 0.55) : AppColors.border(context), width: selected ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 22, color: iconColor)),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: AppText.h3(context))),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22, height: 22,
              decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? AppColors.primary : Colors.transparent, border: Border.all(color: selected ? AppColors.primary : AppColors.border(context), width: 2)),
              child: selected ? const Icon(Icons.check_rounded, size: 13, color: Colors.white) : null,
            ),
          ]),
          const SizedBox(height: 10),
          Text(subtitle, style: AppText.body(context).copyWith(fontSize: 13, height: 1.5)),
          if (selected) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBg : AppColors.lightCardAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(bullets, style: AppText.caption(context).copyWith(height: 1.85, fontSize: 12, color: AppColors.textSecondary(context))),
            ),
          ],
        ],
      ),
    ),
  );
}

// ─── Step 4a: Online setup with phone verification simulation ─────────────────
class _OnlineSetupStep extends StatefulWidget {
  final L10n l; final String langCode; final String locId;
  final TextEditingController nameCtrl; final TextEditingController phoneCtrl;
  final Future<void> Function() onDone;
  const _OnlineSetupStep({required this.l, required this.langCode, required this.locId, required this.nameCtrl, required this.phoneCtrl, required this.onDone});

  @override State<_OnlineSetupStep> createState() => _OnlineSetupStepState();
}

class _OnlineSetupStepState extends State<_OnlineSetupStep> {
  bool _loading = false;
  _VerifStep _verifStep = _VerifStep.idle;
  String _simCode = '';
  final _codeCtrl = TextEditingController();
  String? _phoneError;
  bool _codeSentShown = false;

  @override void dispose() { _codeCtrl.dispose(); super.dispose(); }

  bool _isValidPhone() {
    final (dial, digits, firstDigits, country) = _rulesFor(widget.locId);
    final t = widget.phoneCtrl.text.trim();
    if (t.length != digits) return false;
    return firstDigits.any((d) => t.startsWith(d));
  }

  Future<void> _sendCode() async {
    if (!_isValidPhone()) {
      final (_, digits, firstDigits, country) = _rulesFor(widget.locId);
      setState(() => _phoneError = 'Enter a valid $country number ($digits digits, starting with ${firstDigits.join(' or ')})');
      return;
    }
    setState(() { _loading = true; _phoneError = null; });
    await Future.delayed(const Duration(milliseconds: 1200));
    _simCode = '4872'; // simulated code
    setState(() { _loading = false; _verifStep = _VerifStep.codeSent; _codeSentShown = true; });
  }

  void _verifyCode() {
    if (_codeCtrl.text.trim() == _simCode) {
      setState(() => _verifStep = _VerifStep.verified);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect code. Try: 4872'), backgroundColor: AppColors.critical));
    }
  }

  @override
  Widget build(BuildContext context) {
    final (dialCode, digitLen, firstDigits, country) = _rulesFor(widget.locId);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Step 4 of 4', style: AppText.caption(context)),
          const SizedBox(height: 6),
          Text(widget.l.almostThere, style: AppText.h2(context)),
          const SizedBox(height: 6),
          Text('Enter your name and verify your phone number to complete setup.', style: AppText.body(context)),
          const SizedBox(height: 20),
          // Name
          _InputCard(label: 'Your name', child: TextField(
            controller: widget.nameCtrl,
            style: AppText.bodyMedium(context).copyWith(fontSize: 16),
            decoration: InputDecoration(hintText: 'e.g. Amara', border: InputBorder.none, hintStyle: TextStyle(color: AppColors.textMuted(context)),
              prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.textMuted(context), size: 20)),
          )),
          const SizedBox(height: 14),
          // Phone
          _InputCard(
            label: 'Phone number',
            note: '$dialCode · $digitLen digits, starts with ${firstDigits.join(' or ')}',
            error: _phoneError,
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border(context))),
                child: Text(dialCode, style: AppText.bodyMedium(context)),
              ),
              const SizedBox(width: 10),
              Expanded(child: TextField(
                controller: widget.phoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(digitLen)],
                style: AppText.bodyMedium(context).copyWith(fontSize: 16),
                decoration: InputDecoration(hintText: 'Phone number', border: InputBorder.none, hintStyle: TextStyle(color: AppColors.textMuted(context))),
                onChanged: (_) => setState(() { _phoneError = null; }),
              )),
            ]),
          ),
          const SizedBox(height: 14),

          // Verification flow
          if (_verifStep == _VerifStep.idle) ...[
            AbssButton(label: _loading ? 'Sending...' : 'Send verification code', icon: Icons.sms_outlined, isLoading: _loading, outlined: true, onTap: !_loading ? _sendCode : null),
          ],

          if (_verifStep == _VerifStep.codeSent) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.info),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Simulation: a code would be sent to $dialCode${widget.phoneCtrl.text.trim()}. For this demo the code is 4872.', style: AppText.caption(context).copyWith(color: AppColors.info, fontSize: 12, height: 1.5))),
                  ]),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _codeCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                    style: AppText.h2(context).copyWith(letterSpacing: 8),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '- - - -',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border(context))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border(context))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.info)),
                      hintStyle: TextStyle(color: AppColors.textMuted(context), letterSpacing: 4),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  AbssButton(label: 'Verify code', icon: Icons.check_rounded, onTap: _codeCtrl.text.length == 4 ? _verifyCode : null),
                ],
              ),
            ),
          ],

          if (_verifStep == _VerifStep.verified) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.verified_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Number verified! You\'re all set.', style: AppText.bodyMedium(context).copyWith(color: AppColors.primary))),
              ]),
            ),
          ],

          const SizedBox(height: 24),
          AbssButton(
            label: widget.l.startUsing, icon: Icons.arrow_forward_rounded, isLoading: _loading,
            onTap: (_verifStep == _VerifStep.verified && !_loading) ? () async { setState(() => _loading = true); await widget.onDone(); if (mounted) setState(() => _loading = false); } : null,
          ),
        ],
      ),
    );
  }
}

// ─── Step 4b: Offline / SMS setup ────────────────────────────────────────────
class _OfflineSetupStep extends StatefulWidget {
  final L10n l; final String langCode; final String locId;
  final TextEditingController phoneCtrl; final Set<String> alertTypes;
  final void Function(String) onToggle; final Future<void> Function() onDone;
  const _OfflineSetupStep({required this.l, required this.langCode, required this.locId, required this.phoneCtrl, required this.alertTypes, required this.onToggle, required this.onDone});

  @override State<_OfflineSetupStep> createState() => _OfflineSetupStepState();
}

class _OfflineSetupStepState extends State<_OfflineSetupStep> {
  bool _loading = false;
  _VerifStep _verifStep = _VerifStep.idle;
  final _codeCtrl = TextEditingController();
  String? _phoneError;

  static const _hazards = [
    ('flood', 'Floods',      Icons.water_outlined,       AppColors.info),
    ('storm', 'Storms',      Icons.thunderstorm_outlined, AppColors.high),
    ('drought', 'Drought',   Icons.wb_sunny_outlined,     AppColors.moderate),
    ('earthquake', 'Earthquakes', Icons.vibration_outlined, AppColors.critical),
    ('heatwave', 'Extreme Heat',  Icons.thermostat_outlined, AppColors.high),
  ];

  bool _isValidPhone() {
    final (_, digits, firstDigits, _) = _rulesFor(widget.locId);
    final t = widget.phoneCtrl.text.trim();
    return t.length == digits && firstDigits.any((d) => t.startsWith(d));
  }

  Future<void> _sendCode() async {
    if (!_isValidPhone()) {
      final (_, digits, firstDigits, country) = _rulesFor(widget.locId);
      setState(() => _phoneError = 'Valid $country number: $digits digits, starting with ${firstDigits.join(' or ')}');
      return;
    }
    setState(() { _loading = true; _phoneError = null; });
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() { _loading = false; _verifStep = _VerifStep.codeSent; });
  }

  void _verifyCode() {
    if (_codeCtrl.text.trim() == '4872') {
      setState(() => _verifStep = _VerifStep.verified);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrong code. Demo code: 4872'), backgroundColor: AppColors.critical));
    }
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    await widget.onDone();
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() { _codeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final (dialCode, digitLen, firstDigits, country) = _rulesFor(widget.locId);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Step 4 of 4', style: AppText.caption(context)),
          const SizedBox(height: 6),
          Text(widget.l.registerSms, style: AppText.h2(context)),
          const SizedBox(height: 6),
          Text('Verify your number and choose which alerts to receive via SMS.', style: AppText.body(context)),
          const SizedBox(height: 20),

          // Phone
          _InputCard(
            label: 'Phone number',
            note: '$dialCode · $digitLen digits, starts with ${firstDigits.join(' or ')}',
            error: _phoneError,
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border(context))),
                child: Text(dialCode, style: AppText.bodyMedium(context)),
              ),
              const SizedBox(width: 10),
              Expanded(child: TextField(
                controller: widget.phoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(digitLen)],
                style: AppText.bodyMedium(context).copyWith(fontSize: 16),
                decoration: InputDecoration(hintText: 'Phone number', border: InputBorder.none, hintStyle: TextStyle(color: AppColors.textMuted(context))),
                onChanged: (_) => setState(() { _phoneError = null; }),
              )),
            ]),
          ),
          const SizedBox(height: 12),

          // Verification
          if (_verifStep == _VerifStep.idle)
            AbssButton(label: _loading ? 'Sending...' : 'Send verification code', icon: Icons.sms_outlined, isLoading: _loading, outlined: true, onTap: !_loading ? _sendCode : null),

          if (_verifStep == _VerifStep.codeSent) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.info.withValues(alpha: 0.25))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Demo: code would be sent to $dialCode${widget.phoneCtrl.text}. Use 4872.', style: AppText.caption(context).copyWith(color: AppColors.info, fontSize: 12)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _codeCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                    style: AppText.h2(context).copyWith(letterSpacing: 8),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '- - - -',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border(context))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border(context))),
                      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.info)),
                      hintStyle: TextStyle(color: AppColors.textMuted(context), letterSpacing: 4),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  AbssButton(label: 'Verify code', icon: Icons.check_rounded, onTap: _codeCtrl.text.length == 4 ? _verifyCode : null),
                ],
              ),
            ),
          ],

          if (_verifStep == _VerifStep.verified) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withValues(alpha: 0.3))),
              child: Row(children: [
                const Icon(Icons.verified_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Number verified!', style: AppText.bodyMedium(context).copyWith(color: AppColors.primary)),
              ]),
            ),
            const SizedBox(height: 20),
            Text('Alert types', style: AppText.h4(context)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _hazards.map((h) {
                final sel = widget.alertTypes.contains(h.$1);
                return GestureDetector(
                  onTap: () => widget.onToggle(h.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: sel ? h.$4.withValues(alpha: 0.1) : AppColors.card(context),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: sel ? h.$4.withValues(alpha: 0.5) : AppColors.border(context), width: sel ? 1.5 : 1),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(h.$3, size: 15, color: sel ? h.$4 : AppColors.textMuted(context)),
                      const SizedBox(width: 6),
                      Text(h.$2, style: AppText.bodyMedium(context).copyWith(fontSize: 13, color: sel ? h.$4 : AppColors.textPrimary(context))),
                    ]),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            AbssButton(label: 'Complete registration', icon: Icons.arrow_forward_rounded, isLoading: _loading, onTap: (widget.alertTypes.isNotEmpty && !_loading) ? _submit : null),
          ],
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
class _InputCard extends StatelessWidget {
  final String label;
  final String? note;
  final String? error;
  final Widget child;
  const _InputCard({required this.label, this.note, this.error, required this.child});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        decoration: AppDecorations.card(context, borderColor: error != null ? AppColors.critical.withValues(alpha: 0.5) : null),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppText.caption(context).copyWith(fontSize: 11, color: AppColors.textSecondary(context))),
            const SizedBox(height: 6),
            child,
          ],
        ),
      ),
      if (note != null && error == null) Padding(padding: const EdgeInsets.only(top: 4, left: 4), child: Text(note!, style: AppText.caption(context).copyWith(fontSize: 11))),
      if (error != null) Padding(padding: const EdgeInsets.only(top: 4, left: 4), child: Text(error!, style: AppText.caption(context).copyWith(fontSize: 11, color: AppColors.critical))),
    ],
  );
}

class _Tile extends StatelessWidget {
  final bool selected; final VoidCallback onTap; final Widget child; final bool compact;
  const _Tile({required this.selected, required this.onTap, required this.child, this.compact = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary.withValues(alpha: 0.07) : AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? AppColors.primary : AppColors.border(context), width: selected ? 1.5 : 1),
      ),
      child: child,
    ),
  );
}
