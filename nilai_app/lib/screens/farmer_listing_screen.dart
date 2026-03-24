// ─────────────────────────────────────────────────────────────────────────────
//  screens/farmer_listing_screen.dart
//  Farmer posts crop listing → Buyers can see & contact directly
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';
import '../services/language_service.dart';
import 'buyer_screen.dart';

// ── Listing model ─────────────────────────────────────────────────────────────
class CropListing {
  final String id;
  final String crop;
  final String farmerName;
  final String phone;
  final String location;
  final double quantity;
  final double pricePerKg;
  final String quality; // A/B/C grade
  final String notes;
  final DateTime postedAt;
  bool isActive;

  CropListing({
    required this.id,
    required this.crop,
    required this.farmerName,
    required this.phone,
    required this.location,
    required this.quantity,
    required this.pricePerKg,
    required this.quality,
    required this.notes,
    required this.postedAt,
    this.isActive = true,
  });
}

// Global listings list — demo-க்கு memory-ல் store பண்றோம்
// Real app-ல் Firebase use பண்ணலாம்
final List<CropListing> globalListings = [];

// ─────────────────────────────────────────────────────────────────────────────
class FarmerListingScreen extends StatefulWidget {
  const FarmerListingScreen({super.key});

  @override
  State<FarmerListingScreen> createState() => _FarmerListingScreenState();
}

