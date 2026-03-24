// ─────────────────────────────────────────────────────────────────────────────
//  services/market_service.dart
//  Real data: data.gov.in mandi prices + ip-api location + transport calc
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/market_data.dart';
import 'weather_service.dart';

class LocationInfo {
  final String city;
  final String state;
  final double lat;
  final double lon;

  const LocationInfo({
    required this.city,
    required this.state,
    required this.lat,
    required this.lon,
  });
}

class MarketService {
  // ── Vehicle rates ₹/km ────────────────────────────────────────────────────
  static const Map<String, double> vehicleRates = {
    'Auto (< 100kg)': 15.0,
    'Mini Van': 12.0,
    'Lorry (> 500kg)': 10.0,
  };

  // ── Step 1: Get user location via ip-api (FREE, no key) ──────────────────
  static Future<LocationInfo> getUserLocation() async {
    try {
      final res = await http
          .get(Uri.parse(
              'http://ip-api.com/json/?fields=city,regionName,lat,lon'))
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final d = jsonDecode(res.body);
        return LocationInfo(
          city: d['city'] ?? 'Chennai',
          state: d['regionName'] ?? 'Tamil Nadu',
          lat: (d['lat'] as num).toDouble(),
          lon: (d['lon'] as num).toDouble(),
        );
      }
    } catch (_) {}

