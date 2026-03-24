// ─────────────────────────────────────────────────────────────────────────────
//  screens/profile_screen.dart
//  Farmer → Sell Crop button only
//  Buyer  → Find Fresh Crops button only
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/language_service.dart';
import 'language_screen.dart';
import '../services/auth_service.dart';
import 'farmer_listing_screen.dart';
import 'buyer_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    final isFarmer = authService.isFarmer;

    return Scaffold(
      backgroundColor: kBg,
      body: SingleChildScrollView(
        child: Column(children: [
          // ── Profile header ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isFarmer
                    ? [kGreen700, kGreen900]
                    : [const Color(0xFF1565C0), const Color(0xFF0D47A1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(children: [
              // Avatar
              Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.white, width: 3)),
                  child: Center(
                      child: Text(isFarmer ? '👨‍🌾' : '🍽️',
                          style: const TextStyle(fontSize: 40)))),
              const SizedBox(height: 12),

              Text(user?.name ?? 'Profile',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text(
                  isFarmer
                      ? (user?.location ?? 'Tamil Nadu')
                      : (user?.businessType ?? 'Buyer'),
                  style:
                      const TextStyle(color: Color(0xFFA5D6A7), fontSize: 13)),
              const SizedBox(height: 4),
              // Role badge
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                      isFarmer ? '👨‍🌾 Farmer Account' : '🍽️ Buyer Account',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold))),
              const SizedBox(height: 16),

              // Stats row
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                if (isFarmer) ...[
                  _stat('${user?.crops.length ?? 0}', 'My Crops'),
                  Container(width: 1, height: 30, color: Colors.white24),
                  _stat('12', 'Markets'),
                  Container(width: 1, height: 30, color: Colors.white24),
                  _stat('₹2.4L', 'Est. Profit'),
                ] else ...[
                  _stat(user?.businessName ?? '-', 'Business'),
                  Container(width: 1, height: 30, color: Colors.white24),
                  _stat(user?.businessType ?? '-', 'Type'),
                  Container(width: 1, height: 30, color: Colors.white24),
                  _stat('0%', 'Middleman'),
                ],
              ]),
            ]),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: [
              // ── FARMER: Sell Crop button only ──────────────────────────
              if (isFarmer) ...[
                const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('🌾 Marketplace',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold))),
                SizedBox(height: 10),

                // Sell Your Crop
                _marketplaceButton(
                  context: context,
                  emoji: '📤',
                  title: langService.t('sell_crop'),
                  subtitle:
                      'Post listing → Restaurants contact you!\nNo middleman — full profit yours! 💰',
                  gradientColors: [kGreen700, kGreen900],
                  glowColor: kGreen700,
                  subtitleColor: const Color(0xFFA5D6A7),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const FarmerListingScreen())),
                ),
                const SizedBox(height: 20),
              ],

              // ── BUYER: Find Fresh Crops button only ────────────────────
              if (!isFarmer) ...[
                const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('🛒 Marketplace',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold))),
                SizedBox(height: 10),

                // Find Fresh Crops
                _marketplaceButton(
                  context: context,
                  emoji: '🍽️',
                  title: langService.t('find_crops'),
                  subtitle: 'Browse farmers nearby\nCall/WhatsApp directly!',
                  gradientColors: [
                    const Color(0xFF1565C0),
                    const Color(0xFF0D47A1)
                  ],
                  glowColor: const Color(0xFF1565C0),
                  subtitleColor: const Color(0xFF90CAF9),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const BuyerScreen())),
                ),
                const SizedBox(height: 20),
              ],

              // ── Farm / Business details ────────────────────────────────
              if (isFarmer) ...[
                _section('🌾 Farm Details', [
                  _item(
                      Icons.grass,
                      'My Crops',
                      user?.crops.isEmpty ?? true
                          ? 'Not set'
                          : user!.crops.join(', ')),
                  _item(Icons.location_on, 'My Location',
                      user?.location ?? 'Not set'),
                  _item(
                      Icons.agriculture,
                      'Farm Size',
                      user?.farmSize?.isEmpty ?? true
                          ? 'Not set'
                          : user!.farmSize!),
                ]),
              ] else ...[
                _section('🍽️ Business Details', [
                  _item(Icons.storefront, 'Business Name',
                      user?.businessName ?? 'Not set'),
                  _item(Icons.category, 'Business Type',
                      user?.businessType ?? 'Not set'),
                  _item(Icons.location_on, 'Location',
                      user?.location ?? 'Not set'),
                ]),
              ],
              const SizedBox(height: 12),

              // ── App Settings ───────────────────────────────────────────
              _section('⚙️ App Settings', [
                _langItem(context),
                _item(Icons.notifications, 'Price Alerts', 'Enabled'),
                _item(Icons.wb_sunny, 'Weather Alerts', 'Enabled'),
              ]),
              const SizedBox(height: 12),

              // ── About ──────────────────────────────────────────────────
              _section('ℹ️ About App', [
                _item(Icons.info_outline, 'App Version',
                    '1.0.0 — Hackathon Build'),
                _item(Icons.code, 'Built With',
                    'Flutter + Groq AI + OpenWeather'),
                _item(
                    Icons.star, 'Problem', 'Farmer Market Price Intelligence'),
              ]),
              SizedBox(height: 12),

              // ── Logout button ──────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout_rounded, color: Colors.red),
                  label: Text(langService.t('logout'),
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                ),
              ),
              const SizedBox(height: 16),

              // ── Mission statement ──────────────────────────────────────
              Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: kGreen100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kGreen700.withOpacity(0.3))),
                  child: const Row(children: [
                    Text('🌾', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('Farmer Market Price Intelligence',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: kGreen700)),
                          SizedBox(height: 4),
                          Text(
                              'Helping farmers & buyers connect directly '
                              'with AI-powered market intelligence.',
                              style: TextStyle(
                                  fontSize: 12, color: kGreen700, height: 1.4)),
                        ])),
                  ])),
              const SizedBox(height: 24),
            ]),
          ),
        ]),
      ),
    );
  }

  // ── Logout confirm ──────────────────────────────────────────────────────
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout?'),
        content: const Text('உங்கள் account-இல் இருந்து logout ஆவீர்களா?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                authService.logout();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: Text(langService.t('logout'))),
        ],
      ),
    );
  }

  // ── Marketplace button ────────────────────────────────────────────────────
  Widget _marketplaceButton({
    required BuildContext context,
    required String emoji,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required Color glowColor,
    required Color subtitleColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: glowColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3))
            ]),
        child: Row(children: [
          Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12)),
              child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 24)))),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: TextStyle(
                        color: subtitleColor, fontSize: 11, height: 1.4)),
              ])),
          const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
        ]),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  static Widget _stat(String val, String label) => Column(children: [
        Text(val,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis),
        Text(label,
            style: const TextStyle(color: Color(0xFFA5D6A7), fontSize: 10)),
      ]);

  static Widget _section(String title, List<Widget> items) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF424242))),
        const SizedBox(height: 8),
        Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ]),
            child: Column(children: items)),
      ]);

  static Widget _item(IconData icon, String title, String subtitle) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: kGreen100, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: kGreen700, size: 18)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ])),
        Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[400]),
      ]));

  // ── Language item — tappable ───────────────────────────────────────────────
  Widget _langItem(BuildContext context) => GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const LanguageScreen())),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: kGreen100, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.language, color: kGreen700, size: 18)),
            SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(langService.t('language'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(langService.currentLanguage.nativeName,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ])),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: kGreen100, borderRadius: BorderRadius.circular(8)),
                child: Text(
                    langService.currentLanguage.flag +
                        ' ' +
                        langService.currentLanguage.nativeName,
                    style: const TextStyle(
                        fontSize: 11,
                        color: kGreen700,
                        fontWeight: FontWeight.bold))),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[400]),
          ])));
}
