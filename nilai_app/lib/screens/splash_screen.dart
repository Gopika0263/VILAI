// ─────────────────────────────────────────────────────────────────────────────
//  screens/splash_screen.dart  —  VILAI Welcome Screen
//  ┌──────────────────────────────┐
//  │  [Logo]  VILAI      🟢      │  ← Top bar
//  ├──────────────────────────────┤
//  │                              │
//  │   [Farmer with money image]  │  ← Middle (big)
//  │                              │
//  ├──────────────────────────────┤
//  │  "உழைக்கும் கைகளுக்கு..."  │  ← Quote
//  │  pills                       │  ← Feature pills
//  │  [ Get Started → ]           │  ← Button
//  │  Live demand  •  AI          │  ← Tagline
//  └──────────────────────────────┘
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';
import 'auth_screen.dart';
import '../main.dart' show AppRoot;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _bottomSlide;

  @override
  void initState() {
    super.initState();

    // Hide status bar for full immersive look
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));

    _mainCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn)));

    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut)));

    _bottomSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _mainCtrl,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut)));

    Future.delayed(
        const Duration(milliseconds: 150), () => _mainCtrl.forward());
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    super.dispose();
  }

  void _goToAuth() {
    Navigator.pushReplacement(
        context,
        PageRouteBuilder(
            pageBuilder: (_, anim, __) =>
                FadeTransition(opacity: anim, child: const AppRoot()),
            transitionDuration: const Duration(milliseconds: 450)));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF081A08),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            // ── TOP BAR — Logo + VILAI + 🟢 LIVE ───────────────────────
            Container(
              color: const Color(0xFF081A08),
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 20,
                  right: 20,
                  bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App logo circle
                  Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                                color: kGreen700.withOpacity(0.5),
                                blurRadius: 12,
                                offset: const Offset(0, 3))
                          ]),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.asset('assets/app_logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                  child: Text('🌾',
                                      style: TextStyle(fontSize: 24)))))),

                  const SizedBox(width: 12),

                  // VILAI text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('VILAI',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 5,
                              height: 1.1)),
                      Text('விலை',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 11,
                              letterSpacing: 3)),
                    ],
                  ),

                  const Spacer(),

                  // 🟢 LIVE badge
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: const Color(0xFF1B5E20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFF69F0AE).withOpacity(0.5),
                              width: 1)),
                      child: const Row(children: [
                        Icon(Icons.circle, color: Color(0xFF69F0AE), size: 7),
                        SizedBox(width: 5),
                        Text('LIVE',
                            style: TextStyle(
                                color: Color(0xFF69F0AE),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5)),
                      ])),
                ],
              ),
            ),

            // ── MIDDLE — Farmer image (big, fills space) ────────────────
            Expanded(
              flex: 5,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 24,
                            offset: const Offset(0, 8))
                      ]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Farmer image
                        Image.asset('assets/farmer_hero.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (_, __, ___) => Container(
                                decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [kGreen900, kGreen700],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter)),
                                child: const Center(
                                    child: Text('👨‍🌾',
                                        style: TextStyle(fontSize: 80))))),

                        // Bottom gradient fade into dark
                        Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 70,
                            child: Container(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                  Colors.transparent,
                                  const Color(0xFF081A08).withOpacity(0.85)
                                ])))),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── BOTTOM — Quote + Pills + Button + Tagline ───────────────
            SlideTransition(
              position: _bottomSlide,
              child: Container(
                color: const Color(0xFF081A08),
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quote
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('"',
                            style: TextStyle(
                                color: kGreen500,
                                fontSize: 36,
                                height: 0.85,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        const Expanded(
                            child: Text(
                                'உழைக்கும் கைகளுக்கு\nசரியான விலை கிடைக்கட்டும்',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    height: 1.5))),
                      ],
                    ),
                    const SizedBox(height: 14),


                    // Get Started button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _goToAuth,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC107),
                            foregroundColor: const Color(0xFF1A1A1A),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 10,
                            shadowColor:
                                const Color(0xFFFFC107).withOpacity(0.45)),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Get Started',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Bottom tagline
                    Center(
                      child: Text('Live Demand  •  AI Assistant',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 11,
                              letterSpacing: 0.8)),
                    ),

                    // Safe area bottom
                    SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.13))),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500)),
      );
}
