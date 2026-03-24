// ─────────────────────────────────────────────────────────────────────────────
//  screens/language_screen.dart
//  Beautiful language selection screen
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/language_service.dart';

class LanguageScreen extends StatefulWidget {
  final bool fromOnboarding; // true = first time, show Continue button
  const LanguageScreen({super.key, this.fromOnboarding = false});
  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selected = langService.currentCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: widget.fromOnboarding ? null : AppBar(
        backgroundColor: kGreen700,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(langService.t('select_language'),
          style: const TextStyle(
            fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(children: [

          // ── Header ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kGreen900, kGreen700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
            child: Column(children: [
              // Logo
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10, offset: const Offset(0, 4))]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset('assets/app_logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Text('🌾',
                        style: TextStyle(fontSize: 36)))))),
              const SizedBox(height: 12),
              const Text('VILAI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 5)),
              const SizedBox(height: 6),
              const Text('Choose your language / மொழி தேர்வு',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13)),
            ])),

          const SizedBox(height: 20),

          // ── Language options ─────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: kLanguages.length,
              itemBuilder: (_, i) {
                final lang = kLanguages[i];
                final isSel = _selected == lang.code;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selected = lang.code);
                    langService.setLanguage(lang.code);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSel
                        ? kGreen700.withOpacity(0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSel ? kGreen700 : Colors.grey.shade200,
                        width: isSel ? 2 : 1),
                      boxShadow: isSel ? [BoxShadow(
                        color: kGreen700.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3))] : [BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2))]),
                    child: Row(children: [

                      // Language emoji/flag
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: isSel
                            ? kGreen700.withOpacity(0.12) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(14)),
                        child: Center(child: Text(lang.flag,
                          style: const TextStyle(fontSize: 26)))),
                      const SizedBox(width: 16),

                      // Language name
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(lang.nativeName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: isSel ? kGreen700 : Colors.grey[800])),
                        const SizedBox(height: 2),
                        Text(lang.name,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500])),
                      ])),

                      // Selected indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSel ? kGreen700 : Colors.grey[200],
                          border: Border.all(
                            color: isSel ? kGreen700 : Colors.grey.shade300,
                            width: 2)),
                        child: isSel
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 16)
                          : null),
                                        ]), // Row
                      ), // AnimatedContainer
                    ); // GestureDetector
              })),

          // ── Continue / Save button ───────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                langService.setLanguage(_selected);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen700,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: kGreen700.withOpacity(0.4)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                const Icon(Icons.check_circle_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  _selected == 'ta' ? 'சேமி & தொடர்'
                  : _selected == 'hi' ? 'सहेजें & जारी रखें'
                  : _selected == 'te' ? 'సేవ్ & కొనసాగించు'
                  : _selected == 'kn' ? 'ಉಳಿಸಿ & ಮುಂದುವರಿಸಿ'
                  : 'Save & Continue',
                  style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
              ])),
          ),
        ]),
      ),
    );
  }
}