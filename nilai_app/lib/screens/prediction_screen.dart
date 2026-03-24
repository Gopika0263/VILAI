// ─────────────────────────────────────────────────────────────────────────────
//  screens/prediction_screen.dart
//
//  PATH A: data.gov.in real prices found
//          → Linear Regression on real data
//          → LineChart: Historical line + Regression line + Predicted line
//
//  PATH B: No real data (API down / city not found)
//          → Groq AI analyses Tamil Nadu seasonal patterns + city + month
//          → AI gives best day recommendation
//          → Never shows error — always gives answer!
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../services/language_service.dart';

const List<String> kCities = [
  'Chennai',
  'Coimbatore',
  'Madurai',
  'Salem',
  'Trichy',
  'Erode',
  'Vellore',
  'Thanjavur',
  'Karur',
  'Krishnagiri',
  'Dindigul',
  'Namakkal',
  'Tiruppur',
  'Kanchipuram',
  'Tirunelveli',
];

const Map<String, int> kShelf = {
  'Tomato': 7,
  'Onion': 30,
  'Potato': 21,
  'Rice': 180,
};

// ── Data source enum ──────────────────────────────────────────────────────────
enum DataSource { realAPI, aiAnalysis }

// ── Day result ────────────────────────────────────────────────────────────────
class DayResult {
  final int day;
  final String label;
  final double pricePerKg;
  final double total;
  final double vsToday;
  final bool isBest;
  final bool safe;
  DayResult({
    required this.day,
    required this.label,
    required this.pricePerKg,
    required this.total,
    required this.vsToday,
    required this.isBest,
    required this.safe,
  });
}

// ── Full result ───────────────────────────────────────────────────────────────
class SellResult {
  final String city;
  final String crop;
  final double qty;
  final double todayPriceKg;
  final String marketName;
  final DataSource source;
  // Chart data
  final List<double> historicalPrices; // real or AI-estimated
  final List<double> regressionLine; // y = mx + b values
  final List<double> predictedPrices; // future predicted
  // Results
  final List<DayResult> days;
  final int bestDay;
  final double bestTotal;
  final double extraIfWait;
  final String tamilAdvice;
  final String englishAdvice;
  // ML stats (PATH A) or AI stats (PATH B)
  final double slope;
  final double rSquared;
  final String analysisNote; // shown to user

  SellResult({
    required this.city,
    required this.crop,
    required this.qty,
    required this.todayPriceKg,
    required this.marketName,
    required this.source,
    required this.historicalPrices,
    required this.regressionLine,
    required this.predictedPrices,
    required this.days,
    required this.bestDay,
    required this.bestTotal,
    required this.extraIfWait,
    required this.tamilAdvice,
    required this.englishAdvice,
    required this.slope,
    required this.rSquared,
    required this.analysisNote,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});
  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  String _city = 'Chennai';
  String _crop = 'Tomato';
  double _qty = 100;
  int _daysHarvested = 0;

  bool _loading = false;
  String _status = '';
  SellResult? _result;

