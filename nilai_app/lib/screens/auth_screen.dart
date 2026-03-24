
// ─────────────────────────────────────────────────────────────────────────────
//  screens/auth_screen.dart  —  VILAI Login / Register
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';
import '../services/language_service.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    langService.addListener(_onLang);
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    langService.removeListener(_onLang);
    _tabCtrl.dispose();
    super.dispose();
  }

  void _onLang() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── TOP — Farmer image + Logo + VILAI ─────────────────────────
          SizedBox(
            height: size.height * 0.38,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ✅ FIXED: assets/register.png
                Image.asset('assets/register.png', // ← correct path
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

                // Bottom dark gradient
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: size.height * 0.22,
                    child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.72),
                        ])))),

                // Top dark overlay
                Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                        ])))),

                // Logo + VILAI name at bottom of image
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: [
                      // App logo
                      Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3))
                              ]),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Image.asset(
                                  'assets/app_logo.png', // ✅ correct path
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                      child: Text('🌾',
                                          style: TextStyle(fontSize: 26)))))),
                      const SizedBox(width: 14),

                      // VILAI text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('VILAI',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 5,
                                  height: 1.0)),
                          Text('விலை  •  Price Intelligence',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 11,
                                  letterSpacing: 1.5)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── TAB BAR ────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(14)),
              child: TabBar(
                  controller: _tabCtrl,
                  indicator: BoxDecoration(
                      color: kGreen700,
                      borderRadius: BorderRadius.circular(12)),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[600],
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                  tabs: [
                    Tab(text: langService.t('login')),
                    Tab(text: langService.t('register')),
                  ]),
            ),
          ),

          // ── FORM CONTENT ───────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: const [
                _LoginForm(),
                _RegisterForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  LOGIN FORM
// ─────────────────────────────────────────────────────────────────────────────
class _LoginForm extends StatefulWidget {
  const _LoginForm();
  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _showPass = false;
  String? _error;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    final error =
        authService.login(_phoneCtrl.text.trim(), _passCtrl.text.trim());
    setState(() {
      _loading = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(langService.t('welcome_back'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(langService.t('login_subtitle'),
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 20),
            _field(
                controller: _phoneCtrl,
                label: 'Phone Number',
                hint: '9876543210',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 10,
                validator: (v) {
                  if (v!.isEmpty) return 'Phone required';
                  if (v.length != 10) return '10 digits enter பண்ணுங்கள்';
                  return null;
                }),
            const SizedBox(height: 14),
            _field(
                controller: _passCtrl,
                label: 'Password',
                hint: '••••••••',
                icon: Icons.lock_outline,
                obscureText: !_showPass,
                suffixIcon: IconButton(
                    icon: Icon(
                        _showPass ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey),
                    onPressed: () => setState(() => _showPass = !_showPass)),
                validator: (v) => v!.isEmpty ? 'Password required' : null),
            const SizedBox(height: 10),
            if (_error != null)
              Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200)),
                  child: Row(children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(_error!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 13))),
                  ])),
            const SizedBox(height: 20),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kGreen700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                        shadowColor: kGreen700.withOpacity(0.4)),
                    child: _loading
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Text(langService.t('login_btn'),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 18),
                              ]))),
            const SizedBox(height: 16),
            Center(
                child: Text('புதியவரா? Register tab-ல் join பண்ணுங்கள்!',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12))),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  REGISTER FORM
// ─────────────────────────────────────────────────────────────────────────────
class _RegisterForm extends StatefulWidget {
  const _RegisterForm();
  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _farmSizeCtrl = TextEditingController();
  final _bizNameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  UserRole _role = UserRole.farmer;
  String _bizType = 'Restaurant';
  bool _loading = false;
  bool _showPass = false;
  String? _error;
  final Set<String> _selectedCrops = {};

