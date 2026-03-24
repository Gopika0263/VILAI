// ─────────────────────────────────────────────────────────────────────────────
//  screens/markets_screen.dart
//  Real location (ip-api) + Real prices (data.gov.in) + Weather + Transport
//  + Final AI Recommendation
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/market_data.dart';
import '../services/market_service.dart';

class MarketsScreen extends StatefulWidget {
  const MarketsScreen({super.key});

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  // ── State ─────────────────────────────────────────────────────────────────
  List<MarketData> _markets = [];
  MarketData? _bestMarket;
  LocationInfo? _userLocation;
  bool _loading = true;
  String _loadingMsg = 'Detecting your location...';
  String _crop = 'Tomato';
  String _vehicle = 'Mini Van';
  double _quantity = 100;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  // ── Load everything ───────────────────────────────────────────────────────
  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _errorMsg = null;
      _loadingMsg = '📍 Detecting your location...';
    });

    try {
      // Step 1: Get user location
      final loc = await MarketService.getUserLocation();
      setState(() {
        _userLocation = loc;
        _loadingMsg = '🏪 Fetching real mandi prices...';
      });

      // Step 2: Fetch markets with weather
      final markets = await MarketService.getMarketsWithWeather(
          crop: _crop, userLocation: loc);

      // Step 3: Find best market (price + transport + weather)
      final best = MarketService.getBestMarket(
        markets: markets,
        quantityKg: _quantity,
        vehicleRate: MarketService.vehicleRates[_vehicle]!,
      );

      setState(() {
        _markets = markets;
        _bestMarket = best;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMsg = 'Error: ${e.toString().replaceFirst('Exception: ', '')}';
      });
    }
  }

  // ── Recalculate best market when qty/vehicle changes ─────────────────────
  void _recalcBest() {
    setState(() {
      _bestMarket = MarketService.getBestMarket(
        markets: _markets,
        quantityKg: _quantity,
        vehicleRate: MarketService.vehicleRates[_vehicle]!,
      );
    });
  }

  // ── Weather emoji ─────────────────────────────────────────────────────────
  String _wEmoji(String icon) =>
      {
        'Clear': '☀️',
        'Clouds': '☁️',
        'Rain': '🌧️',
        'Drizzle': '🌦️',
        'Thunderstorm': '⛈️',
      }[icon] ??
      '🌤️';

  // ─────────────────────────────────────────────────────────────────────────
  //  WIDGETS
  // ─────────────────────────────────────────────────────────────────────────

  // ── Loading screen ────────────────────────────────────────────────────────
  Widget _loadingView() => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const CircularProgressIndicator(color: kGreen700),
          const SizedBox(height: 16),
          Text(_loadingMsg,
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          const Text('Fetching real-time data...',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ]),
      );

  // ── Error view ────────────────────────────────────────────────────────────
  Widget _errorView() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(_errorMsg ?? 'Something went wrong',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadAll,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen700, foregroundColor: Colors.white),
            ),
          ]),
        ),
      );

  // ── Input controls card (quantity + vehicle) ──────────────────────────────
  Widget _controlsCard() => Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('⚙️ Your Details',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [
            // Quantity slider
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Quantity: ${_quantity.toInt()} kg',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                  Slider(
                    value: _quantity,
                    min: 50,
                    max: 1000,
                    divisions: 19,
                    activeColor: kGreen700,
                    onChanged: (v) {
                      setState(() => _quantity = v);
                      _recalcBest();
                    },
                  ),
                ])),
            const SizedBox(width: 8),
            // Vehicle dropdown
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('Vehicle',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        border: Border.all(color: kGreen700),
                        borderRadius: BorderRadius.circular(8)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _vehicle,
                        isExpanded: true,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF1A1A1A)),
                        items: MarketService.vehicleRates.keys
                            .map((v) => DropdownMenuItem(
                                value: v,
                                child: Text(v,
                                    style: const TextStyle(fontSize: 11))))
                            .toList(),
                        onChanged: (v) {
                          setState(() => _vehicle = v!);
                          _recalcBest();
                        },
                      ),
                    ),
                  ),
                ])),
          ]),
        ]),
      );

  // ── FINAL RECOMMENDATION banner ───────────────────────────────────────────
  Widget _recommendationBanner() {
    if (_bestMarket == null) return const SizedBox();
    final rate = MarketService.vehicleRates[_vehicle]!;
    final profit = MarketService.calcProfit(
      pricePerKg: _bestMarket!.price,
      quantityKg: _quantity,
      distanceKm: _bestMarket!.distance,
      vehicleRate: rate,
    );
    final isGood = profit['net']! > 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: isGood
                ? [kGreen700, kGreen900]
                : [Colors.orange.shade700, Colors.orange.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: (isGood ? kGreen700 : Colors.orange).withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Title
          Row(children: [
            const Text('🏆', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            const Text('FINAL RECOMMENDATION',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5)),
            const Spacer(),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                    _bestMarket!.arrivalDate.isNotEmpty
                        ? _bestMarket!.arrivalDate
                        : 'Today',
                    style: const TextStyle(color: Colors.white, fontSize: 10))),
          ]),
          const SizedBox(height: 10),

          // Main recommendation text
          Text(
              isGood
                  ? 'Sell ${_quantity.toInt()} kg $_crop at ${_bestMarket!.name}, '
                      '${_bestMarket!.city} for maximum profit!'
                  : 'Warning: Transport cost is high. Consider a closer market.',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  height: 1.4)),
          const SizedBox(height: 12),

          // Stats row
          Row(children: [
            _recoPill(
                '💰', '₹${_bestMarket!.price.toInt()}/kg', 'Market Price'),
            const SizedBox(width: 8),
            _recoPill('📍', '${_bestMarket!.distance.toInt()} km', 'Distance'),
            const SizedBox(width: 8),
            _recoPill(_wEmoji(_bestMarket!.weatherIcon),
                _bestMarket!.isRainy ? 'Rain' : 'Clear', 'Weather'),
          ]),
          const SizedBox(height: 12),

          // Profit breakdown
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              _profitRow('Gross Revenue',
                  '₹${profit['gross']!.toStringAsFixed(0)}', false),
              _profitRow(
                  'Transport Cost (${_bestMarket!.distance.toInt()} km × ₹${rate.toInt()})',
                  '- ₹${profit['transport']!.toStringAsFixed(0)}',
                  true),
              _profitRow('Loading/Unloading',
                  '- ₹${profit['loading']!.toStringAsFixed(0)}', true),
              const Divider(color: Colors.white38, height: 16),
              _profitRow(
                  'NET PROFIT', '₹${profit['net']!.toStringAsFixed(0)}', false,
                  isBig: true),
              _profitRow('Per KG profit',
                  '₹${profit['netPerKg']!.toStringAsFixed(2)}/kg', false),
            ]),
          ),
          const SizedBox(height: 10),

          // Weather advice
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Text(_wEmoji(_bestMarket!.weatherIcon),
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(
                      _bestMarket!.isRainy
                          ? '⚠️ Rain expected in ${_bestMarket!.city}. Cover crops well before transport!'
                          : '✅ Weather is clear in ${_bestMarket!.city}. Good day to transport!',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12, height: 1.4))),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _recoPill(String emoji, String value, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10)),
          child: Column(children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ]),
        ),
      );

  Widget _profitRow(String label, String value, bool isDeduction,
          {bool isBig = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: Colors.white70, fontSize: isBig ? 13 : 11))),
          Text(value,
              style: TextStyle(
                  color: isDeduction ? Colors.redAccent[100] : Colors.white,
                  fontWeight: isBig ? FontWeight.bold : FontWeight.w600,
                  fontSize: isBig ? 16 : 12)),
        ]),
      );

  // ── Bar graph ─────────────────────────────────────────────────────────────
  Widget _barGraph() {
    if (_markets.isEmpty) return const SizedBox();
    final maxP = _markets.map((m) => m.price).reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('📊 ', style: TextStyle(fontSize: 16)),
          Text('Price Comparison — $_crop (₹/kg)',
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 14),
        ..._markets.asMap().entries.map((e) {
          final i = e.key;
          final m = e.value;
          final frac = m.price / maxP;
          final isBest = _bestMarket?.name == m.name;
          final rate = MarketService.vehicleRates[_vehicle]!;
          final profit = MarketService.calcProfit(
              pricePerKg: m.price,
              quantityKg: _quantity,
              distanceKm: m.distance,
              vehicleRate: rate);
          final netPerKg = profit['netPerKg']!;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              SizedBox(
                  width: 76,
                  child: Text(m.name.split(' ').first,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isBest ? FontWeight.bold : FontWeight.normal,
                          color: isBest ? kGreen700 : Colors.grey[600]),
                      overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 6),
              Expanded(
                  child: Stack(children: [
                Container(
                    height: 26,
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6))),
                FractionallySizedBox(
                    widthFactor: frac,
                    child: Container(
                        height: 26,
                        decoration: BoxDecoration(
                            color: isBest
                                ? kGreen700
                                : m.isRainy
                                    ? Colors.orange.shade300
                                    : kGreen500.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(6)),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 8),
                        child: Text('₹${m.price.toInt()}',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: frac > 0.4
                                    ? Colors.white
                                    : Colors.grey[700])))),
              ])),
              const SizedBox(width: 6),
              Text(_wEmoji(m.weatherIcon),
                  style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              // Net profit per kg
              SizedBox(
                  width: 52,
                  child: Text(
                      netPerKg >= 0
                          ? '+₹${netPerKg.toStringAsFixed(1)}'
                          : '-₹${netPerKg.abs().toStringAsFixed(1)}',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: netPerKg >= 0 ? kGreen700 : Colors.red[600]),
                      textAlign: TextAlign.right)),
              if (isBest)
                const Icon(Icons.emoji_events, color: kAmber, size: 16),
            ]),
          );
        }),
        const SizedBox(height: 6),
        Wrap(spacing: 12, runSpacing: 4, children: [
          _leg(kGreen700, 'Best market'),
          _leg(kGreen500.withOpacity(0.6), 'Good price'),
          _leg(Colors.orange.shade300, 'Rain risk'),
          const SizedBox(width: 4),
          const Text('+₹X = net profit/kg after transport',
              style: TextStyle(fontSize: 9, color: Colors.grey)),
        ]),
      ]),
    );
  }

  Widget _leg(Color c, String l) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: c, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(l, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ]);

  // ── Individual market card ─────────────────────────────────────────────────
  Widget _marketCard(MarketData m, int rank) {
    final isBest = _bestMarket?.name == m.name;
    final rate = MarketService.vehicleRates[_vehicle]!;
    final profit = MarketService.calcProfit(
        pricePerKg: m.price,
        quantityKg: _quantity,
        distanceKm: m.distance,
        vehicleRate: rate);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isBest ? Border.all(color: kGreen700, width: 2) : null,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ]),
      child: Column(children: [
        // ── Header ──────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: isBest ? kGreen100 : Colors.grey[50],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14))),
          child: Row(children: [
            Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: isBest ? kGreen700 : Colors.grey[300],
                    borderRadius: BorderRadius.circular(16)),
                child: Center(
                    child: Text(isBest ? '🏆' : '#$rank',
                        style: TextStyle(
                            fontSize: isBest ? 14 : 12,
                            fontWeight: FontWeight.bold,
                            color: isBest ? Colors.white : Colors.grey[600])))),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(m.name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isBest ? kGreen700 : const Color(0xFF1A1A1A))),
                  Text('📍 ${m.city} • ${m.distance.toInt()} km away',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ])),
            // Price column
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('₹${m.price.toInt()}',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isBest ? kGreen700 : const Color(0xFF1A1A1A))),
              const Text('/kg',
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
              if (m.minPrice > 0)
                Text('₹${m.minPrice.toInt()}–₹${m.maxPrice.toInt()}',
                    style: const TextStyle(fontSize: 9, color: Colors.grey)),
            ]),
          ]),
        ),

        // ── Weather row ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
          child: Row(children: [
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: m.isRainy
                        ? const Color(0xFFFFEBEE)
                        : const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(_wEmoji(m.weatherIcon),
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(m.weatherDesc,
                      style: TextStyle(
                          fontSize: 11,
                          color:
                              m.isRainy ? Colors.red[700] : Colors.blue[700])),
                ])),
            const SizedBox(width: 8),
            Text('${m.temperature.toStringAsFixed(1)}°C  💧${m.humidity}%',
                style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            const Spacer(),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: m.isRainy ? Colors.orange[50] : kGreen100,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(m.isRainy ? '⚠️ Rain risk' : '✅ Safe travel',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: m.isRainy ? Colors.orange[800] : kGreen700))),
          ]),
        ),

        // ── Transport profit row ─────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: kBg, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            const Text('🚜 ', style: TextStyle(fontSize: 14)),
            Expanded(
                child: Text(
                    'Transport: ₹${profit['transport']!.toStringAsFixed(0)}'
                    '  |  Net: ₹${profit['net']!.toStringAsFixed(0)}'
                    '  |  Per kg: ₹${profit['netPerKg']!.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[700]))),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: profit['net']! > 0 ? kGreen100 : Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: profit['net']! > 0
                            ? kGreen700
                            : Colors.red.shade300)),
                child: Text(profit['net']! > 0 ? '✅ Profitable' : '❌ Loss',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color:
                            profit['net']! > 0 ? kGreen700 : Colors.red[700]))),
          ]),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kGreen700,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('🏪 Nearby Markets',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text(
              _userLocation != null
                  ? '📍 ${_userLocation!.city}, ${_userLocation!.state}'
                  : 'Detecting location...',
              style: const TextStyle(fontSize: 11, color: Color(0xFFA5D6A7))),
        ]),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: _loadAll),
        ],
      ),
      body: Column(children: [
        // ── Crop selector ────────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
                children: kCrops.map((c) {
              final sel = _crop == c;
              return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                      label: Text('${kCropEmojis[c]} $c'),
                      selected: sel,
                      selectedColor: kGreen100,
                      onSelected: (_) {
                        setState(() => _crop = c);
                        _loadAll();
                      },
                      side: BorderSide(
                          color: sel ? kGreen700 : Colors.grey[300]!)));
            }).toList()),
          ),
        ),

        // ── Content ──────────────────────────────────────────────────────
        Expanded(
            child: _loading
                ? _loadingView()
                : _errorMsg != null
                    ? _errorView()
                    : RefreshIndicator(
                        color: kGreen700,
                        onRefresh: _loadAll,
                        child: ListView(
                          padding: const EdgeInsets.only(bottom: 32),
                          children: [
                            // Controls
                            _controlsCard(),
                            // Final recommendation
                            _recommendationBanner(),
                            // Bar graph
                            _barGraph(),
                            // Market cards
                            Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 12, 16, 0),
                                child: const Text('📋 All Markets',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold))),
                            const SizedBox(height: 8),
                            ..._markets.asMap().entries.map((e) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: _marketCard(e.value, e.key + 1))),
                          ],
                        ),
                      )),
      ]),
    );
  }
}
