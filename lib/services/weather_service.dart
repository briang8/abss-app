// lib/services/weather_service.dart
// Uses Open-Meteo (https://open-meteo.com) — completely free, no API key needed.
// Covers all of Africa at 1–11 km resolution, updated hourly.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class WeatherService {
  /// Fetches a 7-day forecast from Open-Meteo.
  /// Open-Meteo provides hourly + daily data, WMO weather codes, no auth needed.
  static Future<ForecastModel> fetchForecast({
    required double lat,
    required double lng,
    required String locationId,
    required String locationName,
  }) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lng'
      '&hourly=temperature_2m,precipitation_probability,windspeed_10m,weathercode'
      '&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum,weathercode'
      '&current_weather=true'
      '&wind_speed_unit=kmh'
      '&timezone=Africa%2FNairobi'
      '&forecast_days=7',
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200)
      throw Exception('Weather API error: ${response.statusCode}');

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return _parse(data, locationId, locationName);
  }

  static ForecastModel _parse(
    Map<String, dynamic> data,
    String locationId,
    String locationName,
  ) {
    final hourly = data['hourly'] as Map<String, dynamic>;
    final daily = data['daily'] as Map<String, dynamic>;

    // Parse hourly (next 24 hours)
    final hourlyTimes = (hourly['time'] as List).cast<String>();
    final hourlyTemps = (hourly['temperature_2m'] as List)
        .map((e) => (e as num).toDouble())
        .toList();
    final hourlyRain = (hourly['precipitation_probability'] as List)
        .map((e) => (e as num).toDouble())
        .toList();
    final hourlyWind = (hourly['windspeed_10m'] as List)
        .map((e) => (e as num).toDouble())
        .toList();
    final hourlyCodes = (hourly['weathercode'] as List).cast<int>();

    final now = DateTime.now();
    // Find the closest current hour index
    int startIdx = 0;
    for (int i = 0; i < hourlyTimes.length; i++) {
      final t = DateTime.parse(hourlyTimes[i]);
      if (t.isAfter(now) || t.isAtSameMomentAs(now)) {
        startIdx = i;
        break;
      }
    }

    final hourlyForecasts = List.generate(
      24.clamp(0, hourlyTimes.length - startIdx),
      (i) {
        final idx = startIdx + i;
        return HourlyForecast(
          time: DateTime.parse(hourlyTimes[idx]),
          temperatureC: hourlyTemps[idx],
          rainProbability: hourlyRain[idx],
          windSpeedKph: hourlyWind[idx],
          condition: _wmoToCondition(hourlyCodes[idx]),
        );
      },
    );

    // Parse daily (5 days)
    final dailyDates = (daily['time'] as List).cast<String>();
    final dailyMax = (daily['temperature_2m_max'] as List)
        .map((e) => (e as num).toDouble())
        .toList();
    final dailyMin = (daily['temperature_2m_min'] as List)
        .map((e) => (e as num).toDouble())
        .toList();
    final dailyRain = (daily['precipitation_probability_max'] as List)
        .map((e) => (e as num).toDouble())
        .toList();
    final dailyMm = (daily['precipitation_sum'] as List)
        .map((e) => (e as num).toDouble())
        .toList();

    final dailyForecasts = List.generate(
      dailyDates.length.clamp(0, 7),
      (i) => DailyForecast(
        date: DateTime.parse(dailyDates[i]),
        tempMaxC: dailyMax[i],
        tempMinC: dailyMin[i],
        rainProbability: dailyRain[i],
        rainfallMm: dailyMm[i],
      ),
    );

    return ForecastModel(
      hourly: hourlyForecasts,
      daily: dailyForecasts,
      isFromCache: false,
    );
  }

  /// Map WMO weather interpretation codes to app condition strings.
  /// Full table: https://open-meteo.com/en/docs#weathervariables
  static String _wmoToCondition(int code) {
    if (code == 0) return 'sunny';
    if (code <= 3) return 'cloudy';
    if (code <= 49) return 'cloudy'; // fog / depositing rime fog
    if (code <= 67) return 'rainy'; // drizzle and rain
    if (code <= 77)
      return 'rainy'; // snow (Africa — rare but possible at altitude)
    if (code <= 82) return 'rainy'; // rain showers
    if (code <= 86) return 'rainy'; // snow showers
    return 'stormy'; // 95–99 thunderstorm
  }

  /// Human-readable label for a WMO code
  static String wmoLabel(int code) {
    if (code == 0) return 'Clear sky';
    if (code <= 3) return 'Partly cloudy';
    if (code <= 9) return 'Cloudy';
    if (code <= 19) return 'Foggy';
    if (code <= 29) return 'Drizzle';
    if (code <= 39) return 'Dust / Sand';
    if (code <= 49) return 'Fog';
    if (code <= 59) return 'Drizzle';
    if (code <= 69) return 'Rain';
    if (code <= 79) return 'Snow';
    if (code <= 84) return 'Rain Showers';
    if (code <= 94) return 'Hail Showers';
    return 'Thunderstorm';
  }
}
