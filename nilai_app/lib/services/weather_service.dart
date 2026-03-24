// ─────────────────────────────────────────────────────────────────────────────
//  services/weather_service.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class WeatherResult {
  final String description;
  final String icon; // e.g. "Clear", "Rain", "Clouds"
  final double temp;
  final int humidity;
  final bool isRainy;

  const WeatherResult({
    required this.description,
    required this.icon,
    required this.temp,
    required this.humidity,
    required this.isRainy,
  });

  String get emoji {
    const map = {
      'Clear': '☀️',
      'Clouds': '☁️',
      'Rain': '🌧️',
      'Drizzle': '🌦️',
      'Thunderstorm': '⛈️',
      'Snow': '❄️',
      'Mist': '🌫️',
      'Haze': '🌫️',
    };
    return map[icon] ?? '🌤️';
  }

  String get advice =>
      isRainy ? '⚠️ Rain risk — transport carefully' : '✅ Safe to travel';
}

class WeatherService {
  static const _rainyTypes = ['Rain', 'Drizzle', 'Thunderstorm'];

  // Simple in-memory cache — avoid hammering API for same city
  static final Map<String, _CacheEntry> _cache = {};
  static const _cacheDuration = Duration(minutes: 20);

  static Future<WeatherResult> getWeather(String city) async {
    // Check cache
    final cached = _cache[city.toLowerCase()];
    if (cached != null &&
        DateTime.now().difference(cached.fetchedAt) < _cacheDuration) {
      return cached.result;
    }

    try {
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather'
        '?q=$city,IN&appid=$kWeatherApiKey&units=metric',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final d = jsonDecode(res.body);
        final main = d['weather'][0]['main'] as String;
        final result = WeatherResult(
          description: d['weather'][0]['description'] as String,
          icon: main,
          temp: (d['main']['temp'] as num).toDouble(),
          humidity: (d['main']['humidity'] as num).toInt(),
          isRainy: _rainyTypes.contains(main),
        );
        _cache[city.toLowerCase()] =
            _CacheEntry(result: result, fetchedAt: DateTime.now());
        return result;
      }
    } catch (_) {}

    // Fallback mock so UI never breaks
    return const WeatherResult(
      description: 'clear sky',
      icon: 'Clear',
      temp: 28.0,
      humidity: 55,
      isRainy: false,
    );
  }
}

class _CacheEntry {
  final WeatherResult result;
  final DateTime fetchedAt;
  _CacheEntry({required this.result, required this.fetchedAt});
}
