import 'package:abss_app/services/firebase_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../utils/app_localizations.dart';
import 'onboarding_screen.dart';


class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  String? _errorText;
  bool _showRegisterLink = false;
  String _locId = 'kigali_rw'; // Default location

  L10n get _l => L10n.of('en'); // Default to English for login

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool _isValidPhone() {
    final (_, digits, firstDigits, _) = rulesFor(_locId);
    final t = _phoneCtrl.text.trim();
    return t.length == digits && firstDigits.any((d) => t.startsWith(d));
  }

  Future<void> _login() async {
    if (!_isValidPhone()) {
      final (_, digits, firstDigits, country) = rulesFor(_locId);
      setState(
        () => _errorText =
            'Valid $country number: $digits digits, starting with ${firstDigits.join(' or ')}',
      );
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
      _showRegisterLink = false;
    });

    final (dial, _, __, ___) = rulesFor(_locId);
    final fullPhone = '$dial${_phoneCtrl.text.trim()}';

    try {
      final phoneExists = await FirestoreService.checkPhoneExists(fullPhone);
      if (!phoneExists) {
        setState(() {
          _loading = false;
          _errorText = 'No account found with this number.';
          _showRegisterLink = true;
        });
        return;
      }

      final profile = await FirestoreService.getUserByPhone(fullPhone);

      if (profile != null) {
        ref.read(userProfileProvider.notifier).setProfile(profile);
        ref.read(localeProvider.notifier).setLocale(profile.preferredLanguage);
        ref.read(onboardingProvider.notifier).complete();
        // This ensures we navigate to the main app and remove the login stack
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainShell()),
            (route) => false,
          );
        }
      } else {
        // This case should ideally not be hit if checkPhoneExists is accurate,
        // but it's good practice to handle it.
        setState(() {
          _loading = false;
          _errorText = 'Failed to retrieve user profile.';
          _showRegisterLink = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorText = 'An error occurred during login. Please try again.';
        });
      }
    } finally {
      if (mounted && _loading) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final (dialCode, digitLen, _, __) = rulesFor(_locId);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: AppColors.background(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome Back!', style: AppText.h2(context)),
            const SizedBox(height: 6),
            Text(
              'Enter your phone number to log in.',
              style: AppText.body(context),
            ),
            const SizedBox(height: 20),
            _InputCard(
              label: 'Phone number',
              error: _errorText,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border(context)),
                    ),
                    child: Text(dialCode, style: AppText.bodyMedium(context)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(digitLen),
                      ],
                      style: AppText.bodyMedium(context).copyWith(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Phone number',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: AppColors.textMuted(context),
                        ),
                      ),
                      onChanged: (_) => setState(() {
                        _errorText = null;
                        _showRegisterLink = false;
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (_showRegisterLink)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 12),
                child: RichText(
                  text: TextSpan(
                    style: AppText.caption(
                      context,
                    ).copyWith(color: AppColors.critical, fontSize: 12),
                    children: [
                      const TextSpan(text: 'No account found. '),
                      TextSpan(
                        text: 'Register here.',
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const OnboardingScreen(),
                              ),
                              (route) => false,
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: !_loading ? _login : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// You might need to move these or make them accessible if they are not already
const _phoneRules = <String, (String, int, List<String>, String)>{
  'kigali_rw': ('+250', 9, ['7'], 'Rwanda'),
  'nairobi_ke': ('+254', 9, ['7', '1'], 'Kenya'),
  'addis_et': ('+251', 9, ['9', '7'], 'Ethiopia'),
  'kampala_ug': ('+256', 9, ['7', '8'], 'Uganda'),
  'dar_tz': ('+255', 9, ['7', '6'], 'Tanzania'),
  'bujumbura_bi': ('+257', 8, ['7', '6', '2'], 'Burundi'),
  'auto': ('+250', 9, ['7'], ''),
};

(String, int, List<String>, String) rulesFor(String locId) =>
    _phoneRules[locId] ?? ('+250', 9, ['7'], '');

class _InputCard extends StatelessWidget {
  final String label;
  final Widget child;
  final String? note;
  final String? error;

  const _InputCard({
    required this.label,
    required this.child,
    this.note,
    this.error,
  });
  
  get _showRegisterLink => null;
  


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.caption(context)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: error != null
                  ? AppColors.critical
                  : AppColors.border(context),
              width: 1,
            ),
          ),
          child: child,
        ),
        if (note != null) ...[
          const SizedBox(height: 4),
          Text(note!, style: AppText.caption(context).copyWith(fontSize: 11)),
        ],
        if (error != null && !_showRegisterLink!) ...[
          const SizedBox(height: 4),
          Text(
            error!,
            style: AppText.caption(
              context,
            ).copyWith(color: AppColors.critical, fontSize: 11),
          ),
        ],
      ],
    );
  }
}
