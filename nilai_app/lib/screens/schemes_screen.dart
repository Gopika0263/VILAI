// ─────────────────────────────────────────────────────────────────────────────
//  screens/schemes_screen.dart
//  Government Schemes for Farmers — Tamil Nadu + Central Government
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/language_service.dart';

// ── Scheme Data Model ─────────────────────────────────────────────────────────
class GovScheme {
  final String name;
  final String tamilName;
  final String emoji;
  final String category;
  final String benefit;
  final String eligibility;
  final String howToApply;
  final String deadline;
  final Color color;
  final bool isCentral; // true = Central, false = State

  const GovScheme({
    required this.name,
    required this.tamilName,
    required this.emoji,
    required this.category,
    required this.benefit,
    required this.eligibility,
    required this.howToApply,
    required this.deadline,
    required this.color,
    required this.isCentral,
  });
}

// ── All Schemes Data ──────────────────────────────────────────────────────────
const List<GovScheme> _allSchemes = [
  // ── Central Government Schemes ────────────────────────────────────────────
  GovScheme(
    name: 'PM-KISAN',
    tamilName: 'பிரதமர் கிசான் சம்மான் நிதி',
    emoji: '💰',
    category: 'Direct Income',
    benefit:
        '₹6,000 per year (₹2,000 × 3 installments) directly to bank account',
    eligibility:
        'All small & marginal farmers with land. Annual income < ₹2 lakh',
    howToApply:
        '1. pmkisan.gov.in website போ\n2. "New Farmer Registration" click பண்ணு\n3. Aadhaar, Bank details, Land records upload பண்ணு\n4. Village Patwari verify பண்ணுவாரு',
    deadline: 'Ongoing — anytime apply பண்ணலாம்',
    color: Color(0xFF1565C0),
    isCentral: true,
  ),

  GovScheme(
    name: 'PM Fasal Bima Yojana',
    tamilName: 'பயிர் காப்பீட்டு திட்டம்',
    emoji: '🛡️',
    category: 'Crop Insurance',
    benefit:
        'Flood, drought, pest-ஆல் crop damage ஆனா full compensation கிடைக்கும். Premium மிகவும் குறைவு (2% மட்டும்)',
    eligibility:
        'All farmers who take crop loans. Voluntary farmers also eligible',
    howToApply:
        '1. Nearest bank அல்லது CSC center போ\n2. Khasra number, crop details தா\n3. Premium கட்டு\n4. Policy document வாங்கு',
    deadline: 'Kharif: July 31 | Rabi: December 31',
    color: Color(0xFF2E7D32),
    isCentral: true,
  ),

  GovScheme(
    name: 'Kisan Credit Card',
    tamilName: 'கிசான் கடன் அட்டை',
    emoji: '💳',
    category: 'Credit/Loan',
    benefit:
        'Up to ₹3 lakh loan at 4% interest only. No collateral needed for < ₹1.6 lakh',
    eligibility: 'All farmers, sharecroppers, tenant farmers. Age 18-75',
    howToApply:
        '1. Any nationalized bank போ\n2. KCC application form fill பண்ணு\n3. Land documents, Aadhaar submit பண்ணு\n4. 2-4 weeks-ல் card கிடைக்கும்',
    deadline: 'Ongoing — anytime apply பண்ணலாம்',
    color: Color(0xFFF57F17),
    isCentral: true,
  ),

  GovScheme(
    name: 'Soil Health Card',
    tamilName: 'மண் சுகாதார அட்டை',
    emoji: '🌱',
    category: 'Farming Support',
    benefit:
        'Free soil testing. Exact fertilizer recommendation கிடைக்கும். 30-40% fertilizer cost மிச்சம்',
    eligibility: 'All farmers — free of cost',
    howToApply:
        '1. Nearest Agriculture office போ\n2. Soil sample (500g) கொண்டு போ\n3. Free-ஆ test பண்ணுவாங்க\n4. 15-30 days-ல் card கிடைக்கும்',
    deadline: 'Ongoing — free service',
    color: Color(0xFF558B2F),
    isCentral: true,
  ),

  GovScheme(
    name: 'PM Kusum Yojana',
    tamilName: 'சூரிய சக்தி பம்ப் திட்டம்',
    emoji: '☀️',
    category: 'Solar Energy',
    benefit:
        'Solar pump-க்கு 90% subsidy! ₹2 lakh pump-க்கு ₹20,000 மட்டும் கட்டினா போதும்',
    eligibility: 'All farmers with agricultural land & power connection',
    howToApply:
        '1. Agriculture department portal-ல் register பண்ணு\n2. Application form submit பண்ணு\n3. Lottery-ல் select ஆனா installation பண்ணுவாங்க',
    deadline: 'Apply: agriculture.gov.in',
    color: Color(0xFFE65100),
    isCentral: true,
  ),

  GovScheme(
    name: 'eNAM',
    tamilName: 'தேசிய விவசாய சந்தை',
    emoji: '🏪',
    category: 'Market Access',
    benefit:
        'Online-ல் crop sell பண்ணலாம். Better price கிடைக்கும். Middleman இல்லாம direct sale',
    eligibility: 'All farmers — free registration',
    howToApply:
        '1. enam.gov.in portal போ\n2. Farmer registration பண்ணு\n3. Nearest APMC mandi register பண்ணு\n4. Online bidding-ல் participate பண்ணு',
    deadline: 'Ongoing — free platform',
    color: Color(0xFF00695C),
    isCentral: true,
  ),

  // ── Tamil Nadu State Schemes ───────────────────────────────────────────────
  GovScheme(
    name: 'Uzhavar Sandhai',
    tamilName: 'உழவர் சந்தை',
    emoji: '🛒',
    category: 'Direct Marketing',
    benefit:
        'Farmers directly consumers-கிட்ட sell பண்ணலாம். 20-30% extra income. No middleman',
    eligibility: 'All Tamil Nadu farmers',
    howToApply:
        '1. Nearest Uzhavar Sandhai office போ\n2. Farmer ID card, land documents தா\n3. Stall allotment கிடைக்கும்\n4. Fresh produce daily sell பண்ணலாம்',
    deadline: 'Ongoing — contact district agriculture office',
    color: Color(0xFF1B5E20),
    isCentral: false,
  ),

  GovScheme(
    name: 'TN Agri Gold Loan',
    tamilName: 'தமிழ்நாடு வேளாண் தங்க கடன்',
    emoji: '🥇',
    category: 'Credit/Loan',
    benefit:
        'Gold against loan — 4% interest only. Agricultural purpose-க்கு மட்டும். Quick processing',
    eligibility: 'Tamil Nadu farmers with gold jewelry',
    howToApply:
        '1. District Cooperative Bank போ\n2. Gold valuate பண்ணுவாங்க\n3. Farmer certificate தா\n4. Same day loan கிடைக்கும்',
    deadline: 'Ongoing',
    color: Color(0xFFF9A825),
    isCentral: false,
  ),

  GovScheme(
    name: 'CM Drought Relief',
    tamilName: 'வறட்சி நிவாரண உதவி',
    emoji: '🌧️',
    category: 'Disaster Relief',
    benefit:
        'Drought-ஆல் பயிர் இழந்தா ₹8,000-₹16,000/acre compensation. Direct bank transfer',
    eligibility: 'Drought-affected Tamil Nadu farmers',
    howToApply:
        '1. Village Administrative Officer-கிட்ட போ\n2. Crop loss report file பண்ணு\n3. Revenue inspector survey பண்ணுவாரு\n4. 30 days-ல் compensation கிடைக்கும்',
    deadline: 'After drought declaration — 60 days',
    color: Color(0xFF1565C0),
    isCentral: false,
  ),

  GovScheme(
    name: 'Free Electricity for Farmers',
    tamilName: 'இலவச மின்சாரம்',
    emoji: '⚡',
    category: 'Utilities',
    benefit:
        '100% free electricity for agricultural pump sets. No monthly bill. Save ₹15,000-₹30,000/year',
    eligibility: 'All Tamil Nadu farmers with registered pump sets',
    howToApply:
        '1. TANGEDCO office போ\n2. Agricultural service connection apply பண்ணு\n3. Land documents, Aadhaar submit பண்ணு\n4. Connection கிடைத்தால் free',
    deadline: 'Ongoing',
    color: Color(0xFFF57F17),
    isCentral: false,
  ),

  GovScheme(
    name: 'Precision Farming',
    tamilName: 'துல்லிய வேளாண்மை',
    emoji: '🚁',
    category: 'Technology',
    benefit:
        'Drip irrigation-க்கு 60-90% subsidy. Sprinkler-க்கும் subsidy. Water 40-60% மிச்சம்',
    eligibility: 'Tamil Nadu farmers with minimum 0.5 acre land',
    howToApply:
        '1. Agriculture Engineering Department போ\n2. Application form fill பண்ணு\n3. Land survey பண்ணுவாங்க\n4. Approved ஆனா installation பண்ணுவாங்க',
    deadline: 'Apply before March 31 each year',
    color: Color(0xFF00838F),
    isCentral: false,
  ),

  GovScheme(
    name: 'Organic Farming Support',
    tamilName: 'இயற்கை வேளாண்மை உதவி',
    emoji: '🌿',
    category: 'Organic',
    benefit:
        '₹10,000/acre subsidy for organic farming conversion. Certification support. Premium market access',
    eligibility: 'Farmers willing to convert to organic farming for 3 years',
    howToApply:
        '1. TNOCD (Organic Certification Dept) contact பண்ணு\n2. Training attend பண்ணு\n3. Application submit பண்ணு\n4. Inspector visit பண்ணுவாரு',
    deadline: 'Apply: tnagrisnet.tn.gov.in',
    color: Color(0xFF33691E),
    isCentral: false,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    langService.addListener(_onLang);
    _tabCtrl = TabController(length: 3, vsync: this);
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

  List<GovScheme> get _filtered {
    List<GovScheme> list;
    if (_tabCtrl.index == 1) {
      list = _allSchemes.where((s) => s.isCentral).toList();
    } else if (_tabCtrl.index == 2) {
      list = _allSchemes.where((s) => !s.isCentral).toList();
    } else {
      list = _allSchemes;
    }
    if (_searchQuery.isEmpty) return list;
    return list
        .where((s) =>
            s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            s.tamilName.contains(_searchQuery) ||
            s.category.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kGreen700,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(children: [
          const SizedBox(width: 12),
          Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/app_logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                          child: Text('🌾', style: TextStyle(fontSize: 18)))))),
          const SizedBox(width: 10),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('VILAI',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 3)),
            Text('அரசு திட்டங்கள் • Gov Schemes',
                style: TextStyle(fontSize: 10, color: Color(0xFFA5D6A7))),
          ]),
        ]),
        bottom: TabBar(
          controller: _tabCtrl,
          onTap: (_) => setState(() {}),
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(text: 'All (${_allSchemes.length})'),
            Tab(
                text:
                    'Central (${_allSchemes.where((s) => s.isCentral).length})'),
            Tab(
                text:
                    'TN State (${_allSchemes.where((s) => !s.isCentral).length})'),
          ],
        ),
      ),
      body: Column(children: [
        // ── Search bar ──────────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'திட்டம் தேடுங்கள் / Search scheme...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: kGreen700),
              filled: true,
              fillColor: kGreen50,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
        ),

        // ── Summary banner ──────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: kGreen700, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Text('💡', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
                child: Text(
                    '${_filtered.length} schemes available! Click any scheme for full details & how to apply.',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12, height: 1.4))),
          ]),
        ),
        const SizedBox(height: 8),

        // ── Schemes list ────────────────────────────────────────────────
        Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        const Text('🔍', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text('No schemes found for "$_searchQuery"',
                            style: TextStyle(color: Colors.grey[600])),
                      ]))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _schemeCard(_filtered[i]))),
      ]),
    );
  }

  Widget _schemeCard(GovScheme scheme) {
    return GestureDetector(
      onTap: () => _showSchemeDetail(scheme),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ]),
        child: Column(children: [
          // Header
          Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: scheme.color.withOpacity(0.08),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14))),
              child: Row(children: [
                Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: scheme.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12)),
                    child: Center(
                        child: Text(scheme.emoji,
                            style: const TextStyle(fontSize: 26)))),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(scheme.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: scheme.color)),
                      const SizedBox(height: 2),
                      Text(scheme.tamilName,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: scheme.isCentral
                              ? const Color(0xFF1565C0).withOpacity(0.1)
                              : kGreen100,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                          scheme.isCentral ? '🇮🇳 Central' : '🏛️ TN State',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: scheme.isCentral
                                  ? const Color(0xFF1565C0)
                                  : kGreen700))),
                  const SizedBox(height: 4),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: scheme.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(scheme.category,
                          style: TextStyle(
                              fontSize: 10,
                              color: scheme.color,
                              fontWeight: FontWeight.w600))),
                ]),
              ])),

          // Benefit preview
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(children: [
              const Icon(Icons.card_giftcard, color: kGreen700, size: 16),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(scheme.benefit,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[700], height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis)),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ]),
          ),
        ]),
      ),
    );
  }

  void _showSchemeDetail(GovScheme scheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: ListView(
            controller: ctrl,
            padding: const EdgeInsets.all(20),
            children: [
              // Handle
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),

              // Header
              Row(children: [
                Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                        color: scheme.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16)),
                    child: Center(
                        child: Text(scheme.emoji,
                            style: const TextStyle(fontSize: 30)))),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(scheme.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: scheme.color)),
                      const SizedBox(height: 2),
                      Text(scheme.tamilName,
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      Row(children: [
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                color: scheme.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(scheme.category,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: scheme.color,
                                    fontWeight: FontWeight.bold))),
                        const SizedBox(width: 6),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                color: scheme.isCentral
                                    ? const Color(0xFF1565C0).withOpacity(0.1)
                                    : kGreen100,
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                                scheme.isCentral
                                    ? '🇮🇳 Central Govt'
                                    : '🏛️ TN State Govt',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: scheme.isCentral
                                        ? const Color(0xFF1565C0)
                                        : kGreen700,
                                    fontWeight: FontWeight.bold))),
                      ]),
                    ])),
              ]),
              const SizedBox(height: 20),

              // Benefit
              _detailSection(
                  icon: Icons.card_giftcard,
                  title: 'பலன் / Benefit',
                  content: scheme.benefit,
                  color: scheme.color),
              const SizedBox(height: 12),

              // Eligibility
              _detailSection(
                  icon: Icons.check_circle_outline,
                  title: 'தகுதி / Eligibility',
                  content: scheme.eligibility,
                  color: kGreen700),
              const SizedBox(height: 12),

              // How to apply
              _detailSection(
                  icon: Icons.assignment_outlined,
                  title: 'எப்படி Apply பண்றது / How to Apply',
                  content: scheme.howToApply,
                  color: const Color(0xFF1565C0)),
              const SizedBox(height: 12),

              // Deadline
              _detailSection(
                  icon: Icons.calendar_today_outlined,
                  title: 'கடைசி தேதி / Deadline',
                  content: scheme.deadline,
                  color: Colors.orange[700]!),
              const SizedBox(height: 20),

              // Apply button
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                '📋 ${scheme.name} — Nearest Agriculture Office அல்லது CSC Center போய் apply பண்ணுங்கள்!'),
                            backgroundColor: scheme.color,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))));
                      },
                      icon: const Icon(Icons.how_to_reg_rounded),
                      label: const Text('Apply Now / இப்போதே Apply பண்ணுங்கள்',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))))),

              const SizedBox(height: 8),
              Center(
                  child: Text(
                      '🏛️ Nearest Agriculture Office / CSC Center-ல் apply பண்ணலாம்',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      textAlign: TextAlign.center)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) =>
      Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.2))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13, color: color)),
            ]),
            const SizedBox(height: 8),
            Text(content,
                style: const TextStyle(
                    fontSize: 13, height: 1.6, color: Color(0xFF1A1A1A))),
          ]));
}
