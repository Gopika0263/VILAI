// ─────────────────────────────────────────────────────────────────────────────
//  screens/loan_screen.dart
//  Government & Bank Loans for Farmers — Tamil Nadu
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/language_service.dart';

// ── Loan Data Model ───────────────────────────────────────────────────────────
class FarmerLoan {
  final String name;
  final String tamilName;
  final String emoji;
  final String bank;
  final String maxAmount;
  final String interestRate;
  final String tenure;
  final String category;
  final String purpose;
  final String eligibility;
  final List<String> documents;
  final String howToApply;
  final String subsidy;
  final Color color;
  final bool isGovernment;

  const FarmerLoan({
    required this.name,
    required this.tamilName,
    required this.emoji,
    required this.bank,
    required this.maxAmount,
    required this.interestRate,
    required this.tenure,
    required this.category,
    required this.purpose,
    required this.eligibility,
    required this.documents,
    required this.howToApply,
    required this.subsidy,
    required this.color,
    required this.isGovernment,
  });
}

// ── All Loans Data ─────────────────────────────────────────────────────────────
const List<FarmerLoan> _allLoans = [
  // ── Government Scheme Loans ───────────────────────────────────────────────
  FarmerLoan(
    name: 'Kisan Credit Card (KCC)',
    tamilName: 'கிசான் கடன் அட்டை',
    emoji: '💳',
    bank: 'All Nationalised Banks + RRBs',
    maxAmount: '₹3 Lakh (without collateral)\n₹3 Lakh+ (with land)',
    interestRate: '4% per year\n(After 2% interest subvention)',
    tenure: '12 months (renewable)',
    category: 'Crop Loan',
    purpose:
        'Seeds, fertilizers, pesticides, farm equipment, post-harvest expenses',
    eligibility: 'All farmers, sharecroppers, tenant farmers. Age: 18-75 years',
    documents: [
      'Aadhaar Card',
      'Land ownership documents / Lease agreement',
      'Passport size photo (2)',
      'Bank account details',
      'Village/Tahsildar certificate',
    ],
    howToApply:
        '1. Nearest nationalised bank branch போ (SBI, Canara, Indian Bank)\n'
        '2. KCC application form fill பண்ணு\n'
        '3. Documents submit பண்ணு\n'
        '4. Bank officer field visit பண்ணுவாரு\n'
        '5. 7-14 days-ல் KCC கிடைக்கும்\n'
        '6. ATM card மூலம் cash எடுக்கலாம்',
    subsidy:
        '2% Interest Subvention — Government 2% கட்டும்!\nPrompt repayment bonus: 3% extra discount',
    color: Color(0xFF1565C0),
    isGovernment: true,
  ),

  FarmerLoan(
    name: 'PM Agriculture Infrastructure Fund',
    tamilName: 'வேளாண் உள்கட்டமைப்பு நிதி',
    emoji: '🏗️',
    bank: 'NABARD through Banks',
    maxAmount: '₹2 Crore per project',
    interestRate: '3% per year\n(After 3% interest subvention)',
    tenure: '7 years',
    category: 'Infrastructure',
    purpose: 'Cold storage, warehouse, processing unit, grading facilities',
    eligibility: 'Farmers, FPOs, Self Help Groups, Agri-entrepreneurs',
    documents: [
      'Project Proposal',
      'Land documents',
      'Aadhaar & PAN Card',
      'Bank statements (6 months)',
      'Registration certificate (if company/FPO)',
    ],
    howToApply: '1. agriinfra.dac.gov.in portal-ல் register பண்ணு\n'
        '2. Project proposal submit பண்ணு\n'
        '3. Bank loan sanction பண்ணும்\n'
        '4. Government 3% subvention automatically apply ஆகும்',
    subsidy: '3% Interest Subvention + ₹2 Crore Credit Guarantee',
    color: Color(0xFF2E7D32),
    isGovernment: true,
  ),

  FarmerLoan(
    name: 'NABARD Farm Loan',
    tamilName: 'நபார்ட் வேளாண் கடன்',
    emoji: '🌾',
    bank: 'NABARD (via Co-operative Banks)',
    maxAmount: '₹10 Lakh',
    interestRate: '7% per year',
    tenure: '5 years',
    category: 'Term Loan',
    purpose: 'Farm equipment, irrigation, land development, horticulture',
    eligibility: 'Small & marginal farmers with land. Annual income < ₹3 lakh',
    documents: [
      'Land patta / chitta',
      'Aadhaar Card',
      'Ration Card',
      'Passport photo',
      'Income certificate',
    ],
    howToApply: '1. District Cooperative Central Bank போ\n'
        '2. NABARD loan application form fill பண்ணு\n'
        '3. Land documents verify பண்ணுவாங்க\n'
        '4. 15-30 days-ல் loan கிடைக்கும்',
    subsidy: 'Interest subvention available for small farmers',
    color: Color(0xFF558B2F),
    isGovernment: true,
  ),

  FarmerLoan(
    name: 'TN Agri Gold Loan',
    tamilName: 'தமிழ்நாடு தங்க கடன்',
    emoji: '🥇',
    bank: 'Tamil Nadu Co-operative Bank',
    maxAmount: '₹5 Lakh (based on gold value)',
    interestRate: '4% per year',
    tenure: '12 months',
    category: 'Gold Loan',
    purpose: 'Any agricultural purpose — seeds, fertilizer, equipment',
    eligibility:
        'Tamil Nadu farmers with gold jewelry. No land document needed!',
    documents: [
      'Gold jewelry (physical)',
      'Aadhaar Card',
      'Farmer ID / Pattadar Passbook',
      'Passport photo',
    ],
    howToApply: '1. District Cooperative Bank போ\n'
        '2. Gold jewelry கொண்டு போ\n'
        '3. Gold valuate பண்ணுவாங்க\n'
        '4. Same day loan கிடைக்கும்! ✅',
    subsidy: 'Low interest 4% only! No collateral except gold',
    color: Color(0xFFF9A825),
    isGovernment: false,
  ),

  // ── Bank Loans ────────────────────────────────────────────────────────────
  FarmerLoan(
    name: 'SBI Kisan Credit Card',
    tamilName: 'SBI கிசான் கடன் அட்டை',
    emoji: '🏦',
    bank: 'State Bank of India',
    maxAmount: '₹5 Lakh',
    interestRate: '7% per year\n(Effective 4% with subvention)',
    tenure: '5 years',
    category: 'Crop Loan',
    purpose: 'Crop cultivation, post-harvest, farm maintenance',
    eligibility: 'All farmers with land. SBI account holders preferred',
    documents: [
      'Land documents',
      'Aadhaar Card',
      'SBI Account details',
      'Photograph',
      'Income proof',
    ],
    howToApply: '1. SBI branch போ அல்லது yono.sbi.co.in\n'
        '2. KCC application submit பண்ணு\n'
        '3. Field verification பண்ணுவாங்க\n'
        '4. 10 days-ல் card கிடைக்கும்',
    subsidy: '2% Government subvention + 3% prompt payment bonus',
    color: Color(0xFF1565C0),
    isGovernment: false,
  ),

  FarmerLoan(
    name: 'Indian Bank Crop Loan',
    tamilName: 'இந்தியன் வங்கி பயிர் கடன்',
    emoji: '🌱',
    bank: 'Indian Bank',
    maxAmount: '₹3 Lakh (Short term)',
    interestRate: '4% effective\n(After subvention)',
    tenure: '12 months',
    category: 'Crop Loan',
    purpose: 'Paddy, sugarcane, cotton, horticulture crops',
    eligibility: 'Tamil Nadu farmers. Land ownership or tenancy',
    documents: [
      'Chitta / Pattadar Passbook',
      'Aadhaar Card',
      'Ration Card',
      'Passport photo (2)',
    ],
    howToApply: '1. Nearest Indian Bank branch போ\n'
        '2. Crop loan application fill பண்ணு\n'
        '3. Agriculture officer certificate தா\n'
        '4. 7 days-ல் loan கிடைக்கும்',
    subsidy: 'Interest subvention for timely repayment',
    color: Color(0xFF00695C),
    isGovernment: false,
  ),

  FarmerLoan(
    name: 'Canara Bank Farm Loan',
    tamilName: 'கேனரா வங்கி வேளாண் கடன்',
    emoji: '🚜',
    bank: 'Canara Bank',
    maxAmount: '₹25 Lakh (Term loan)',
    interestRate: '8.5% per year',
    tenure: '7 years',
    category: 'Term Loan',
    purpose: 'Tractor, farm equipment, irrigation systems, land development',
    eligibility: 'Farmers with land. Good credit history',
    documents: [
      'Land ownership documents',
      'Aadhaar & PAN Card',
      'Bank statements (12 months)',
      'Quotation for equipment',
      'Income certificate',
    ],
    howToApply: '1. Canara Bank branch போ\n'
        '2. Farm loan application submit பண்ணு\n'
        '3. Land & income verification பண்ணுவாங்க\n'
        '4. 15-21 days-ல் loan sanction ஆகும்',
    subsidy: 'Interest subvention for priority sector lending',
    color: Color(0xFFE65100),
    isGovernment: false,
  ),

  FarmerLoan(
    name: 'Microfinance for Farmers',
    tamilName: 'சிறு நிதி கடன்',
    emoji: '🤝',
    bank: 'Grameen Bank / SEWA / Ujjivan',
    maxAmount: '₹50,000 - ₹2 Lakh',
    interestRate: '18-24% per year',
    tenure: '12-24 months',
    category: 'Micro Loan',
    purpose: 'Small farm inputs, seeds, tools — no collateral needed!',
    eligibility:
        'Any farmer, especially women SHG members. No land document needed',
    documents: [
      'Aadhaar Card',
      'Passport photo',
      'SHG membership (if applicable)',
    ],
    howToApply: '1. Nearest Grameen Bank / MFI office போ\n'
        '2. Group formation (5-10 members)\n'
        '3. Training attend பண்ணு\n'
        '4. 1 week-ல் loan கிடைக்கும்',
    subsidy: 'No collateral needed! Quick approval',
    color: Color(0xFF6A1B9A),
    isGovernment: false,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _search = '';

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

  List<FarmerLoan> get _filtered {
    List<FarmerLoan> list;
    if (_tabCtrl.index == 1) {
      list = _allLoans.where((l) => l.isGovernment).toList();
    } else if (_tabCtrl.index == 2) {
      list = _allLoans.where((l) => !l.isGovernment).toList();
    } else {
      list = _allLoans;
    }
    if (_search.isEmpty) return list;
    final q = _search.toLowerCase();
    return list
        .where((l) =>
            l.name.toLowerCase().contains(q) ||
            l.tamilName.contains(q) ||
            l.bank.toLowerCase().contains(q) ||
            l.category.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9A825),
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
            Text('வேளாண் கடன் திட்டங்கள்',
                style: TextStyle(fontSize: 10, color: Colors.white70)),
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
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: [
            Tab(text: 'All (${_allLoans.length})'),
            Tab(
                text:
                    'Govt (${_allLoans.where((l) => l.isGovernment).length})'),
            Tab(
                text:
                    'Banks (${_allLoans.where((l) => !l.isGovernment).length})'),
          ],
        ),
      ),
      body: Column(children: [
        // ── Search ──────────────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
                hintText: 'கடன் தேடுங்கள் / Search loan...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFF9A825)),
                filled: true,
                fillColor: const Color(0xFFFFF8E1),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none)),
          ),
        ),

        // ── Summary ─────────────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: const Color(0xFFF9A825),
              borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Text('💡', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
                child: Text(
                    '${_filtered.length} loan schemes! Click any loan for full details, documents & how to apply.',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12, height: 1.4))),
          ]),
        ),
        const SizedBox(height: 4),

        // ── Loan list ────────────────────────────────────────────────────
        Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        const Text('🔍', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text('No loans found for "$_search"',
                            style: TextStyle(color: Colors.grey[600])),
                      ]))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _loanCard(_filtered[i]))),
      ]),
    );
  }

  // ── Loan card ──────────────────────────────────────────────────────────────
  Widget _loanCard(FarmerLoan loan) => GestureDetector(
      onTap: () => _showLoanDetail(loan),
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
                    color: loan.color.withOpacity(0.08),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(14))),
                child: Row(children: [
                  Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                          color: loan.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12)),
                      child: Center(
                          child: Text(loan.emoji,
                              style: const TextStyle(fontSize: 26)))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(loan.name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: loan.color)),
                        const SizedBox(height: 2),
                        Text(loan.tamilName,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[600])),
                        const SizedBox(height: 2),
                        Text('🏦 ${loan.bank}',
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey[500])),
                      ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: loan.isGovernment
                                ? const Color(0xFF1565C0).withOpacity(0.1)
                                : kGreen100,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(loan.isGovernment ? '🇮🇳 Govt' : '🏦 Bank',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: loan.isGovernment
                                    ? const Color(0xFF1565C0)
                                    : kGreen700))),
                    const SizedBox(height: 4),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: loan.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(loan.category,
                            style: TextStyle(
                                fontSize: 9,
                                color: loan.color,
                                fontWeight: FontWeight.w600))),
                  ]),
                ])),

            // Key info row
            Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Row(children: [
                  _infoChip('💰', loan.maxAmount.split('\n').first),
                  const SizedBox(width: 8),
                  _infoChip(
                      '📊', '${loan.interestRate.split('\n').first} interest'),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.grey),
                ])),
          ])));

  Widget _infoChip(String emoji, String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: kGreen50, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(text,
            style: TextStyle(
                fontSize: 10,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500)),
      ]));

  // ── Loan detail bottom sheet ────────────────────────────────────────────────
  void _showLoanDetail(FarmerLoan loan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.88,
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
                        color: loan.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16)),
                    child: Center(
                        child: Text(loan.emoji,
                            style: const TextStyle(fontSize: 30)))),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(loan.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: loan.color)),
                      Text(loan.tamilName,
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      Text('🏦 ${loan.bank}',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[500])),
                    ])),
              ]),
              const SizedBox(height: 16),

              // Key stats
              Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: loan.color.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: loan.color.withOpacity(0.2))),
                  child: Row(children: [
                    Expanded(
                        child: _statCol(
                            '💰 Max Amount', loan.maxAmount, loan.color)),
                    Container(
                        width: 1,
                        height: 50,
                        color: loan.color.withOpacity(0.2)),
                    Expanded(
                        child: _statCol(
                            '📊 Interest', loan.interestRate, loan.color)),
                    Container(
                        width: 1,
                        height: 50,
                        color: loan.color.withOpacity(0.2)),
                    Expanded(
                        child: _statCol('📅 Tenure', loan.tenure, loan.color)),
                  ])),
              const SizedBox(height: 12),

              // Subsidy highlight
              if (loan.subsidy.isNotEmpty)
                Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: kGreen100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kGreen700.withOpacity(0.3))),
                    child: Row(children: [
                      const Text('🎁', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            const Text('Subsidy / சலுகை',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: kGreen700)),
                            const SizedBox(height: 3),
                            Text(loan.subsidy,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: kGreen700,
                                    height: 1.4)),
                          ])),
                    ])),
              const SizedBox(height: 12),

              // Purpose
              _detailSection(
                  icon: Icons.agriculture,
                  title: 'நோக்கம் / Purpose',
                  content: loan.purpose,
                  color: loan.color),
              const SizedBox(height: 10),

              // Eligibility
              _detailSection(
                  icon: Icons.check_circle_outline,
                  title: 'தகுதி / Eligibility',
                  content: loan.eligibility,
                  color: kGreen700),
              const SizedBox(height: 10),

              // Documents
              Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: Colors.orange.withOpacity(0.3))),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.folder_outlined,
                              color: Colors.orange[700], size: 18),
                          const SizedBox(width: 8),
                          Text('தேவையான ஆவணங்கள் / Documents',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.orange[700])),
                        ]),
                        const SizedBox(height: 10),
                        ...loan.documents.map((doc) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(children: [
                              Icon(Icons.check_box_outlined,
                                  color: Colors.orange[600], size: 16),
                              const SizedBox(width: 8),
                              Text(doc,
                                  style: const TextStyle(
                                      fontSize: 13, height: 1.3)),
                            ]))),
                      ])),
              const SizedBox(height: 10),

              // How to apply
              _detailSection(
                  icon: Icons.assignment_outlined,
                  title: 'எப்படி Apply பண்றது',
                  content: loan.howToApply,
                  color: const Color(0xFF1565C0)),
              const SizedBox(height: 20),

              // Apply button
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                '🏦 ${loan.bank} — Nearest branch-ல் போய் apply பண்ணுங்கள்!'),
                            backgroundColor: loan.color,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))));
                      },
                      icon: const Icon(Icons.account_balance_rounded),
                      label: const Text('Apply Now — Bank-ல் போங்கள்!',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: loan.color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))))),
              const SizedBox(height: 8),
              Center(
                  child: Text(
                      'Nearest Bank Branch / District Agriculture Office-ல் apply பண்ணலாம்',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      textAlign: TextAlign.center)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCol(String label, String value, Color color) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(children: [
        Text(label,
            style: TextStyle(fontSize: 9, color: Colors.grey[600]),
            textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(value.split('\n').first,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: color),
            textAlign: TextAlign.center),
      ]));

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
