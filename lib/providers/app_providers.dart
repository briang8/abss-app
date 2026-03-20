import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/weather_service.dart';


final connectivityProvider =
    StreamProvider<ConnectivityResult>((ref) {
  final connectivity = Connectivity();
  return connectivity.onConnectivityChanged;
});

final isOnlineProvider = Provider<bool>((ref) {
  final asyncResult = ref.watch(connectivityProvider);
  return asyncResult.maybeWhen(
    data: (result) => result != ConnectivityResult.none,
    orElse: () => true,
  );
});



class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Default: light mode
    return ThemeMode.light;
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    // Later: persist to SharedPreferences
  }
}

final themeProvider =
    NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);



class LocaleNotifier extends Notifier<String> {
  @override
  String build() {
    // Default: English
    return 'en';
  }

  void setLocale(String code) {
    state = code;
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, String>(
  LocaleNotifier.new,
);


class OnboardingState {
  final bool completed;

  const OnboardingState({required this.completed});

  OnboardingState copyWith({bool? completed}) {
    return OnboardingState(
      completed: completed ?? this.completed,
    );
  }
}

class OnboardingNotifier
    extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    // Later: read from SharedPreferences
    return const OnboardingState(completed: false);
  }

  void complete() {
    state = state.copyWith(completed: true);
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);


class UserProfileNotifier
    extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    // Initial empty / guest profile;
    // later this can be restored from local storage.
    return const UserProfile(
      id: '',
      name: '',
      phone: '',
      preferredLanguage: 'en',
      homeLocationId: 'kigali_rw',
      registrationType: 'online',
      alertTypesEnabled: <String>[],
      isVerified: false,
      verifiedAt: null,
    );
  }

  void setProfile(UserProfile profile) {
    state = profile;
  }

  void updateProfile(UserProfile profile) {
    state = profile;
  }
}

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfile>(
  UserProfileNotifier.new,
);



class LocationModel {
  final String locationId;
  final String locationName;
  final double? lat;
  final double? lng;

  const LocationModel({
    required this.locationId,
    required this.locationName,
    this.lat,
    this.lng,
  });

  LocationModel copyWith({
    String? locationId,
    String? locationName,
    double? lat,
    double? lng,
  }) {
    return LocationModel(
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}

class LocationNotifier
    extends Notifier<LocationModel> {
  @override
  LocationModel build() {
    // Default: Kigali
    return const LocationModel(
      locationId: 'kigali_rw',
      locationName: 'Kigali, Rwanda',
      lat: -1.9441,
      lng: 30.0619,
    );
  }

  void setLocation(LocationModel loc) {
    state = loc;
  }
}

final locationProvider =
    NotifierProvider<LocationNotifier, LocationModel>(
  LocationNotifier.new,
);


final forecastProvider =
    FutureProvider.autoDispose<ForecastModel>(
  (ref) async {
    final loc = ref.watch(locationProvider);
    final lat = loc.lat ?? -1.9441;
    final lng = loc.lng ?? 30.0619;

    try {
      return await WeatherService.fetchForecast(
        lat: lat,
        lng: lng,
        locationId: loc.locationId,
        locationName: loc.locationName,
      );
    } catch (_) {
      return ForecastModel.demo();
    }
  },
);


final alertsProvider =
    FutureProvider.autoDispose<List<AlertModel>>(
  (ref) async {
    final loc = ref.watch(locationProvider);
    final isOnline = ref.watch(isOnlineProvider);

    if (isOnline) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('alerts')
            .where('location_id',
                isEqualTo: loc.locationId)
            .orderBy('start_time', descending: true)
            .limit(20)
            .get();

        if (snap.docs.isNotEmpty) {
          return snap.docs
              .map((doc) => AlertModel.fromFirestore(doc))
              .toList();
        }
      } catch (_) {
        // fall through to demo
      }
    }

    await Future<void>.delayed(
      const Duration(milliseconds: 400),
    );
    return AlertModel.demoAlerts();
  },
);

final activeAlertsProvider =
    Provider<List<AlertModel>>((ref) {
  final alertsAsync = ref.watch(alertsProvider);

  return alertsAsync.maybeWhen(
    data: (alerts) => alerts
        .where((a) =>
            a.severity == AlertSeverity.critical ||
            a.severity == AlertSeverity.high)
        .toList(),
    orElse: () => <AlertModel>[],
  );
});


class SyncState {
  final DateTime? lastSyncedAt;

  const SyncState({required this.lastSyncedAt});

  SyncState copyWith({DateTime? lastSyncedAt}) {
    return SyncState(
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}

class SyncNotifier extends Notifier<SyncState> {
  @override
  SyncState build() {
    return const SyncState(lastSyncedAt: null);
  }

  void markSynced() {
    state = state.copyWith(
      lastSyncedAt: DateTime.now(),
    );
  }
}

final syncProvider =
    NotifierProvider<SyncNotifier, SyncState>(
  SyncNotifier.new,
);


final bottomNavIndexProvider =
    StateProvider<int>((ref) => 0);



class UserRegistrationTypeNotifier
    extends Notifier<String> {
  @override
  String build() {
    // 'online' or 'offline'
    return 'online';
  }

  void setType(String type) {
    state = type;
  }
}

final userRegistrationTypeProvider =
    NotifierProvider<UserRegistrationTypeNotifier, String>(
  UserRegistrationTypeNotifier.new,
);


class DailyCheckInState {
  final DateTime? lastCheckIn;

  const DailyCheckInState({required this.lastCheckIn});

  DailyCheckInState copyWith({DateTime? lastCheckIn}) {
    return DailyCheckInState(
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
    );
  }
}

class DailyCheckInNotifier
    extends Notifier<DailyCheckInState> {
  @override
  DailyCheckInState build() {
    return const DailyCheckInState(lastCheckIn: null);
  }

  void markCheckedIn() {
    state = state.copyWith(
      lastCheckIn: DateTime.now(),
    );
  }
}

final dailyCheckInProvider =
    NotifierProvider<DailyCheckInNotifier, DailyCheckInState>(
  DailyCheckInNotifier.new,
);



class SmsRegistrationState {
  final bool codeSent;
  final bool verified;
  final String? lastPhone;

  const SmsRegistrationState({
    required this.codeSent,
    required this.verified,
    required this.lastPhone,
  });

  SmsRegistrationState copyWith({
    bool? codeSent,
    bool? verified,
    String? lastPhone,
  }) {
    return SmsRegistrationState(
      codeSent: codeSent ?? this.codeSent,
      verified: verified ?? this.verified,
      lastPhone: lastPhone ?? this.lastPhone,
    );
  }
}

class SmsRegistrationNotifier
    extends Notifier<SmsRegistrationState> {
  @override
  SmsRegistrationState build() {
    return const SmsRegistrationState(
      codeSent: false,
      verified: false,
      lastPhone: null,
    );
  }

  void markCodeSent(String phone) {
    state = state.copyWith(
      codeSent: true,
      lastPhone: phone,
    );
  }

  void markVerified() {
    state = state.copyWith(
      verified: true,
    );
  }

  void reset() {
    state = const SmsRegistrationState(
      codeSent: false,
      verified: false,
      lastPhone: null,
    );
  }
}

final smsRegistrationProvider =
    NotifierProvider<SmsRegistrationNotifier, SmsRegistrationState>(
  SmsRegistrationNotifier.new,
);