    // Fallback — default to Krishnagiri (common farming district)
    return const LocationInfo(
        city: 'Krishnagiri', state: 'Tamil Nadu', lat: 12.5186, lon: 78.2137);
  }

  // ── Step 2: Fetch real mandi prices from data.gov.in ─────────────────────
  static Future<List<Map<String, dynamic>>> fetchRealMandiPrices({
    required String state,
    required String crop,
  }) async {
    try {
      // Map common crop names to API commodity names
      final commodityMap = {
        'Tomato': 'Tomato',
        'Onion': 'Onion',
        'Potato': 'Potato',
        'Rice': 'Rice',
      };
      final commodity = commodityMap[crop] ?? crop;

      final url = Uri.parse(
        'https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070'
        '?api-key=$kGovApiKey'
        '&format=json'
        '&filters%5Bstate%5D=${Uri.encodeComponent(state)}'
        '&filters%5Bcommodity%5D=${Uri.encodeComponent(commodity)}'
        '&limit=20',
      );

      final res = await http.get(url).timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final records = data['records'] as List? ?? [];
        if (records.isNotEmpty) return List<Map<String, dynamic>>.from(records);
      }
    } catch (_) {}

    // Fallback dummy data if API fails
    return _fallbackData(crop);
  }

  // ── Step 3: Calculate real distance (Haversine formula) ──────────────────
  static double calcDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // Earth radius km
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _toRad(double deg) => deg * pi / 180;

  // ── Step 4: Build MarketData list with weather + distance ─────────────────
  static Future<List<MarketData>> getMarketsWithWeather({
    required String crop,
    required LocationInfo userLocation,
  }) async {
    // Fetch real mandi prices
    final mandiRecords =
        await fetchRealMandiPrices(state: userLocation.state, crop: crop);

    // Tamil Nadu district coordinates for distance calc
    final districtCoords = <String, List<double>>{
      'Chennai': [13.0827, 80.2707],
      'Coimbatore': [11.0168, 76.9558],
      'Madurai': [9.9252, 78.1198],
      'Salem': [11.6643, 78.1460],
      'Tiruchirappalli': [10.7905, 78.7047],
      'Tirupur': [11.1085, 77.3411],
      'Vellore': [12.9165, 79.1325],
      'Erode': [11.3410, 77.7172],
      'Thanjavur': [10.7870, 79.1378],
      'Hosur': [12.7409, 77.8253],
      'Krishnagiri': [12.5186, 78.2137],
      'Dharmapuri': [12.1278, 78.1580],
      'Tiruvannamalai': [12.2253, 79.0747],
      'Cuddalore': [11.7447, 79.7689],
      'Nagapattinam': [10.7672, 79.8449],
      'Ooty': [11.4102, 76.6950],
    };

    final result = <MarketData>[];
    final seen = <String>{};

    for (final record in mandiRecords) {
      try {
        final marketName = record['market'] as String? ?? 'Unknown Market';
        final district = record['district'] as String? ?? 'Chennai';
        final minPrice =
            double.tryParse(record['min_price']?.toString() ?? '0') ?? 0;
        final maxPrice =
            double.tryParse(record['max_price']?.toString() ?? '0') ?? 0;
        final modalPrice =
            double.tryParse(record['modal_price']?.toString() ?? '0') ?? 0;

        // Use modal price as current price
        final price = modalPrice > 0 ? modalPrice : (minPrice + maxPrice) / 2;

        if (price <= 0) continue;

        // Dedup by market name
        final key = marketName.toLowerCase();
        if (seen.contains(key)) continue;
        seen.add(key);

        // Distance calculation
        final coords = districtCoords[district] ?? districtCoords['Chennai']!;
        final distance = calcDistance(
          userLocation.lat,
          userLocation.lon,
          coords[0],
          coords[1],
        );

        // Get weather for the district
        final weather = await WeatherService.getWeather(district);

        result.add(MarketData(
          name: marketName,
          city: district,
          price: price,
          minPrice: minPrice,
          maxPrice: maxPrice,
          distance: distance,
          weatherDesc: weather.description,
          temperature: weather.temp,
          humidity: weather.humidity,
          isRainy: weather.isRainy,
          weatherIcon: weather.icon,
          arrivalDate: record['arrival_date'] as String? ?? '',
        ));
      } catch (_) {
        continue;
      }
    }

    // Sort by price descending
    result.sort((a, b) => b.price.compareTo(a.price));
    return result;
  }

  // ── Transport profit calculation ──────────────────────────────────────────
  static Map<String, double> calcProfit({
    required double pricePerKg,
    required double quantityKg,
    required double distanceKm,
    required double vehicleRate,
    double loadingCharge = 100.0,
  }) {
    final gross = pricePerKg * quantityKg;
    final transport = distanceKm * vehicleRate;
    final net = gross - transport - loadingCharge;
    final netPerKg = net / quantityKg;

    return {
      'gross': gross,
      'transport': transport,
      'loading': loadingCharge,
      'net': net,
      'netPerKg': netPerKg,
    };
  }

  // ── Final recommendation logic ────────────────────────────────────────────
  static MarketData? getBestMarket({
    required List<MarketData> markets,
    required double quantityKg,
    required double vehicleRate,
  }) {
    if (markets.isEmpty) return null;

    MarketData? best;
    double bestNetProfit = double.negativeInfinity;

    for (final m in markets) {
      final profit = calcProfit(
        pricePerKg: m.price,
        quantityKg: quantityKg,
        distanceKm: m.distance,
        vehicleRate: vehicleRate,
      );
      // Penalise rainy markets slightly
      final score = profit['net']! - (m.isRainy ? 200 : 0);
      if (score > bestNetProfit) {
        bestNetProfit = score;
        best = m;
      }
    }
    return best;
  }

  // ── Fallback data when API fails ──────────────────────────────────────────
  static List<Map<String, dynamic>> _fallbackData(String crop) {
    final prices = {
      'Tomato': [
        {
          'market': 'Koyambedu',
          'district': 'Chennai',
          'min_price': '28',
          'max_price': '36',
          'modal_price': '32',
          'arrival_date': 'Today'
        },
        {
          'market': 'Uzhavar Sandhai',
          'district': 'Coimbatore',
          'min_price': '24',
          'max_price': '32',
          'modal_price': '28',
          'arrival_date': 'Today'
        },
        {
          'market': 'Hosur Mandi',
          'district': 'Krishnagiri',
          'min_price': '22',
          'max_price': '30',
          'modal_price': '26',
          'arrival_date': 'Today'
        },
        {
          'market': 'Salem Market',
          'district': 'Salem',
          'min_price': '20',
          'max_price': '28',
          'modal_price': '24',
          'arrival_date': 'Today'
        },
        {
          'market': 'Madurai Mandi',
          'district': 'Madurai',
          'min_price': '26',
          'max_price': '34',
          'modal_price': '30',
          'arrival_date': 'Today'
        },
      ],
      'Onion': [
        {
          'market': 'Koyambedu',
          'district': 'Chennai',
          'min_price': '40',
          'max_price': '50',
          'modal_price': '45',
          'arrival_date': 'Today'
        },
        {
          'market': 'Krishnagiri',
          'district': 'Krishnagiri',
          'min_price': '35',
          'max_price': '45',
          'modal_price': '40',
          'arrival_date': 'Today'
        },
        {
          'market': 'Tirupur Mandi',
          'district': 'Tirupur',
          'min_price': '38',
          'max_price': '46',
          'modal_price': '42',
          'arrival_date': 'Today'
        },
        {
          'market': 'Salem Market',
          'district': 'Salem',
          'min_price': '33',
          'max_price': '43',
          'modal_price': '38',
          'arrival_date': 'Today'
        },
        {
          'market': 'Trichy Market',
          'district': 'Tiruchirappalli',
          'min_price': '31',
          'max_price': '41',
          'modal_price': '36',
          'arrival_date': 'Today'
        },
      ],
      'Potato': [
        {
          'market': 'Koyambedu',
          'district': 'Chennai',
          'min_price': '18',
          'max_price': '26',
          'modal_price': '22',
          'arrival_date': 'Today'
        },
        {
          'market': 'Ooty Market',
          'district': 'Ooty',
          'min_price': '14',
          'max_price': '22',
          'modal_price': '18',
          'arrival_date': 'Today'
        },
        {
          'market': 'Vellore Mandi',
          'district': 'Vellore',
          'min_price': '17',
          'max_price': '25',
          'modal_price': '21',
          'arrival_date': 'Today'
        },
        {
          'market': 'Salem Market',
          'district': 'Salem',
          'min_price': '15',
          'max_price': '23',
          'modal_price': '19',
          'arrival_date': 'Today'
        },
        {
          'market': 'Coimbatore',
          'district': 'Coimbatore',
          'min_price': '16',
          'max_price': '24',
          'modal_price': '20',
          'arrival_date': 'Today'
        },
      ],
      'Rice': [
        {
          'market': 'Thanjavur Mandi',
          'district': 'Thanjavur',
          'min_price': '30',
          'max_price': '40',
          'modal_price': '35',
          'arrival_date': 'Today'
        },
        {
          'market': 'Trichy Market',
          'district': 'Tiruchirappalli',
          'min_price': '28',
          'max_price': '38',
          'modal_price': '33',
          'arrival_date': 'Today'
        },
        {
          'market': 'Tiruvarur',
          'district': 'Nagapattinam',
          'min_price': '29',
          'max_price': '39',
          'modal_price': '34',
          'arrival_date': 'Today'
        },
        {
          'market': 'Cuddalore',
          'district': 'Cuddalore',
          'min_price': '26',
          'max_price': '36',
          'modal_price': '31',
          'arrival_date': 'Today'
        },
        {
          'market': 'Nagapattinam',
          'district': 'Nagapattinam',
          'min_price': '27',
          'max_price': '37',
          'modal_price': '32',
          'arrival_date': 'Today'
        },
      ],
    };
    return prices[crop] ?? prices['Tomato']!;
  }
}