class _FarmerListingScreenState extends State<FarmerListingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // ── Form controllers ──────────────────────────────────────────────────────
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedCrop = 'Tomato';
  double _quantity = 100;
  double _pricePerKg = 30;
  String _selectedQuality = 'A';
  bool _posting = false;

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
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onLang() {
    if (mounted) setState(() {});
  }

  // ── Post listing ──────────────────────────────────────────────────────────
  Future<void> _postListing() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _posting = true);
    await Future.delayed(const Duration(milliseconds: 800)); // simulate save

    final listing = CropListing(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      crop: _selectedCrop,
      farmerName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      quantity: _quantity,
      pricePerKg: _pricePerKg,
      quality: _selectedQuality,
      notes: _notesCtrl.text.trim(),
      postedAt: DateTime.now(),
    );

    setState(() {
      globalListings.insert(0, listing);
      _posting = false;
    });

    // Clear form
    _nameCtrl.clear();
    _phoneCtrl.clear();
    _locationCtrl.clear();
    _notesCtrl.clear();
    setState(() {
      _selectedCrop = 'Tomato';
      _quantity = 100;
      _pricePerKg = 30;
      _selectedQuality = 'A';
    });

    // Show success + switch to My Listings tab
    _tabCtrl.animateTo(1);
    _showSuccess();
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('✅', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text('Listing Posted!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
              'உங்கள் $_selectedCrop listing buyers-கிட்ட காட்டப்படுது!\n'
              'Buyers directly call பண்ணுவாங்க.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: Colors.grey[600], height: 1.4)),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text('Great! 👍')),
        ]),
      ),
    );
  }

  void _deleteListing(String id) {
    setState(() => globalListings.removeWhere((l) => l.id == id));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('🗑️ Listing removed'), backgroundColor: Colors.grey));
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  TAB 1 — POST NEW LISTING FORM
  // ─────────────────────────────────────────────────────────────────────────
  Widget _postForm() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: kGreen100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kGreen700.withOpacity(0.3))),
              child: const Row(children: [
                Text('💡', style: TextStyle(fontSize: 20)),
                SizedBox(width: 10),
                Expanded(
                    child: Text(
                        'உங்கள் crop listing post பண்ணுங்கள்!\n'
                        'Restaurants & shops directly contact பண்ணுவாங்க.\n'
                        'No middleman — full profit உங்களுக்கே! 💰',
                        style: TextStyle(
                            fontSize: 12, height: 1.4, color: kGreen700))),
              ]),
            ),
            const SizedBox(height: 16),

            // ── Crop selector ────────────────────────────────────────────────
            _sectionTitle('🌾 Select Crop'),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: kCrops.map((c) {
                final sel = _selectedCrop == c;
                return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCrop = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                            color: sel ? kGreen700 : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: sel ? kGreen700 : Colors.grey.shade300),
                            boxShadow: sel
                                ? [
                                    BoxShadow(
                                        color: kGreen700.withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2))
                                  ]
                                : []),
                        child: Row(children: [
                          Text(kCropEmojis[c]!,
                              style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 6),
                          Text(c,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      sel ? Colors.white : Colors.grey[700])),
                        ]),
                      ),
                    ));
              }).toList()),
            ),
            const SizedBox(height: 20),

            // ── Quantity slider ──────────────────────────────────────────────
            _sectionTitle('⚖️ Quantity'),
            const SizedBox(height: 6),
            Container(
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
              child: Column(children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('How much do you want to sell?',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                              color: kGreen100,
                              borderRadius: BorderRadius.circular(20)),
                          child: Text('${_quantity.toInt()} kg',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kGreen700,
                                  fontSize: 15))),
                    ]),
                Slider(
                    value: _quantity,
                    min: 10,
                    max: 2000,
                    divisions: 39,
                    activeColor: kGreen700,
                    label: '${_quantity.toInt()} kg',
                    onChanged: (v) => setState(() => _quantity = v)),
              ]),
            ),
            const SizedBox(height: 16),

            // ── Price slider ─────────────────────────────────────────────────
            _sectionTitle('💰 Your Asking Price'),
            const SizedBox(height: 6),
            Container(
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
              child: Column(children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Price per kg',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(20)),
                          child: Text('₹${_pricePerKg.toInt()}/kg',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[800],
                                  fontSize: 15))),
                    ]),
                Slider(
                    value: _pricePerKg,
                    min: 5,
                    max: 200,
                    divisions: 39,
                    activeColor: Colors.orange[700],
                    label: '₹${_pricePerKg.toInt()}',
                    onChanged: (v) => setState(() => _pricePerKg = v)),
                // Total earnings preview
                Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: kBg, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total earnings:',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(
                              '₹${(_quantity * _pricePerKg).toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: kGreen700)),
                        ])),
              ]),
            ),
            const SizedBox(height: 16),

            // ── Quality grade ────────────────────────────────────────────────
            _sectionTitle('⭐ Crop Quality Grade'),
            const SizedBox(height: 10),
            Row(
                children: ['A', 'B', 'C'].map((grade) {
              final sel = _selectedQuality == grade;
              final colors = {
                'A': kGreen700,
                'B': Colors.orange[700]!,
                'C': Colors.red[600]!
              };
              final labels = {'A': 'Premium', 'B': 'Good', 'C': 'Average'};
              final descs = {
                'A': 'Fresh, no damage',
                'B': 'Minor marks',
                'C': 'Some damage'
              };
              return Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedQuality = grade),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: sel
                            ? colors[grade]!.withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: sel ? colors[grade]! : Colors.grey.shade300,
                            width: sel ? 2 : 1)),
                    child: Column(children: [
                      Text(grade,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colors[grade])),
                      const SizedBox(height: 4),
                      Text(labels[grade]!,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: colors[grade])),
                      Text(descs[grade]!,
                          style:
                              TextStyle(fontSize: 9, color: Colors.grey[600]),
                          textAlign: TextAlign.center),
                    ]),
                  ),
                ),
              ));
            }).toList()),
            const SizedBox(height: 16),

            // ── Farmer details ───────────────────────────────────────────────
            _sectionTitle('👨‍🌾 Your Details'),
            const SizedBox(height: 10),
            _inputField(
              controller: _nameCtrl,
              label: 'Your Name',
              hint: 'உங்கள் பெயர்',
              icon: Icons.person_outline,
              validator: (v) => v!.isEmpty ? 'Name required' : null,
            ),
            const SizedBox(height: 10),
            _inputField(
              controller: _phoneCtrl,
              label: 'Phone Number',
              hint: '9876543210',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 10,
              validator: (v) {
                if (v!.isEmpty) return 'Phone required';
                if (v.length != 10) return 'Enter 10-digit number';
                return null;
              },
            ),
            const SizedBox(height: 10),
            _inputField(
              controller: _locationCtrl,
              label: 'Your Village / Town',
              hint: 'Krishnagiri, Tamil Nadu',
              icon: Icons.location_on_outlined,
              validator: (v) => v!.isEmpty ? 'Location required' : null,
            ),
            const SizedBox(height: 10),
            _inputField(
              controller: _notesCtrl,
              label: 'Additional Notes (Optional)',
              hint: 'Harvest date, special conditions...',
              icon: Icons.notes_outlined,
              maxLines: 2,
              validator: (_) => null,
            ),
            const SizedBox(height: 24),

            // ── Preview card ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: kGreen50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kGreen700.withOpacity(0.3))),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('👁️ Preview — Buyers இதை பார்ப்பாங்க:',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: kGreen700)),
                    const SizedBox(height: 10),
                    Row(children: [
                      Text(kCropEmojis[_selectedCrop]!,
                          style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text('$_selectedCrop — ${_quantity.toInt()} kg',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(
                                '₹${_pricePerKg.toInt()}/kg • Grade $_selectedQuality',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600])),
                            Text(
                                '📍 ${_locationCtrl.text.isEmpty ? "Your location" : _locationCtrl.text}',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[500])),
                          ])),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                                '₹${(_quantity * _pricePerKg).toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: kGreen700)),
                            const Text('total',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey)),
                          ]),
                    ]),
                  ]),
            ),
            const SizedBox(height: 20),

            // ── Post button ──────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                  onPressed: _posting ? null : _postListing,
                  icon: _posting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.upload_rounded, size: 22),
                  label: Text(
                      _posting
                          ? 'Posting...'
                          : '📤 Post Listing — Reach Buyers!',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)))),
            ),
            const SizedBox(height: 8),

            // View buyers button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const BuyerScreen())),
                  icon: const Icon(Icons.storefront_outlined),
                  label: const Text('🍽️ View as Buyer',
                      style: TextStyle(fontSize: 14)),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: kGreen700,
                      side: const BorderSide(color: kGreen700),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)))),
            ),
            const SizedBox(height: 32),
          ]),
        ),
      );

  // ─────────────────────────────────────────────────────────────────────────
  //  TAB 2 — MY LISTINGS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _myListings() {
    final myListings = globalListings;

    if (myListings.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('📭', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          const Text('No listings yet!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Post your first crop listing\nto reach buyers directly!',
              style:
                  TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton.icon(
              onPressed: () => _tabCtrl.animateTo(0),
              icon: const Icon(Icons.add),
              label: const Text('Post Now'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)))),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myListings.length,
      itemBuilder: (_, i) => _listingCard(myListings[i]),
    );
  }

  Widget _listingCard(CropListing listing) {
    final timeAgo = _timeAgo(listing.postedAt);
    final qualityColors = {
      'A': kGreen700,
      'B': Colors.orange[700]!,
      'C': Colors.red[600]!
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ]),
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: kGreen100,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14))),
          child: Row(children: [
            Text(kCropEmojis[listing.crop]!,
                style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('${listing.crop} — ${listing.quantity.toInt()} kg',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: kGreen700)),
                  Text(
                      '₹${listing.pricePerKg.toInt()}/kg • '
                      'Grade ${listing.quality} • $timeAgo',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                  '₹${(listing.quantity * listing.pricePerKg).toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: kGreen700)),
              const Text('total',
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
            ]),
          ]),
        ),

        // Details row
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
          child: Row(children: [
            _infoPill(Icons.person, listing.farmerName),
            const SizedBox(width: 8),
            _infoPill(Icons.location_on, listing.location),
            const Spacer(),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: qualityColors[listing.quality]!.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color:
                            qualityColors[listing.quality]!.withOpacity(0.5))),
                child: Text('Grade ${listing.quality}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: qualityColors[listing.quality]))),
          ]),
        ),

        // Status + delete
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: Row(children: [
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: kGreen100, borderRadius: BorderRadius.circular(20)),
                child: const Row(children: [
                  Icon(Icons.visibility, size: 14, color: kGreen700),
                  SizedBox(width: 4),
                  Text('Live — Buyers can see this',
                      style: TextStyle(
                          fontSize: 11,
                          color: kGreen700,
                          fontWeight: FontWeight.bold)),
                ])),
            const Spacer(),
            // Delete button
            IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
                onPressed: () => _confirmDelete(listing)),
          ]),
        ),

        // Notes
        if (listing.notes.isNotEmpty)
          Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: kBg, borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                const Icon(Icons.notes, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(listing.notes,
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600]))),
              ])),
      ]),
    );
  }

  void _confirmDelete(CropListing listing) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Listing?'),
        content: Text('${listing.crop} ${listing.quantity.toInt()}kg listing-ஐ '
            'delete பண்ணவா?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteListing(listing.id);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Delete')),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _sectionTitle(String title) => Text(title,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)));

  Widget _infoPill(IconData icon, String text) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: Colors.grey[500]),
        const SizedBox(width: 3),
        Text(text,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis),
      ]);

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    int? maxLength,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        maxLength: maxLength,
        validator: validator,
        decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon, color: kGreen700),
            filled: true,
            fillColor: Colors.white,
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
                borderSide: const BorderSide(color: Colors.red))),
      );

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
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
        title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📤 Sell Your Crop',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text('Direct to Restaurants & Shops — No Middleman!',
                  style: TextStyle(fontSize: 10, color: Color(0xFFA5D6A7))),
            ]),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            const Tab(
                icon: Icon(Icons.add_circle_outline), text: 'Post Listing'),
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.list_alt, size: 18),
                const SizedBox(width: 6),
                const Text('My Listings'),
                if (globalListings.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(9)),
                      child: Center(
                          child: Text('${globalListings.length}',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: kGreen700,
                                  fontWeight: FontWeight.bold)))),
                ],
              ]),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [_postForm(), _myListings()],
      ),
    );
  }
}
