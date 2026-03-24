// ─────────────────────────────────────────────────────────────────────────────
//  main.dart — Auth check + Role-based navigation (FIXED)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'constants.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/prediction_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/markets_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/price_alert_screen.dart';
import 'screens/farmer_listing_screen.dart';
import 'screens/buyer_screen.dart';
import 'services/auth_service.dart';
import 'services/language_service.dart';
import 'screens/language_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const FarmerApp());
}

// ─────────────────────────────────────────────────────────────────────────────
//  GLOBAL ALERT STATE
// ─────────────────────────────────────────────────────────────────────────────
class AlertState extends ChangeNotifier {
  final List<AlertNotification> _notifications = [];

  List<AlertNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get hasUnread => unreadCount > 0;

  void addNotification(AlertNotification n) {
    _notifications.insert(0, n);
    notifyListeners();
  }

  void markAllRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}

class AlertNotification {
  final String title;
  final String body;
  final String emoji;
  final DateTime time;
  bool isRead;

  AlertNotification({
    required this.title,
    required this.body,
    required this.emoji,
  })  : time = DateTime.now(),
        isRead = false;
}

final alertState = AlertState();

// ─────────────────────────────────────────────────────────────────────────────
//  APP ROOT
// ─────────────────────────────────────────────────────────────────────────────
class FarmerApp extends StatelessWidget {
  const FarmerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: langService,
      builder: (context, _) {
        return MaterialApp(
          key: ValueKey(langService.currentCode),
          title: 'VILAI — விலை',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: kGreen700),
            useMaterial3: true,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  APP ROOT — Auth check
// ─────────────────────────────────────────────────────────────────────────────
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  void _onAuthChange() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    authService.addListener(_onAuthChange);
  }

  @override
  void dispose() {
    authService.removeListener(_onAuthChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Auth state-க்கு based-ஆ screen show பண்ணும்
    if (!authService.isLoggedIn) {
      return const AuthScreen();
    }
    if (authService.isFarmer) {
      return const FarmerShell();
    }
    return const BuyerShell();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  NAV ITEM MODEL
// ─────────────────────────────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isHighlighted;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.isHighlighted = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  FARMER SHELL
// ─────────────────────────────────────────────────────────────────────────────
class FarmerShell extends StatefulWidget {
  const FarmerShell({super.key});

  @override
  State<FarmerShell> createState() => _FarmerShellState();
}

class _FarmerShellState extends State<FarmerShell> {
  int _idx = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    PredictionScreen(),
    ChatScreen(),
    MarketsScreen(),
    ProfileScreen(),
  ];

  List<_NavItem> get _navItems => [
        _NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: _nl('greeting')),
        _NavItem(
            icon: Icons.trending_up_outlined,
            activeIcon: Icons.trending_up,
            label: _nl('prices')),
        _NavItem(
            icon: Icons.smart_toy_outlined,
            activeIcon: Icons.smart_toy,
            label: _nl('chat'),
            isHighlighted: true),
        _NavItem(
            icon: Icons.store_outlined,
            activeIcon: Icons.store,
            label: _nl('markets')),
        _NavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: _nl('profile')),
      ];

  String _nl(String key) {
    const m = {
      'ta': {
        'greeting': 'முகப்பு',
        'prices': 'விலை',
        'chat': 'AI Bot',
        'markets': 'சந்தை',
        'profile': 'சுயவிவரம்'
      },
      'en': {
        'greeting': 'Home',
        'prices': 'Prices',
        'chat': 'AI Bot',
        'markets': 'Markets',
        'profile': 'Profile'
      },
      'hi': {
        'greeting': 'होम',
        'prices': 'कीमत',
        'chat': 'AI Bot',
        'markets': 'बाजार',
        'profile': 'प्रोफाइल'
      },
      'te': {
        'greeting': 'హోమ్',
        'prices': 'ధర',
        'chat': 'AI Bot',
        'markets': 'మార్కెట్',
        'profile': 'ప్రొఫైల్'
      },
      'kn': {
        'greeting': 'ಹೋಮ್',
        'prices': 'ಬೆಲೆ',
        'chat': 'AI Bot',
        'markets': 'ಮಾರ್ಕೆಟ್',
        'profile': 'ಪ್ರೊಫೈಲ್'
      },
    };
    return m[langService.currentCode]?[key] ?? m['en']![key]!;
  }

  static const List<String> _titles = [
    'Farmer Market Intelligence',
    'Price Prediction',
    'AI Farmer Assistant',
    'Nearby Markets',
    'My Profile',
  ];