  // ═══════════════════════════════════════════════════════════════════
  //  PATH A — Fetch real prices from data.gov.in
  // ═══════════════════════════════════════════════════════════════════
  Future<Map<String, dynamic>?> _fetchRealPrices() async {
    setState(() => _status = '📥 data.gov.in → real market prices...');

    final commodity = {
      'Tomato': 'Tomato',
      'Onion': 'Onion',
      'Potato': 'Potato',
      'Rice': 'Rice(Common)',
    }[_crop]!;

    try {
      final url = Uri.parse('https://api.data.gov.in/resource/'
          '9ef84268-d588-465a-a308-a864a43d0070'
          '?api-key=$kGovApiKey&format=json'
          '&filters%5Bstate%5D=Tamil+Nadu'
          '&filters%5Bcommodity%5D=${Uri.encodeComponent(commodity)}'
          '&limit=100&sort%5Barrival_date%5D=desc');

      final res = await http.get(url).timeout(const Duration(seconds: 12));

      if (res.statusCode != 200) return null;

      final records = json.decode(res.body)['records'] as List? ?? [];
      if (records.isEmpty) return null;

      final Map<String, List<double>> cityByDate = {};
      final Map<String, List<double>> tnByDate = {};
      String? cityMarket;

      for (final r in records) {
        final qPrice =
            double.tryParse(r['modal_price']?.toString() ?? '0') ?? 0;
        if (qPrice <= 0) continue;
        final date = r['arrival_date']?.toString() ?? '';
        final market = r['market']?.toString() ?? '';
        final dist = r['district']?.toString().toLowerCase() ?? '';
        if (market.toLowerCase().contains(_city.toLowerCase()) ||
            dist.contains(_city.toLowerCase())) {
          cityMarket ??= market;
          cityByDate.putIfAbsent(date, () => []).add(qPrice / 100);
        } else {
          tnByDate.putIfAbsent(date, () => []).add(qPrice / 100);
        }
      }

      final useCity = cityByDate.length >= 3;
      final byDate = useCity ? cityByDate : tnByDate;
      final mktName =
          useCity ? (cityMarket ?? '$_city APMC') : 'Tamil Nadu Average';

      if (byDate.isEmpty) return null;

      final sorted = byDate.keys.toList()..sort();
      final prices = sorted.map((d) {
        final v = byDate[d]!;
        return v.reduce((a, b) => a + b) / v.length;
      }).toList();

      if (prices.length < 3) return null;

      return {
        'prices': prices,
        'market': mktName,
        'isCity': useCity,
      };
    } catch (_) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  LINEAR REGRESSION  y = mx + b
  // ═══════════════════════════════════════════════════════════════════
  Map<String, double> _linearRegression(List<double> prices) {
    final n = prices.length.toDouble();
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    for (int i = 0; i < prices.length; i++) {
      sumX += i;
      sumY += prices[i];
      sumXY += i * prices[i];
      sumX2 += i * i;
    }
    final denom = n * sumX2 - sumX * sumX;
    if (denom == 0) return {'slope': 0, 'intercept': sumY / n, 'rSquared': 0};
    final m = (n * sumXY - sumX * sumY) / denom;
    final b = (sumY - m * sumX) / n;
    final yMean = sumY / n;
    double ssTot = 0, ssRes = 0;
    for (int i = 0; i < prices.length; i++) {
      ssTot += pow(prices[i] - yMean, 2);
      ssRes += pow(prices[i] - (m * i + b), 2);
    }
    final r2 = ssTot > 0 ? max(0.0, 1.0 - ssRes / ssTot) : 0.0;
    return {'slope': m, 'intercept': b, 'rSquared': r2};
  }

  // ═══════════════════════════════════════════════════════════════════
  //  PATH A — Process real data → regression → predict
  // ═══════════════════════════════════════════════════════════════════
  Future<SellResult> _pathA(List<double> prices, String market) async {
    setState(() => _status = '📈 Linear Regression on real data...');
    await Future.delayed(const Duration(milliseconds: 500));

    final lr = _linearRegression(prices);
    final m = lr['slope']!;
    final b = lr['intercept']!;
    final r2 = lr['rSquared']!;
    final n = prices.length;
    final todayKg = prices.last;

    // Regression line values over historical data
    final regLine = List.generate(n, (i) => m * i + b);

    // Predict future days
    final shelf = kShelf[_crop]!;
    final daysLeft = shelf - _daysHarvested;
    final safeDays = max(1, min(daysLeft - 1, 7));

    setState(() => _status = '🔮 Predicting next $safeDays days...');
    await Future.delayed(const Duration(milliseconds: 300));

    final predicted = List.generate(safeDays, (i) {
      final d = i + 1;
      double p = m * (n - 1 + d) + b;
      return p.clamp(todayKg * 0.80, todayKg * 1.20).toDouble().roundToDouble();
    });

    return _buildResult(
      source: DataSource.realAPI,
      market: market,
      todayKg: todayKg,
      historical: prices,
      regLine: regLine,
      predicted: predicted,
      slope: m,
      rSquared: r2,
      analysisNote: 'data.gov.in real data • ${prices.length} days • '
          'Linear Regression (R²=${(r2 * 100).toStringAsFixed(0)}%)',
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  PATH B — No real data → Groq AI analyses patterns
  // ═══════════════════════════════════════════════════════════════════
  Future<SellResult> _pathB() async {
    setState(() => _status = '🤖 AI analysing Tamil Nadu patterns...');

    final month = DateTime.now().month;
    final monthName = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ][month - 1];
    final shelf = kShelf[_crop]!;
    final daysLeft = shelf - _daysHarvested;
    final safeDays = max(1, min(daysLeft - 1, 7));

    // Ask Groq AI for price estimates based on patterns
    String aiResponse = '';
    try {
      final res = await http
          .post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer $kGroqApiKey',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'model': 'llama-3.3-70b-versatile',
              'max_tokens': 400,
              'temperature': 0.2,
              'messages': [
                {
                  'role': 'user',
                  'content': 'You are an expert on Tamil Nadu agricultural markets.\n'
                      'City: $_city, Crop: $_crop, Month: $monthName\n'
                      'Farmer has ${_qty.toInt()} kg, harvested $_daysHarvested days ago.\n'
                      'Shelf life: ${kShelf[_crop]} days ($daysLeft days left).\n\n'
                      'Based on Tamil Nadu seasonal patterns and historical trends for $_crop in $_city:\n'
                      '1. Estimate today price in ₹ per kg (realistic)\n'
                      '2. Predict prices for next $safeDays days\n\n'
                      'Return ONLY valid JSON, no markdown:\n'
                      '{"today":28.5,"predictions":[29.0,30.5,32.0,31.0,30.0,28.0,27.0],'
                      '"best_day":2,"trend":"up",'
                      '"tamil_advice":"⭐ 2 நாள் காத்திரு! ₹3200 கிடைக்கும்!",'
                      '"english_advice":"Wait 2 days for best price!",'
                      '"market_name":"$_city Uzhavar Sandhai"}'
                }
              ],
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        aiResponse =
            json.decode(res.body)['choices'][0]['message']['content'] as String;
      }
    } catch (_) {}

    // Parse AI response
    try {
      final cleaned =
          aiResponse.replaceAll('```json', '').replaceAll('```', '').trim();
      final parsed = json.decode(cleaned);

      final todayKg = (parsed['today'] as num).toDouble();
      final preds = (parsed['predictions'] as List)
          .take(safeDays)
          .map((p) => (p as num).toDouble())
          .toList();
      final mktName =
          parsed['market_name']?.toString() ?? '$_city Uzhavar Sandhai';
      final tAdv = parsed['tamil_advice']?.toString() ?? '';
      final eAdv = parsed['english_advice']?.toString() ?? '';

      // Run regression on AI-estimated prices for chart consistency
      final allPrices = [todayKg, ...preds];
      final lr = _linearRegression(allPrices);
      final regLine = List.generate(
          allPrices.length, (i) => lr['slope']! * i + lr['intercept']!);

      return _buildResult(
        source: DataSource.aiAnalysis,
        market: mktName,
        todayKg: todayKg,
        historical: [todayKg], // only today known
        regLine: regLine,
        predicted: preds,
        slope: lr['slope']!,
        rSquared: lr['rSquared']!,
        analysisNote: 'AI Analysis (Groq LLaMA 3.3 70B) • '
            'Based on $_city seasonal patterns • $monthName trends',
        overrideTamil: tAdv,
        overrideEnglish: eAdv,
      );
    } catch (_) {
      // Last resort fallback using crop seasonal knowledge
      return _aiSeasonalFallback(safeDays);
    }
  }

  // ── Seasonal fallback when AI JSON parsing fails ─────────────────
  Future<SellResult> _aiSeasonalFallback(int safeDays) async {
    // Real seasonal patterns for TN crops
    final month = DateTime.now().month;
    final basePrices = {
      'Tomato': [35, 38, 32, 28, 26, 24, 22, 25, 28, 30, 33, 36],
      'Onion': [28, 26, 24, 22, 24, 28, 32, 35, 38, 36, 32, 30],
      'Potato': [20, 18, 16, 18, 20, 22, 24, 22, 20, 18, 18, 19],
      'Rice': [22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22],
    };
    final seasonBase = basePrices[_crop]![month - 1].toDouble();

    final preds = List.generate(safeDays, (i) {
      // slight upward trend then leveling
      return double.parse((seasonBase * (1 + i * 0.01)).toStringAsFixed(2));
    });

    final lr = _linearRegression([seasonBase, ...preds]);
    final regLine = List.generate(
        preds.length + 1, (i) => lr['slope']! * i + lr['intercept']!);

    return _buildResult(
      source: DataSource.aiAnalysis,
      market: '$_city Uzhavar Sandhai (Seasonal Estimate)',
      todayKg: seasonBase,
      historical: [seasonBase],
      regLine: regLine,
      predicted: preds,
      slope: lr['slope']!,
      rSquared: 0.0,
      analysisNote: 'Tamil Nadu seasonal patterns • '
          '${[
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][month - 1]} '
          'typical prices for $_crop',
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  BUILD SellResult from any path
  // ═══════════════════════════════════════════════════════════════════
  Future<SellResult> _buildResult({
    required DataSource source,
    required String market,
    required double todayKg,
    required List<double> historical,
    required List<double> regLine,
    required List<double> predicted,
    required double slope,
    required double rSquared,
    required String analysisNote,
    String? overrideTamil,
    String? overrideEnglish,
  }) async {
    final shelf = kShelf[_crop]!;
    final daysLeft = shelf - _daysHarvested;

    final allPrices = [todayKg, ...predicted];
    final maxPrice = allPrices.reduce(max);
    final bestIdx = allPrices.indexOf(maxPrice);

    final days = <DayResult>[];
    days.add(DayResult(
        day: 0,
        label: langService.t('today'),
        pricePerKg: todayKg,
        total: todayKg * _qty,
        vsToday: 0,
        isBest: bestIdx == 0,
        safe: true));

    for (int i = 0; i < predicted.length; i++) {
      final d = i + 1;
      final p = predicted[i];
      days.add(DayResult(
          day: d,
          label: d == 1
              ? langService.t('tomorrow')
              : '${langService.t("today")} $d',
          pricePerKg: p,
          total: p * _qty,
          vsToday: (p - todayKg) * _qty,
          isBest: bestIdx == d,
          safe: d < daysLeft));
    }

    final best = days[bestIdx];
    final extra = best.total - days[0].total;

    // Get AI Tamil advice if not already provided
    String tAdvice = overrideTamil ?? '';
    String eAdvice = overrideEnglish ?? '';

    if (tAdvice.isEmpty) {
      setState(() => _status = '🤖 Tamil advice...');
      try {
        final res = await http
            .post(
              Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
              headers: {
                'Authorization': 'Bearer $kGroqApiKey',
                'Content-Type': 'application/json',
              },
              body: json.encode({
                'model': 'llama-3.3-70b-versatile',
                'max_tokens': 80,
                'temperature': 0.2,
                'messages': [
                  {
                    'role': 'user',
                    'content': 'Tamil farmer $_city, ${_qty.toInt()} kg $_crop.\n'
                        'Today ₹${todayKg.toStringAsFixed(2)}/kg = '
                        '₹${(todayKg * _qty).toStringAsFixed(0)} total.\n'
                        'Best day $bestIdx: ₹${best.pricePerKg.toStringAsFixed(2)}/kg = '
                        '₹${best.total.toStringAsFixed(0)} '
                        '(₹${extra.toStringAsFixed(0)} more).\n'
                        'Write:\nTAMIL: [emoji+Tamil, max 12 words]\n'
                        'ENGLISH: [English, max 10 words]',
                  }
                ],
              }),
            )
            .timeout(const Duration(seconds: 8));

        if (res.statusCode == 200) {
          final text = json.decode(res.body)['choices'][0]['message']['content']
              as String;
          for (final l in text.split('\n')) {
            if (l.startsWith('TAMIL:'))
              tAdvice = l.replaceFirst('TAMIL:', '').trim();
            if (l.startsWith('ENGLISH:'))
              eAdvice = l.replaceFirst('ENGLISH:', '').trim();
          }
        }
      } catch (_) {}
    }

    if (tAdvice.isEmpty) {
      tAdvice = bestIdx == 0
          ? '✅ இன்னைக்கே விக்கணும்! Best price today!'
          : '⏳ $bestIdx நாள் காத்திரு! ₹${extra.toStringAsFixed(0)} அதிகம்!';
      eAdvice = bestIdx == 0
          ? 'Sell TODAY — best price!'
          : 'Wait $bestIdx days — ₹${extra.toStringAsFixed(0)} more profit!';
    }

    return SellResult(
      city: _city,
      crop: _crop,
      qty: _qty,
      todayPriceKg: todayKg,
      marketName: market,
      source: source,
      historicalPrices: historical,
      regressionLine: regLine,
      predictedPrices: predicted,
      days: days,
      bestDay: bestIdx,
      bestTotal: best.total,
      extraIfWait: extra,
      tamilAdvice: tAdvice,
      englishAdvice: eAdvice,
      slope: slope,
      rSquared: rSquared,
      analysisNote: analysisNote,
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  MAIN — Try PATH A first, fallback to PATH B
  // ═══════════════════════════════════════════════════════════════════
  Future<void> _analyze() async {
    setState(() {
      _loading = true;
      _result = null;
    });

    try {
      // Try PATH A
      final realData = await _fetchRealPrices();

      SellResult result;
      if (realData != null) {
        final prices = (realData['prices'] as List).cast<double>();
        final market = realData['market'] as String;
        result = await _pathA(prices, market);
      } else {
        // PATH B — AI analysis
        setState(() => _status = '⚠️ Real data இல்லை → AI analysis...');
        await Future.delayed(const Duration(milliseconds: 400));
        result = await _pathB();
      }

      setState(() {
        _result = result;
        _loading = false;
        _status = '';
      });
    } catch (e) {
      // Even on error, try PATH B
      try {
        final result = await _pathB();
        setState(() {
          _result = result;
          _loading = false;
          _status = '';
        });
      } catch (_) {
        setState(() {
          _loading = false;
          _status = '';
        });
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  LINE CHART (fl_chart)
  //  Line 1: Green solid  — Historical real prices
  //  Line 2: Blue dashed  — Regression line (ML model)
  //  Line 3: Orange dots  — Predicted prices
  // ═══════════════════════════════════════════════════════════════════
  Widget _lineChart() {
    final r = _result!;
    final hist = r.historicalPrices;
    final pred = r.predictedPrices;
    final reg = r.regressionLine;

    // All values for Y axis range
    final allVals = [...hist, ...pred, ...reg];
    final maxY = allVals.reduce(max) * 1.12;
    final minY = allVals.reduce(min) * 0.90;

    // ── LINE 1: Historical (green solid) ──────────────────────────
    final histSpots = hist
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    // ── LINE 2: Regression (blue dashed) ──────────────────────────
    // Draw regression line across both historical + predicted range
    final totalPoints = hist.length + pred.length;
    final regSpots = List.generate(
        totalPoints,
        (i) => FlSpot(
            i.toDouble(),
            (r.slope * i + r.regressionLine.first - r.slope * 0)
                .clamp(minY, maxY)));

    // Actually use the proper regression values
    final regSpotsReal = reg
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.clamp(minY, maxY)))
        .toList();

    // ── LINE 3: Predicted (orange with dots) ──────────────────────
    final offset = hist.isEmpty ? 0 : hist.length - 1;
    final predSpots = [
      // Connect from last historical point
      if (hist.isNotEmpty) FlSpot(offset.toDouble(), hist.last),
      // Predicted points
      ...pred
          .asMap()
          .entries
          .map((e) => FlSpot((offset + e.key + 1).toDouble(), e.value)),
    ];

    // Best day spot for annotation
    final bestX = (offset + r.bestDay).toDouble();
    final bestY =
        r.bestDay == 0 ? r.todayPriceKg : r.predictedPrices[r.bestDay - 1];

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          clipData: const FlClipData.all(),
          gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (v) =>
                  FlLine(color: Colors.grey.withOpacity(0.12), strokeWidth: 1)),
          borderData: FlBorderData(
              show: true,
              border: Border(
                  bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  left: BorderSide(color: Colors.grey.withOpacity(0.3)))),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    getTitlesWidget: (val, _) => Text(
                        '₹${val.toStringAsFixed(0)}',
                        style:
                            TextStyle(fontSize: 9, color: Colors.grey[500])))),
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, _) {
                      final idx = val.toInt();
                      if (idx == offset) {
                        return const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text('Today',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: kGreen700,
                                    fontWeight: FontWeight.bold)));
                      }
                      if (idx > offset) {
                        final d = idx - offset;
                        if (d > 0 && d <= pred.length) {
                          final day = r.days[d];
                          return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(day.isBest ? '⭐' : '${d}d',
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: day.isBest
                                          ? Colors.orange[700]!
                                          : Colors.grey[500]!,
                                      fontWeight: day.isBest
                                          ? FontWeight.bold
                                          : FontWeight.normal)));
                        }
                      }
                      return const SizedBox.shrink();
                    })),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),

          // Extra lines: vertical line at "Today"
          extraLinesData: ExtraLinesData(verticalLines: [
            VerticalLine(
                x: offset.toDouble(),
                color: Colors.grey.withOpacity(0.4),
                strokeWidth: 1,
                dashArray: [4, 4]),
          ]),

          lineBarsData: [
            // LINE 1: Historical — green solid
            if (histSpots.isNotEmpty)
              LineChartBarData(
                  spots: histSpots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: kGreen700,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                          radius: 3,
                          color: kGreen700,
                          strokeWidth: 1.5,
                          strokeColor: Colors.white)),
                  belowBarData: BarAreaData(
                      show: true, color: kGreen700.withOpacity(0.06))),

            // LINE 2: Regression — blue dashed
            if (regSpotsReal.length >= 2)
              LineChartBarData(
                  spots: regSpotsReal,
                  isCurved: false,
                  color: const Color(0xFF1565C0),
                  barWidth: 1.5,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  dashArray: [6, 4]),

            // LINE 3: Predicted — orange dotted
            if (predSpots.length >= 2)
              LineChartBarData(
                  spots: predSpots,
                  isCurved: true,
                  curveSmoothness: 0.2,
                  color: Colors.orange[700]!,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, idx) {
                        final isBest = spot.x.toInt() == bestX.toInt();
                        return FlDotCirclePainter(
                            radius: isBest ? 6 : 3.5,
                            color: isBest
                                ? Colors.orange[700]!
                                : Colors.orange[400]!,
                            strokeWidth: isBest ? 2 : 1.5,
                            strokeColor: Colors.white);
                      }),
                  dashArray: [5, 3]),
          ],

          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: Colors.grey[800]!,
                getTooltipItems: (spots) => spots.map((s) {
                      final x = s.x.toInt();
                      final isHist = x <= offset && histSpots.isNotEmpty;
                      String label;
                      if (isHist) {
                        label = 'Historical\n₹${s.y.toStringAsFixed(2)}/kg';
                      } else {
                        final d = x - offset;
                        if (d >= 0 && d < r.days.length) {
                          final day = r.days[d];
                          label = '${day.label}\n'
                              '₹${s.y.toStringAsFixed(2)}/kg\n'
                              '₹${day.total.toStringAsFixed(0)} total';
                        } else {
                          label = 'Regression\n₹${s.y.toStringAsFixed(2)}';
                        }
                      }
                      return LineTooltipItem(label,
                          const TextStyle(color: Colors.white, fontSize: 11));
                    }).toList()),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  WIDGETS
  // ─────────────────────────────────────────────────────────────────

  Widget _bigAnswer() {
    final r = _result!;
    final sellNow = r.bestDay == 0;
    final color = sellNow ? kGreen700 : Colors.orange[700]!;
    return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: 2)),
        child: Column(children: [
          Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18))),
              child: Column(children: [
                Text(
                    sellNow
                        ? '✅ இன்னைக்கே விக்கணும்!'
                        : '⏳ ${r.bestDay} நாள் காத்திரு!',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(sellNow ? 'Sell TODAY!' : 'Wait ${r.bestDay} days!',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 13)),
              ])),
          Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Text(r.tamilAdvice,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: color,
                        height: 1.5)),
                const SizedBox(height: 5),
                Text(r.englishAdvice,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic)),
              ])),
        ]));
  }

  Widget _sourceBadge() {
    final r = _result!;
    final isReal = r.source == DataSource.realAPI;
    final color = isReal ? kGreen700 : Colors.orange[700]!;
    final bgColor = isReal ? kGreen100 : const Color(0xFFFFF8E1);

    return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(isReal ? '✅' : '🤖', style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
                child: Text(isReal ? 'Real Government Data' : 'AI Analysis',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: color))),
          ]),
          const SizedBox(height: 4),
          Text(r.analysisNote,
              style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          if (!isReal) ...[
            const SizedBox(height: 4),
            Text(
                '💡 data.gov.in-ல் $_city data இல்லை → '
                'Groq AI Tamil Nadu seasonal patterns analyse பண்ணது',
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange[800]!,
                    fontStyle: FontStyle.italic)),
          ],
        ]));
  }

  Widget _mlBadge() {
    final r = _result!;
    final r2 = (r.rSquared * 100).toStringAsFixed(0);
    return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: const Color(0xFFEDE7F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.withOpacity(0.3))),
        child: Row(children: [
          const Text('🧠', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(
                  r.source == DataSource.realAPI
                      ? 'Linear Regression (y=mx+b) on real data  •  '
                          'Slope: ${r.slope >= 0 ? "📈" : "📉"} '
                          '${r.slope.toStringAsFixed(2)} ₹/day  •  '
                          'R²=$r2%'
                      : 'Groq LLaMA 3.3 70B  •  '
                          'Tamil Nadu seasonal analysis  •  '
                          '${DateTime.now().month == 1 ? "Jan" : DateTime.now().month == 2 ? "Feb" : DateTime.now().month == 3 ? "Mar" : DateTime.now().month == 4 ? "Apr" : DateTime.now().month == 5 ? "May" : DateTime.now().month == 6 ? "Jun" : DateTime.now().month == 7 ? "Jul" : DateTime.now().month == 8 ? "Aug" : DateTime.now().month == 9 ? "Sep" : DateTime.now().month == 10 ? "Oct" : DateTime.now().month == 11 ? "Nov" : "Dec"} patterns',
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF6A1B9A)))),
        ]));
  }

  Widget _summaryCard() {
    final r = _result!;
    return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ]),
        child: Row(children: [
          Text(kCropEmojis[r.crop]!, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('${r.crop} • ${r.qty.toInt()} kg',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text('📍 ${r.city}  •  ${r.marketName}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('₹${r.todayPriceKg.toStringAsFixed(2)}/kg',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: kGreen700)),
            const Text('இன்னைக்கு',
                style: TextStyle(fontSize: 9, color: Colors.grey)),
            Text('₹${(r.todayPriceKg * r.qty).toStringAsFixed(0)} total',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: kGreen700)),
          ]),
        ]));
  }

  Widget _chartCard() {
    return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('📈', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            const Text('Price Chart',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ]),
          const SizedBox(height: 6),
          // Legend
          Wrap(spacing: 12, children: [
            _legendItem(kGreen700, '━━', 'Real data'),
            _legendItem(const Color(0xFF1565C0), '╌╌', 'Regression line'),
            _legendItem(Colors.orange[700]!, '┅┅', 'ML Prediction'),
          ]),
          const SizedBox(height: 10),
          _lineChart(),
        ]));
  }

  Widget _legendItem(Color c, String dash, String label) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Text(dash,
            style:
                TextStyle(color: c, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ]);

  Widget _dayTable() {
    final r = _result!;
    return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ]),
        child: Column(children: [
          const Padding(
              padding: EdgeInsets.fromLTRB(14, 14, 14, 8),
              child: Row(children: [
                Text('💰', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text('எந்த நாள் விற்றால் எவ்வளவு?',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ])),
          const Divider(height: 1),
          Container(
              color: Colors.grey[50],
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              child: Row(children: [
                const SizedBox(width: 28),
                const SizedBox(width: 6),
                Expanded(
                    child: Text('நாள்',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold))),
                SizedBox(
                    width: 68,
                    child: Text('₹/kg',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold))),
                SizedBox(
                    width: 90,
                    child: Text('மொத்தம்',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold))),
              ])),
          const Divider(height: 1),
          ...r.days.map((d) {
            final bg = d.isBest
                ? kGreen700.withOpacity(0.07)
                : !d.safe
                    ? Colors.red[50]!
                    : Colors.transparent;
            final tc = d.isBest
                ? kGreen700
                : !d.safe
                    ? Colors.red[700]!
                    : Colors.grey[800]!;
            final emoji = !d.safe
                ? '⚠️'
                : d.isBest
                    ? '⭐'
                    : d.vsToday > 50
                        ? '📈'
                        : d.vsToday < -50
                            ? '📉'
                            : '➡️';

            return Container(
                padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
                decoration: BoxDecoration(
                    color: bg,
                    border:
                        Border(bottom: BorderSide(color: Colors.grey[100]!))),
                child: Row(children: [
                  SizedBox(
                      width: 28,
                      child: Text(emoji, style: const TextStyle(fontSize: 18))),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(d.label,
                            style: TextStyle(
                                fontWeight: d.isBest
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 13,
                                color: tc)),
                        if (d.isBest)
                          Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                  color: kGreen700,
                                  borderRadius: BorderRadius.circular(6)),
                              child: Text(langService.t('best_day'),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold)))
                        else if (!d.safe)
                          const Text('⚠️ கெட்டுவிடும்!',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold)),
                      ])),
                  SizedBox(
                      width: 68,
                      child: Text('₹${d.pricePerKg.toStringAsFixed(2)}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: tc))),
                  SizedBox(
                      width: 90,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('₹${d.total.toStringAsFixed(0)}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: tc)),
                            if (d.day > 0 && d.safe)
                              Text(
                                  d.vsToday >= 0
                                      ? '+₹${d.vsToday.toStringAsFixed(0)}'
                                      : '-₹${d.vsToday.abs().toStringAsFixed(0)}',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: d.vsToday >= 0
                                          ? kGreen700
                                          : Colors.red[500]!)),
                          ])),
                ]));
          }),
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(14))),
              child: Row(children: [
                const Text('ℹ️', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(
                        'மொத்தம் = ${r.qty.toInt()} kg × ₹/kg. '
                        '"+" = இன்னைக்கு விட அதிகம்.',
                        style:
                            TextStyle(fontSize: 10, color: Colors.grey[500]))),
              ])),
        ]));
  }

  // ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kGreen700,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(children: [
          const SizedBox(width: 4),
          Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/app_logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                          child: Text('🌾', style: TextStyle(fontSize: 18)))))),
          SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('VILAI',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 3)),
            Text(langService.t('sell_or_wait'),
                style: TextStyle(fontSize: 10, color: Color(0xFFA5D6A7))),
          ]),
        ]),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // City
                    Text(langService.t('where_are_you'),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 10),
                    SizedBox(
                        height: 42,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: kCities.length,
                            itemBuilder: (_, i) {
                              final c = kCities[i];
                              final sel = _city == c;
                              return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                      onTap: () => setState(() {
                                            _city = c;
                                            _result = null;
                                          }),
                                      child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 150),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                              color: sel
                                                  ? kGreen700
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: sel
                                                      ? kGreen700
                                                      : Colors.grey.shade300)),
                                          child: Text(c,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  color: sel
                                                      ? Colors.white
                                                      : Colors.grey[700])))));
                            })),

                    SizedBox(height: 16),

                    // Crop
                    Text(langService.t('which_crop'),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 10),
                    Row(
                        children: kCrops.map((c) {
                      final sel = _crop == c;
                      return Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                  onTap: () => setState(() {
                                        _crop = c;
                                        _result = null;
                                      }),
                                  child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 150),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                          color: sel ? kGreen700 : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: sel
                                                  ? kGreen700
                                                  : Colors.grey.shade300),
                                          boxShadow: sel
                                              ? [
                                                  BoxShadow(
                                                      color: kGreen700
                                                          .withOpacity(0.3),
                                                      blurRadius: 5)
                                                ]
                                              : []),
                                      child: Column(children: [
                                        Text(kCropEmojis[c]!,
                                            style:
                                                const TextStyle(fontSize: 24)),
                                        SizedBox(height: 3),
                                        Text(c,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: sel
                                                    ? Colors.white
                                                    : Colors.grey[700])),
                                      ])))));
                    }).toList()),

                    SizedBox(height: 16),

                    // Quantity
                    Text(langService.t('how_many_kg'),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 10),
                    Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [50, 100, 200, 500, 1000].map((q) {
                          final sel = _qty == q.toDouble();
                          return GestureDetector(
                              onTap: () => setState(() {
                                    _qty = q.toDouble();
                                    _result = null;
                                  }),
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                      color: sel ? kGreen700 : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: sel
                                              ? kGreen700
                                              : Colors.grey.shade300)),
                                  child: Text('$q kg',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: sel
                                              ? Colors.white
                                              : Colors.grey[700]))));
                        }).toList()),
                    Row(children: [
                      const Text('50',
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Expanded(
                          child: Slider(
                              value: _qty,
                              min: 50,
                              max: 2000,
                              divisions: 39,
                              activeColor: kGreen700,
                              label: '${_qty.toInt()} kg',
                              onChanged: (v) => setState(() {
                                    _qty = v;
                                    _result = null;
                                  }))),
                      const Text('2000',
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ]),
                    Center(
                        child: Text('${_qty.toInt()} kg',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: kGreen700))),

                    SizedBox(height: 16),

                    // Days harvested
                    Row(children: [
                      Text(langService.t('days_since'),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('$_daysHarvested நாள் முன்பு',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: kGreen700)),
                    ]),
                    Slider(
                        value: _daysHarvested.toDouble(),
                        min: 0,
                        max: (kShelf[_crop]! - 1).toDouble(),
                        divisions: kShelf[_crop]! - 1,
                        activeColor: _daysHarvested > kShelf[_crop]! * 0.6
                            ? Colors.red
                            : kGreen700,
                        label: '$_daysHarvested நாள்',
                        onChanged: (v) => setState(() {
                              _daysHarvested = v.toInt();
                              _result = null;
                            })),
                    Center(
                        child: Text(
                            _daysHarvested == 0
                                ? '🌱 இன்னைக்கே அறுவடை'
                                : '⏱️ ${kShelf[_crop]! - _daysHarvested} நாள் மட்டுமே safe',
                            style: TextStyle(
                                fontSize: 12,
                                color: _daysHarvested > kShelf[_crop]! * 0.6
                                    ? Colors.red[700]
                                    : Colors.grey[600]))),
                  ])),
          const SizedBox(height: 14),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                  onPressed: _loading ? null : _analyze,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _loading ? Colors.grey : kGreen700,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 62),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      elevation: 4,
                      shadowColor: kGreen700.withOpacity(0.4)),
                  child: _loading
                      ? Column(mainAxisSize: MainAxisSize.min, children: [
                          const SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5)),
                          const SizedBox(height: 6),
                          Text(_status, style: const TextStyle(fontSize: 12)),
                        ])
                      : Column(mainAxisSize: MainAxisSize.min, children: [
                          Text('$_city-ல் $_crop எப்போ விற்றால் best?',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const Text('Real data + ML Line Chart',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.white70)),
                        ]))),
          const SizedBox(height: 16),
          if (_result != null) ...[
            _bigAnswer(),
            _sourceBadge(),
            _mlBadge(),
            _summaryCard(),
            _chartCard(),
            _dayTable(),
          ],
          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}
