// ─────────────────────────────────────────────────────────────────────────────
//  screens/home_screen.dart
//  - Language selector at top (5 languages)
//  - Full app text from langService.t()
//  - Selecting language → whole app changes instantly
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/auth_service.dart';
import '../services/weather_service.dart';
import '../services/language_service.dart';
import 'prediction_screen.dart';
import 'chat_screen.dart';
import 'markets_screen.dart';
import 'schemes_screen.dart';
import 'loan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WeatherResult? _weather;
  bool _weatherLoading = true;
  String? _weatherError;

  @override
  void initState() {
    super.initState();
    // Rebuild when language changes
    langService.addListener(_onLangChange);
    _loadWeather();
  }

  @override
  void dispose() {
    langService.removeListener(_onLangChange);
    super.dispose();
  }

  void _onLangChange() {
    if (mounted) setState(() {});
  }

  Future<void> _loadWeather() async {
    final user = authService.currentUser;
    if (user == null || user.location.isEmpty) {
      setState(() {
        _weatherLoading = false;
        _weatherError = 'no_location';
      });
      return;
    }
    final city = user.location.split(',').first.trim();
    try {
      final w = await WeatherService.getWeather(city);
      if (mounted)
        setState(() {
          _weather = w;
          _weatherLoading = false;
        });
    } catch (_) {
      if (mounted)
        setState(() {
          _weatherLoading = false;
          _weatherError = 'error';
        });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    final city = user?.location.split(',').first.trim() ?? '';
    final L = langService.t; // shorthand for translation

    return Scaffold(
      backgroundColor: kBg,
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 12),

          // ── LANGUAGE SELECTOR ─────────────────────────────────────
          _languageSelector(),

          const SizedBox(height: 12),

          // ── WEATHER CARD ──────────────────────────────────────────
          _buildWeatherCard(city, L),

          // ── FEATURE CARDS ─────────────────────────────────────────
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(L('what_to_do'),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    // Price Prediction
                    _featureCard(
                        context: context,
                        emoji: '📈',
                        title: L('price_prediction'),
                        subtitle: L('price_pred_sub'),
                        bg: kGreen100,
                        accent: kGreen700,
                        onTap: () => _nav(context, const PredictionScreen())),
                    const SizedBox(height: 10),

                    // AI Chatbot
                    _featureCard(
                        context: context,
                        emoji: '🤖',
                        title: L('ai_chatbot'),
                        subtitle: L('ai_chatbot_sub'),
                        bg: const Color(0xFFE8EAF6),
                        accent: const Color(0xFF3949AB),
                        onTap: () => _nav(context, const ChatScreen())),
                    const SizedBox(height: 10),

                    // Markets
                    _featureCard(
                        context: context,
                        emoji: '🏪',
                        title: L('markets'),
                        subtitle: L('markets_sub'),
                        bg: const Color(0xFFFFF8E1),
                        accent: const Color(0xFFF57F17),
                        onTap: () => _nav(context, const MarketsScreen())),
                    const SizedBox(height: 10),

                    // Govt Schemes
                    _govCard(context, L),
                    const SizedBox(height: 10),

                    // Loans
                    _loanCard(context, L),
                    const SizedBox(height: 24),
                  ])),
        ]),
      ),
    );
  }

  // ── Language selector ─────────────────────────────────────────────────────
  Widget _languageSelector() {
    return Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.language_rounded, size: 16, color: kGreen700),
            SizedBox(width: 6),
            Text(langService.t('select_language'),
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: kGreen700)),
          ]),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: kLanguages.map((lang) {
              final isSel = langService.currentCode == lang.code;
              return GestureDetector(
                  onTap: () {
                    langService.setLanguage(lang.code);
                    // setState already called via listener
                  },
                  child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                          color: isSel ? kGreen700 : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: isSel ? kGreen700 : Colors.grey.shade300,
                              width: isSel ? 0 : 1),
                          boxShadow: isSel
                              ? [
                                  BoxShadow(
                                      color: kGreen700.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2))
                                ]
                              : []),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(lang.flag, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(lang.nativeName,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSel ? Colors.white : Colors.grey[700])),
                      ])));
            }).toList()),
          ),
        ]));
  }

  // ── Weather card ──────────────────────────────────────────────────────────
  Widget _buildWeatherCard(String city, String Function(String) L) {
    if (_weatherLoading) {
      return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          height: 120,
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20)),
          child: Center(
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white)),
            const SizedBox(width: 12),
            Text(
                city.isEmpty
                    ? L('weather_loading')
                    : '$city ${L('weather_loading')}',
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ])));
    }

    if (_weatherError == 'no_location') {
      return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            const Text('📍', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(L('no_location'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 3),
                  Text(L('no_location_msg'),
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                ])),
          ]));
    }

    if (_weatherError != null || _weather == null) {
      return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF455A64), Color(0xFF607D8B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            const Text('🌤️', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(city,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  Text(L('weather_error'),
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                ])),
            IconButton(
                onPressed: () {
                  setState(() {
                    _weatherLoading = true;
                    _weatherError = null;
                  });
                  _loadWeather();
                },
                icon: const Icon(Icons.refresh_rounded,
                    color: Colors.white70, size: 22)),
          ]));
    }

    final w = _weather!;
    final isRainy = w.isRainy;

    // ── Beautiful Blue Weather Card ───────────────────────────────
    return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(24), boxShadow: [
          BoxShadow(
              color: const Color(0xFF1565C0).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6)),
          BoxShadow(
              color: const Color(0xFF42A5F5).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ]),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: isRainy
                            ? [
                                const Color(0xFF1A237E),
                                const Color(0xFF283593),
                                const Color(0xFF3949AB)
                              ]
                            : [
                                const Color(0xFF0D47A1),
                                const Color(0xFF1565C0),
                                const Color(0xFF1976D2)
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight)),
                child: Stack(children: [
                  // Decorative circles
                  Positioned(
                      top: -30,
                      right: -20,
                      child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05)))),
                  Positioned(
                      bottom: -40,
                      left: -30,
                      child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.04)))),

                  // Content
                  Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // City + refresh
                            Row(children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 13, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(city,
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                              const Spacer(),
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _weatherLoading = true;
                                      _weatherError = null;
                                    });
                                    _loadWeather();
                                  },
                                  child: const Icon(Icons.refresh_rounded,
                                      color: Colors.white38, size: 15)),
                            ]),
                            const SizedBox(height: 10),

                            // Emoji + temp + description
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(w.emoji,
                                      style: const TextStyle(fontSize: 50)),
                                  const SizedBox(width: 14),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${w.temp.toStringAsFixed(0)}',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 46,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      height: 1.0)),
                                              const Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 6),
                                                  child: Text('°C',
                                                      style: TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 18,
                                                          fontWeight: FontWeight
                                                              .bold))),
                                            ]),
                                        Text(w.description,
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12)),
                                      ])),
                                ]),
                            const SizedBox(height: 12),

                            // Humidity + temp pills
                            Row(children: [
                              _pill('💧 ${w.humidity}%'),
                              const SizedBox(width: 8),
                              _pill('🌡️ ${w.temp.toStringAsFixed(0)}°C'),
                            ]),
                            const SizedBox(height: 12),

                            // Advice box
                            Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: isRainy
                                        ? Colors.red.withOpacity(0.18)
                                        : Colors.white.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.15))),
                                child: Row(children: [
                                  Text(isRainy ? '⚠️' : '✅',
                                      style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(
                                            isRainy
                                                ? L('rain_warning')
                                                : L('good_weather'),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13)),
                                        SizedBox(height: 2),
                                        Text(
                                            isRainy
                                                ? L('rain_msg')
                                                : _weatherAdvice(w),
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 11,
                                                height: 1.4)),
                                      ])),
                                ])),
                          ])),
                ]))));
  }

  String _weatherAdvice(WeatherResult w) {
    if (w.temp > 38) {
      return langService.currentCode == 'ta'
          ? 'மிகவும் வெப்பம்! காலையில் சீக்கிரம் போங்க.'
          : langService.currentCode == 'hi'
              ? 'बहुत गर्म! सुबह जल्दी जाएं।'
              : 'Very hot! Travel early morning.';
    }
    if (w.humidity > 80) {
      return langService.currentCode == 'ta'
          ? 'அதிக ஈரப்பதம் — சீக்கிரம் விற்கவும்.'
          : langService.currentCode == 'hi'
              ? 'अधिक नमी — जल्दी बेचें।'
              : 'High humidity — sell crops quickly.';
    }
    return langService.currentCode == 'ta'
        ? 'நல்ல வானிலை — சந்தைக்கு பாதுகாப்பாக போகலாம்!'
        : langService.currentCode == 'hi'
            ? 'अच्छा मौसम — बाजार जाना सुरक्षित है!'
            : langService.currentCode == 'te'
                ? 'మంచి వాతావరణం — మార్కెట్‌కు వెళ్ళవచ్చు!'
                : langService.currentCode == 'kn'
                    ? 'ಒಳ್ಳೆಯ ಹವಾಮಾನ — ಮಾರುಕಟ್ಟೆಗೆ ಹೋಗಬಹುದು!'
                    : 'Good weather — safe to go to market!';
  }

  Widget _pill(String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)));

  void _nav(BuildContext ctx, Widget w) =>
      Navigator.push(ctx, MaterialPageRoute(builder: (_) => w));

  Widget _featureCard({
    required BuildContext context,
    required String emoji,
    required String title,
    required String subtitle,
    required Color bg,
    required Color accent,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
          onTap: onTap,
          child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ]),
              child: Row(children: [
                Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12)),
                    child: Center(
                        child:
                            Text(emoji, style: const TextStyle(fontSize: 24)))),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: accent)),
                      const SizedBox(height: 3),
                      Text(subtitle,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              height: 1.3)),
                    ])),
                Icon(Icons.arrow_forward_ios, size: 14, color: accent),
              ])));

  Widget _govCard(BuildContext ctx, String Function(String) L) =>
      GestureDetector(
          onTap: () => Navigator.push(
              ctx, MaterialPageRoute(builder: (_) => const SchemesScreen())),
          child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF1565C0).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ]),
              child: Row(children: [
                Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14)),
                    child: const Center(
                        child: Text('🏛️', style: TextStyle(fontSize: 28)))),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(L('govt_schemes'),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(L('govt_sub'),
                          style: const TextStyle(
                              color: Color(0xFFBBDEFB),
                              fontSize: 11,
                              height: 1.3)),
                    ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Text('12',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold))),
                  const SizedBox(height: 6),
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.white70, size: 14),
                ]),
              ])));

  Widget _loanCard(BuildContext ctx, String Function(String) L) =>
      GestureDetector(
          onTap: () => Navigator.push(
              ctx, MaterialPageRoute(builder: (_) => const LoanScreen())),
          child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFF57F17), Color(0xFFE65100)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFFF57F17).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ]),
              child: Row(children: [
                Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14)),
                    child: const Center(
                        child: Text('🏦', style: TextStyle(fontSize: 28)))),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(L('loans'),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(L('loans_sub'),
                          style: const TextStyle(
                              color: Color(0xFFFFE0B2),
                              fontSize: 11,
                              height: 1.3)),
                    ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Text('8',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold))),
                  const SizedBox(height: 6),
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.white70, size: 14),
                ]),
              ])));
}