  void _showNotifPanel(BuildContext context) {
    alertState.markAllRead();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AnimatedBuilder(
        animation: alertState,
        builder: (_, __) => _NotifPanel(
          notifications: alertState.notifications,
          onClear: () {
            alertState.clearAll();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('உங்கள் account-இல் இருந்து logout ஆவீர்களா?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authService.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser!;

    return Scaffold(
      appBar: _idx == 2
          ? null
          : AppBar(
              backgroundColor: kGreen700,
              foregroundColor: Colors.white,
              elevation: 0,
              titleSpacing: 0,
              title: Row(
                children: [
                  const SizedBox(width: 12),
                  Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 4)
                          ]),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset('assets/app_logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                  child: Text('🌾',
                                      style: TextStyle(fontSize: 18)))))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('VILAI',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 3)),
                        Text(
                            '📍 ${user.location.isNotEmpty ? user.location.split(',').first : _titles[_idx]}',
                            style: const TextStyle(
                                fontSize: 10, color: Color(0xFFA5D6A7))),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                // Notification bell
                AnimatedBuilder(
                  animation: alertState,
                  builder: (_, __) {
                    final count = alertState.unreadCount;
                    return GestureDetector(
                      onTap: () => _showNotifPanel(context),
                      child: Container(
                        margin: const EdgeInsets.only(right: 4),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                count > 0
                                    ? Icons.notifications_active_rounded
                                    : Icons.notifications_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            if (count > 0)
                              Positioned(
                                top: -3,
                                right: -3,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: kGreen700, width: 1.5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      count > 9 ? '9+' : '$count',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Price alert
                IconButton(
                  icon: const Icon(Icons.add_alert_outlined,
                      color: Colors.white70, size: 20),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PriceAlertScreen()),
                  ),
                ),
                // Sell crop
                IconButton(
                  icon: const Icon(Icons.upload_rounded,
                      color: Colors.white70, size: 20),
                  tooltip: 'Sell Crop',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FarmerListingScreen()),
                  ),
                ),
                // Logout
                IconButton(
                  icon: const Icon(Icons.logout_rounded,
                      color: Colors.white70, size: 20),
                  onPressed: () => _confirmLogout(context),
                ),
                const SizedBox(width: 4),
              ],
            ),
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: _buildFarmerNav(),
    );
  }

  Widget _buildFarmerNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: _navItems.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final sel = _idx == i;

              if (item.isHighlighted) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _idx = i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          margin: const EdgeInsets.only(bottom: 0),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [kGreen500, kGreen700],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: kGreen700.withOpacity(0.45),
                                blurRadius: 12,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            sel ? item.activeIcon : item.icon,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: sel ? kGreen700 : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _idx = i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 32,
                        decoration: BoxDecoration(
                          color: sel ? kGreen100 : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          sel ? item.activeIcon : item.icon,
                          color: sel ? kGreen700 : Colors.grey[400],
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                          color: sel ? kGreen700 : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  BUYER SHELL
// ─────────────────────────────────────────────────────────────────────────────
class BuyerShell extends StatefulWidget {
  const BuyerShell({super.key});

  @override
  State<BuyerShell> createState() => _BuyerShellState();
}

class _BuyerShellState extends State<BuyerShell> {
  int _idx = 0;

  final List<Widget> _screens = const [
    BuyerHomeScreen(),
    BuyerScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  List<_NavItem> get _navItems => [
        _NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: _nl('greeting')),
        _NavItem(
            icon: Icons.storefront_outlined,
            activeIcon: Icons.storefront,
            label: _nl('crops')),
        _NavItem(
            icon: Icons.smart_toy_outlined,
            activeIcon: Icons.smart_toy,
            label: _nl('chat'),
            isHighlighted: true),
        _NavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: _nl('profile')),
      ];

  String _nl(String key) {
    const m = {
      'ta': {
        'greeting': 'முகப்பு',
        'crops': 'பயிர்கள்',
        'chat': 'AI Bot',
        'profile': 'சுயவிவரம்'
      },
      'en': {
        'greeting': 'Home',
        'crops': 'Find Crops',
        'chat': 'AI Bot',
        'profile': 'Profile'
      },
      'hi': {
        'greeting': 'होम',
        'crops': 'फसलें',
        'chat': 'AI Bot',
        'profile': 'प्रोफाइल'
      },
      'te': {
        'greeting': 'హోమ్',
        'crops': 'పంటలు',
        'chat': 'AI Bot',
        'profile': 'ప్రొఫైల్'
      },
      'kn': {
        'greeting': 'ಹೋಮ್',
        'crops': 'ಬೆಳೆಗಳು',
        'chat': 'AI Bot',
        'profile': 'ಪ್ರೊಫೈಲ್'
      },
    };
    return m[langService.currentCode]?[key] ?? m['en']![key]!;
  }

  static const List<String> _titles = [
    'Fresh Crops Market',
    'Find Crops',
    'AI Assistant',
    'My Profile',
  ];

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('உங்கள் account-இல் இருந்து logout ஆவீர்களா?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authService.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser!;

    return Scaffold(
      appBar: _idx == 2
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              elevation: 0,
              titleSpacing: 0,
              title: Row(
                children: [
                  const SizedBox(width: 12),
                  Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 4)
                          ]),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset('assets/app_logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                  child: Text('🌾',
                                      style: TextStyle(fontSize: 18)))))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('VILAI',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 3)),
                        Text(
                            '🍽️ ${user.businessName ?? user.name}  •  ${_titles[_idx]}',
                            style: const TextStyle(
                                fontSize: 10, color: Color(0xFF90CAF9))),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                  onPressed: () => _confirmLogout(context),
                ),
              ],
            ),
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: _buildBuyerNav(),
    );
  }

  Widget _buildBuyerNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: _navItems.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final sel = _idx == i;

              if (item.isHighlighted) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _idx = i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          margin: const EdgeInsets.only(bottom: 0),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF42A5F5),
                                Color(0xFF1565C0),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF1565C0).withOpacity(0.45),
                                blurRadius: 12,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            sel ? item.activeIcon : item.icon,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: sel
                                ? const Color(0xFF1565C0)
                                : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _idx = i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 32,
                        decoration: BoxDecoration(
                          color: sel
                              ? const Color(0xFFE3F2FD)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          sel ? item.activeIcon : item.icon,
                          color:
                              sel ? const Color(0xFF1565C0) : Colors.grey[400],
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                          color:
                              sel ? const Color(0xFF1565C0) : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  BUYER HOME SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class BuyerHomeScreen extends StatelessWidget {
  const BuyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser!;

    return Scaffold(
      backgroundColor: kBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text('🍽️', style: TextStyle(fontSize: 26)),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${langService.t('greeting')}, ${user.name}!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user.businessType ?? 'Buyer',
                              style: const TextStyle(
                                color: Color(0xFF90CAF9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => authService.logout(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Direct from Farmers 🌾',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const Text(
                    'No middleman. Fresh. Affordable.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Find crops button
                  GestureDetector(
                    onTap: () {
                      final shell =
                          context.findAncestorStateOfType<_BuyerShellState>();
                      shell?.setState(() => shell._idx = 1);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1565C0).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Text('🛒', style: TextStyle(fontSize: 28)),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Browse Fresh Crops',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Farmers-இடம் directly buy பண்ணுங்கள்!\nCall or WhatsApp — instant contact!',
                                  style: TextStyle(
                                    color: Color(0xFF90CAF9),
                                    fontSize: 11,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              color: Colors.white70, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Stats row
                  Row(
                    children: [
                      _statCard(
                          '${globalListings.length}', 'Active\nListings', '📦'),
                      const SizedBox(width: 10),
                      _statCard('5', 'Crops\nAvailable', '🌾'),
                      const SizedBox(width: 10),
                      _statCard('0%', 'Middleman\nCost', '✅'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Recent listings
                  if (globalListings.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '🆕 Latest Listings',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...globalListings.take(2).map(
                          (l) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(kCropEmojis[l.crop]!,
                                    style: const TextStyle(fontSize: 28)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${l.crop} — ${l.quantity.toInt()} kg',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '📍 ${l.location} • ₹${l.pricePerKg.toInt()}/kg',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1565C0),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('📞 Call',
                                      style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String val, String label, String emoji) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(val,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  NOTIFICATION PANEL
// ─────────────────────────────────────────────────────────────────────────────
class _NotifPanel extends StatelessWidget {
  final List<AlertNotification> notifications;
  final VoidCallback onClear;

  const _NotifPanel({
    required this.notifications,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
            child: Row(
              children: [
                const Text('🔔', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                const Text(
                  'Notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (notifications.isNotEmpty)
                  TextButton(
                    onPressed: onClear,
                    child: const Text(
                      'Clear All',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: notifications.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🔕', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 12),
                        Text(
                          'No notifications yet',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: notifications.length,
                    itemBuilder: (_, i) {
                      final n = notifications[i];
                      final time =
                          '${n.time.hour.toString().padLeft(2, '0')}:${n.time.minute.toString().padLeft(2, '0')}';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: kGreen50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: kGreen700.withOpacity(0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: kGreen100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(n.emoji,
                                    style: const TextStyle(fontSize: 22)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    n.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    n.body,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
