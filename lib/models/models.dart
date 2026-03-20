import 'package:cloud_firestore/cloud_firestore.dart';


enum AlertType {
  flood,
  storm,
  drought,
  earthquake,
  heatwave,
}

enum AlertSeverity {
  critical,
  high,
  moderate,
  low,
}


class AlertModel {
  final String id;
  final String title;
  final AlertType type;
  final AlertSeverity severity;
  final String locationId;
  final String locationName;
  final DateTime startTime;
  final DateTime endTime;
  final String messagePlain;
  final String source;
  final bool isOfflineCritical;
  final DateTime createdAt;

  const AlertModel({
    required this.id,
    required this.title,
    required this.type,
    required this.severity,
    required this.locationId,
    required this.locationName,
    required this.startTime,
    required this.endTime,
    required this.messagePlain,
    required this.source,
    required this.isOfflineCritical,
    required this.createdAt,
  });

  factory AlertModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};

    AlertType _typeFromString(String? value) {
      switch (value) {
        case 'flood':
          return AlertType.flood;
        case 'storm':
          return AlertType.storm;
        case 'drought':
          return AlertType.drought;
        case 'earthquake':
          return AlertType.earthquake;
        case 'heatwave':
          return AlertType.heatwave;
        default:
          return AlertType.storm;
      }
    }

    AlertSeverity _severityFromString(String? value) {
      switch (value) {
        case 'critical':
          return AlertSeverity.critical;
        case 'high':
          return AlertSeverity.high;
        case 'moderate':
          return AlertSeverity.moderate;
        case 'low':
          return AlertSeverity.low;
        default:
          return AlertSeverity.moderate;
      }
    }

    DateTime _toDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return AlertModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      type: _typeFromString(data['type'] as String?),
      severity: _severityFromString(data['severity'] as String?),
      locationId: data['location_id'] as String? ?? '',
      locationName: data['location_name'] as String? ?? '',
      startTime: _toDateTime(data['start_time']),
      endTime: _toDateTime(data['end_time']),
      messagePlain: data['message_plain'] as String? ?? '',
      source: data['source'] as String? ?? '',
      isOfflineCritical: data['is_offline_critical'] as bool? ?? false,
      createdAt: _toDateTime(data['created_at']),
    );
  }

  /// Demo alerts used as a fallback when Firestore is empty/offline.
  /// The actual AlertModel(...) blocks should stay commented out by default.
  static List<AlertModel> demoAlerts() {
    return [
    

    ];
  }
}

/// ----------------------
/// Forecast models
/// ----------------------

class HourlyForecast {
  final DateTime time;
  final double temperatureC;
  final double rainProbability;
  final double windSpeedKph;
  final String condition; // "sunny" / "cloudy" / "rainy" / "stormy"

  const HourlyForecast({
    required this.time,
    required this.temperatureC,
    required this.rainProbability,
    required this.windSpeedKph,
    required this.condition,
  });
}

class DailyForecast {
  final DateTime date;
  final double tempMinC;
  final double tempMaxC;
  final double rainfallMm;
  final double rainProbability;

  const DailyForecast({
    required this.date,
    required this.tempMinC,
    required this.tempMaxC,
    required this.rainfallMm,
    required this.rainProbability,
  });
}

class ForecastModel {
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final bool isFromCache;

  const ForecastModel({
    required this.hourly,
    required this.daily,
    required this.isFromCache,
  });


  static ForecastModel demo() {
    final now = DateTime.now();

    final hourly = List<HourlyForecast>.generate(6, (i) {
      final t = now.add(Duration(hours: i));
      return HourlyForecast(
        time: t,
        temperatureC: 22 + i.toDouble(),
        rainProbability: i == 0 ? 20 : 40,
        windSpeedKph: 8 + i.toDouble(),
        condition: i < 2 ? 'sunny' : 'cloudy',
      );
    });

    final daily = List<DailyForecast>.generate(5, (i) {
      final d = DateTime(now.year, now.month, now.day + i);
      return DailyForecast(
        date: d,
        tempMinC: 18 + i.toDouble(),
        tempMaxC: 26 + i.toDouble(),
        rainfallMm: i == 0 ? 0 : 4 + i.toDouble(),
        rainProbability: i == 0 ? 10 : 50,
      );
    });

    return ForecastModel(
      hourly: hourly,
      daily: daily,
      isFromCache: true,
    );
  }
}


class UserProfile {
  final String id;
  final String name;
  final String phone;
  final String preferredLanguage; 
  final String homeLocationId; 
  final String registrationType; 
  final List<String> alertTypesEnabled; 
  final bool isVerified;
  final DateTime? verifiedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.preferredLanguage,
    required this.homeLocationId,
    required this.registrationType,
    required this.alertTypesEnabled,
    required this.isVerified,
    this.verifiedAt,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? phone,
    String? preferredLanguage,
    String? homeLocationId,
    String? registrationType,
    List<String>? alertTypesEnabled,
    bool? isVerified,
    DateTime? verifiedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      homeLocationId: homeLocationId ?? this.homeLocationId,
      registrationType: registrationType ?? this.registrationType,
      alertTypesEnabled: alertTypesEnabled ?? this.alertTypesEnabled,
      isVerified: isVerified ?? this.isVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'preferred_language': preferredLanguage,
      'home_location_id': homeLocationId,
      'registration_type': registrationType,
      'alert_types_enabled': alertTypesEnabled,
      'is_verified': isVerified,
      'verified_at': verifiedAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
      homeLocationId: json['home_location_id'] as String? ?? 'kigali_rw',
      registrationType: json['registration_type'] as String? ?? 'online',
      alertTypesEnabled: (json['alert_types_enabled'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[],
      isVerified: json['is_verified'] as bool? ?? false,
      verifiedAt: (json['verified_at'] as String?) != null
          ? DateTime.tryParse(json['verified_at'] as String)!
          : null,
    );
  }
}