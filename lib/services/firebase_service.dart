import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// ─── Firestore Service ────────────────────────────────────────────────────────
class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // Call once at app start — enables Firestore offline caching
  static Future<void> initOfflinePersistence() async {
    _db.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // FCM init
  static Future<String?> initFCM() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await messaging.getToken();
    await messaging.subscribeToTopic('all_alerts');

    return token;
  }

  // Users
  static Future<void> createOrUpdateUser(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _db.collection('users').doc(uid).set(
      {
        ...data,
        'last_active_at': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  static Future<void> updateUserSettings(
    String uid,
    Map<String, dynamic> settings,
  ) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('prefs')
        .set(settings, SetOptions(merge: true));
  }

  static Future<void> updateFcmToken(
    String uid,
    String token,
    String platform,
  ) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('devices')
        .doc(token)
        .set({
      'fcm_token': token,
      'platform': platform,
      'last_seen': FieldValue.serverTimestamp(),
    });
  }

  static Future<Map<String, dynamic>?> getUserProfile(
    String uid,
  ) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.exists ? doc.data() : null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> markUserVerified(String uid) async {
    await _db.collection('users').doc(uid).update({
      'is_verified': true,
      'verified_at': FieldValue.serverTimestamp(),
    });
  }

  // Locations
  static Future<DocumentSnapshot?> getLocation(
    String locationId,
  ) async {
    try {
      return await _db.collection('locations').doc(locationId).get();
    } catch (_) {
      return null;
    }
  }

  // Forecasts
  static Stream<QuerySnapshot> forecastsStream(
    String locationId,
  ) {
    return _db
        .collection('forecasts')
        .where('location_id', isEqualTo: locationId)
        .orderBy('valid_from', descending: true)
        .limit(7)
        .snapshots();
  }

  static Future<void> saveForecast(ForecastModel forecast) async {
    await _db.collection('forecasts').add({
      'location_id': forecast.locationId,
      'valid_from': Timestamp.fromDate(forecast.generatedAt),
      'valid_to':
          Timestamp.fromDate(forecast.generatedAt.add(const Duration(days: 7))),
      'temperature_min':
          forecast.daily.isNotEmpty ? forecast.daily.first.tempMin : 0,
      'temperature_max':
          forecast.daily.isNotEmpty ? forecast.daily.first.tempMax : 0,
      'rainfall_mm':
          forecast.daily.isNotEmpty ? forecast.daily.first.rainfallMm : 0,
      'wind_speed': forecast.windKph,
      'humidity': forecast.humidity,
      'forecast_source': 'Open-Meteo',
      'generated_at': FieldValue.serverTimestamp(),
    });
  }

  // Alerts
  // In production, replace the demo list in models.dart with this stream.
  // Swap alertsProvider in app_providers.dart to use alertsStream().
  static Stream<QuerySnapshot> alertsStream(String locationId) {
    return _db
        .collection('alerts')
        .where('location_id', isEqualTo: locationId)
        .orderBy('start_time', descending: true)
        .limit(20)
        .snapshots();
  }

  static Future<void> acknowledgeAlert(
    String uid,
    String alertId,
  ) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('acknowledged_alerts')
        .doc(alertId)
        .set({'acknowledged_at': FieldValue.serverTimestamp()});
  }

  // Content Localization
  static Future<Map<String, String>> getLocalizedContent(
    String key,
    String language,
  ) async {
    try {
      final snap = await _db
          .collection('content_localization')
          .where('key', isEqualTo: key)
          .where('language', isEqualTo: language)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return {};
      return Map<String, String>.from(snap.docs.first.data());
    } catch (_) {
      return {};
    }
  }

  // SMS Registrations
  // Writes to Firestore; Cloud Function onSmsRegistrationCreate handles the SMS.
  // For the demo, the SMS is simulated in the app UI — no actual message is sent.
  static Future<void> registerForSmsAlerts({
    required String phone,
    required List<String> hazardTypes,
    required String language,
    required String locationId,
    bool isVerified = false,
  }) async {
    await _db.collection('sms_registrations').add({
      'phone': phone,
      'hazard_types': hazardTypes,
      'language': language,
      'location_id': locationId,
      'registration_type': 'offline',
      'is_verified': isVerified,
      'verified_at':
          isVerified ? FieldValue.serverTimestamp() : null,
      'created_at': FieldValue.serverTimestamp(),
      'is_active': true,
    });
  }

  static Future<void> registerUser({
    required String uid,
    required String name,
    required String phone,
    required String preferredLanguage,
    required String locationId,
    required String registrationType,
    required List<String> alertTypesEnabled,
    required bool isVerified,
  }) async {
    await _db.collection('users').doc(uid).set(
      {
        'name': name,
        'phone': phone,
        'preferred_language': preferredLanguage,
        'home_location_id': locationId,
        'registration_type': registrationType,
        'is_verified': isVerified,
        'verified_at':
            isVerified ? FieldValue.serverTimestamp() : null,
        'notification_on': true,
        'alert_types_enabled': alertTypesEnabled,
        'created_at': FieldValue.serverTimestamp(),
        'last_active_at': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // Sync Metadata
  static Future<void> updateSyncMetadata(String userId) async {
    await _db.collection('sync_metadata').doc(userId).set(
      {
        'user_id': userId,
        'last_forecast_sync_at': FieldValue.serverTimestamp(),
        'last_alert_sync_at': FieldValue.serverTimestamp(),
        'app_version': '1.0.0',
      },
      SetOptions(merge: true),
    );
  }
}

// Phone Verification Service
// useSimulation = true  → simulates verification locally (no SMS sent).
// Set useSimulation = false when you wire up real SMS (MTN / Africa's Talking).
class PhoneVerificationService {
  static const bool useSimulation = true;
  // Simulated OTP — in the UI we show the user this code as "demo mode"
  static const String _simCode = '4872';

  static Future<PhoneVerificationResult> sendCode({
    required String phone,
    required String langCode,
    required String registrationType,
  }) async {
    if (useSimulation) {
      await Future.delayed(const Duration(milliseconds: 1400));
      return PhoneVerificationResult.codeSent(_simCode);
    }
    // Production wiring (MTN SMS API v3 or Africa's Talking)
    try {
      return PhoneVerificationResult.codeSent('______'); // replace with real code flow
    } catch (e) {
      return PhoneVerificationResult.failure(e.toString());
    }
  }

  static PhoneVerificationResult verifyCode(
    String entered,
    String expected,
  ) {
    if (entered.trim() == expected.trim()) {
      return const PhoneVerificationResult.verified();
    }
    return const PhoneVerificationResult.failure(
      'Incorrect code. Please try again.',
    );
  }

  static String buildWelcomeMessage(String langCode) {
    const msgs = {
      'en':
          'Welcome to ABSS! Your number is verified. You will receive critical hazard alerts for your area.',
      'sw':
          'Karibu ABSS! Nambari yako imethibitishwa. Utapokea arifa za hatari muhimu kwa eneo lako.',
      'rw':
          'Murakaza neza ABSS! Numero yawe yemejwe. Uzahabwa inzitizi z\'ibyago mu karere kawe.',
      'am':
          'ABSS እንኳን ደህና መጡ! ቁጥርዎ ተረጋግጧል። ለአካባቢዎ ወሳኝ ማስጠንቀቂያዎች ይደርሳሉ።',
      'fr':
          'Bienvenue sur ABSS ! Votre numéro est vérifié. Vous recevrez des alertes de danger critique.',
    };
    return msgs[langCode] ?? msgs['en']!;
  }
}

class PhoneVerificationResult {
  final bool success;
  final bool codeSentFlag;
  final String? code; // simulated or null
  final String? error;

  const PhoneVerificationResult.codeSent(this.code)
      : success = true,
        codeSentFlag = true,
        error = null;

  const PhoneVerificationResult.verified()
      : success = true,
        codeSentFlag = false,
        code = null,
        error = null;

  const PhoneVerificationResult.failure(this.error)
      : success = false,
        codeSentFlag = false,
        code = null;
}