  final List<String> _bizTypes = [
    'Restaurant',
    'Hotel',
    'Supermarket',
    'Wholesale Shop',
    'School/College',
    'Other'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _farmSizeCtrl.dispose();
    _bizNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_role == UserRole.farmer && _selectedCrops.isEmpty) {
      setState(() => _error = 'குறைந்தது ஒரு crop select பண்ணுங்கள்!');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 800));

    final user = AppUser(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      role: _role,
      password: _passCtrl.text.trim(),
      farmSize: _role == UserRole.farmer ? _farmSizeCtrl.text.trim() : null,
      crops: _role == UserRole.farmer ? _selectedCrops.toList() : [],
      businessName: _role == UserRole.buyer ? _bizNameCtrl.text.trim() : null,
      businessType: _role == UserRole.buyer ? _bizType : null,
    );

    final error = authService.register(user);
    setState(() {
      _loading = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(langService.t('register_title'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(langService.t('register_subtitle'),
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            SizedBox(height: 18),
            Text(langService.t('who_are_you'),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(children: [
              _roleCard(
                  role: UserRole.farmer,
                  emoji: '👨‍🌾',
                  title: 'Farmer',
                  subtitle: 'விவசாயி\nCrops விற்பவர்',
                  color: kGreen700),
              const SizedBox(width: 12),
              _roleCard(
                  role: UserRole.buyer,
                  emoji: '🍽️',
                  title: 'Buyer',
                  subtitle: 'வாங்குபவர்\nRestaurant/Shop',
                  color: const Color(0xFF1565C0)),
            ]),
            const SizedBox(height: 16),
            _field(
                controller: _nameCtrl,
                label: 'Full Name / முழு பெயர்',
                hint: 'Murugan',
                icon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? 'Name required' : null),
            const SizedBox(height: 12),
            _field(
                controller: _phoneCtrl,
                label: 'Phone Number',
                hint: '9876543210',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 10,
                validator: (v) {
                  if (v!.isEmpty) return 'Phone required';
                  if (v.length != 10) return '10 digits enter பண்ணுங்கள்';
                  return null;
                }),
            const SizedBox(height: 12),
            _field(
                controller: _locationCtrl,
                label: 'Location / இடம்',
                hint: 'Krishnagiri, Tamil Nadu',
                icon: Icons.location_on_outlined,
                validator: (v) => v!.isEmpty ? 'Location required' : null),
            const SizedBox(height: 12),
            if (_role == UserRole.farmer) ...[
              _field(
                  controller: _farmSizeCtrl,
                  label: 'Farm Size (Optional)',
                  hint: '2.5 Acres',
                  icon: Icons.agriculture_outlined,
                  validator: (_) => null),
              const SizedBox(height: 14),
              const Text('உங்கள் Crops:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kCrops.map((c) {
                    final sel = _selectedCrops.contains(c);
                    return GestureDetector(
                        onTap: () => setState(() => sel
                            ? _selectedCrops.remove(c)
                            : _selectedCrops.add(c)),
                        child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                                color: sel ? kGreen700 : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color:
                                        sel ? kGreen700 : Colors.grey.shade300),
                                boxShadow: sel
                                    ? [
                                        BoxShadow(
                                            color: kGreen700.withOpacity(0.3),
                                            blurRadius: 4)
                                      ]
                                    : []),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Text(kCropEmojis[c]!,
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(c,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: sel
                                          ? Colors.white
                                          : Colors.grey[700])),
                            ])));
                  }).toList()),
              const SizedBox(height: 14),
            ],
            if (_role == UserRole.buyer) ...[
              _field(
                  controller: _bizNameCtrl,
                  label: 'Business Name',
                  hint: 'Sri Krishna Restaurant',
                  icon: Icons.storefront_outlined,
                  validator: (v) =>
                      v!.isEmpty ? 'Business name required' : null),
              const SizedBox(height: 12),
              const Text('Business Type:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _bizTypes.map((t) {
                    final sel = _bizType == t;
                    return ChoiceChip(
                        label: Text(t),
                        selected: sel,
                        selectedColor: const Color(0xFFE3F2FD),
                        onSelected: (_) => setState(() => _bizType = t),
                        side: BorderSide(
                            color: sel
                                ? const Color(0xFF1565C0)
                                : Colors.grey.shade300));
                  }).toList()),
              const SizedBox(height: 14),
            ],
            _field(
                controller: _passCtrl,
                label: 'Password',
                hint: 'Min 6 characters',
                icon: Icons.lock_outline,
                obscureText: !_showPass,
                suffixIcon: IconButton(
                    icon: Icon(
                        _showPass ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey),
                    onPressed: () => setState(() => _showPass = !_showPass)),
                validator: (v) {
                  if (v!.isEmpty) return 'Password required';
                  if (v.length < 6) return 'Min 6 characters';
                  return null;
                }),
            const SizedBox(height: 12),
            _field(
                controller: _confirmCtrl,
                label: 'Confirm Password',
                hint: 'Repeat password',
                icon: Icons.lock_outline,
                obscureText: true,
                validator: (v) {
                  if (v!.isEmpty) return 'Confirm required';
                  if (v != _passCtrl.text) return 'Passwords do not match!';
                  return null;
                }),
            const SizedBox(height: 12),
            if (_error != null)
              Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200)),
                  child: Row(children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(_error!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 13))),
                  ])),
            const SizedBox(height: 20),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: _loading ? null : _register,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _role == UserRole.farmer
                            ? kGreen700
                            : const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 4),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(
                            _role == UserRole.farmer
                                ? 'Join VILAI as Farmer 👨‍🌾'
                                : 'Join VILAI as Buyer 🍽️',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)))),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _roleCard({
    required UserRole role,
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final sel = _role == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: sel ? color.withOpacity(0.08) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: sel ? color : Colors.grey.shade300,
                  width: sel ? 2 : 1),
              boxShadow: sel
                  ? [BoxShadow(color: color.withOpacity(0.15), blurRadius: 8)]
                  : []),
          child: Column(children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: sel ? color : Colors.grey[700])),
            const SizedBox(height: 3),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10,
                    color: sel ? color : Colors.grey[500],
                    height: 1.4)),
            if (sel) ...[
              const SizedBox(height: 6),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(10)),
                  child: const Text('✓ Selected',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold))),
            ],
          ]),
        ),
      ),
    );
  }
}

// ── Shared input field ────────────────────────────────────────────────────────
Widget _field({
  required TextEditingController controller,
  required String label,
  required String hint,
  required IconData icon,
  required String? Function(String?) validator,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
  int maxLines = 1,
  int? maxLength,
  bool obscureText = false,
  Widget? suffixIcon,
}) =>
    TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        maxLength: maxLength,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon, color: kGreen700),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.grey[50],
            counterText: '',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kGreen700, width: 2)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red))));
