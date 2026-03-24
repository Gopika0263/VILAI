// ─────────────────────────────────────────────────────────────────────────────
//  models/market_data.dart
// ─────────────────────────────────────────────────────────────────────────────

class MarketData {
  final String name;
  final String city;
  final String weatherDesc;
  final String weatherIcon;
  final String arrivalDate;
  final double price; // modal price ₹/kg
  final double minPrice; // min price from mandi
  final double maxPrice; // max price from mandi
  final double distance; // km from user location
  final double temperature;
  final int humidity;
  final bool isRainy;

  MarketData({
    required this.name,
    required this.city,
    required this.price,
    required this.distance,
    required this.weatherDesc,
    required this.temperature,
    required this.isRainy,
    required this.weatherIcon,
    this.minPrice = 0,
    this.maxPrice = 0,
    this.humidity = 60,
    this.arrivalDate = '',
  });
}
