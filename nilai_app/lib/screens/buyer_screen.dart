// ─────────────────────────────────────────────────────────────────────────────
//  screens/buyer_screen.dart
//  Call + WhatsApp — NO url_launcher needed!
//  Uses Flutter's built-in AndroidIntent approach via platform channels
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';
import '../services/language_service.dart';
import 'farmer_listing_screen.dart';

class BuyerScreen extends StatefulWidget {
  const BuyerScreen({super.key});

  @override
  State<BuyerScreen> createState() => _BuyerScreenState();
}

class _BuyerScreenState extends State<BuyerScreen> {
  String _filterCrop = 'All';

  // Platform channel for launching URLs on Android
  static const _platform = MethodChannel('com.vilai.app/launcher');

  List<CropListing> get _filtered {
    if (_filterCrop == 'All') return globalListings;
    return globalListings.where((l) => l.crop == _filterCrop).toList();
  }

  // ── Phone Call ─────────────────────────────────────────────────────────────
  Future<void> _makeCall(BuildContext context, CropListing listing) async {
    final phone = listing.phone.replaceAll(RegExp(r'\D'), '');

    try {
      await _platform.invokeMethod('makeCall', {'phone': '+91$phone'});
    } on PlatformException catch (_) {
      // Fallback: show number to dial manually
      _showCallDialog(context, listing);
    } catch (_) {
      _showCallDialog(context, listing);
    }
  }

  // ── WhatsApp ───────────────────────────────────────────────────────────────
  Future<void> _openWhatsApp(BuildContext context, CropListing listing) async {
    final phone = listing.phone.replaceAll(RegExp(r'\D'), '');
    final message = 'Hello ${listing.farmerName}! 🌾\n\n'
        'நான் உங்கள் VILAI listing பார்த்தேன்:\n'
        '• Crop: ${listing.crop}\n'
        '• Quantity: ${listing.quantity.toInt()} kg\n'
        '• Price: ₹${listing.pricePerKg.toInt()}/kg\n'
        '• Location: ${listing.location}\n\n'
        'Interested! Price confirm பண்ணுங்கள். 🙏';

    try {
      await _platform.invokeMethod('openWhatsApp', {
        'phone': '91$phone',
        'message': message,
      });
    } on PlatformException catch (_) {
      _showWhatsAppDialog(context, listing, message);
    } catch (_) {
      _showWhatsAppDialog(context, listing, message);
    }
  }

  // ── Fallback dialogs ───────────────────────────────────────────────────────
  void _showCallDialog(BuildContext context, CropListing listing) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('📞 Call Farmer'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Farmer phone number:',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: listing.phone));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('📋 Number copied!'),
                  backgroundColor: kGreen700));
            },
            child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: kGreen100, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.phone, color: kGreen700),
                  const SizedBox(width: 10),
                  Text(listing.phone,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kGreen700,
                          letterSpacing: 1.5)),
                  const Spacer(),
                  const Icon(Icons.copy, color: kGreen700, size: 16),
                ])),
          ),
          const SizedBox(height: 8),
          Text('${listing.farmerName} — ${listing.crop}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
          ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: listing.phone));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('📋 Number copied! Phone app-ல் paste பண்ணு'),
                    backgroundColor: kGreen700));
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy Number'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen700, foregroundColor: Colors.white)),
        ],
      ),
    );
  }

  void _showWhatsAppDialog(
      BuildContext context, CropListing listing, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('💬 WhatsApp Message'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12)),
              child: Column(children: [
                Row(children: [
                  const Text('📱', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text('+91 ${listing.phone}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const Spacer(),
                  GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: listing.phone));
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Number copied!')));
                      },
                      child:
                          const Icon(Icons.copy, size: 16, color: kGreen700)),
                ]),
                const Divider(height: 16),
                Text(message,
                    style: const TextStyle(fontSize: 12, height: 1.4)),
                const SizedBox(height: 8),
                GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: message));
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Message copied!')));
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.copy, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('Copy message',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[600])),
                        ])),
              ])),
          const SizedBox(height: 10),
          const Text(
              '1. Copy number above\n2. Open WhatsApp\n3. New chat → paste number',
              style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.6)),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
          ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(
                    ClipboardData(text: '+91${listing.phone}\n\n$message'));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        '✅ Number + Message copied! WhatsApp-ல் paste பண்ணு'),
                    backgroundColor: Color(0xFF25D366)));
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy All'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('🛒 Find Fresh Crops',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text('${globalListings.length} listings available',
              style: const TextStyle(fontSize: 11, color: Color(0xFF90CAF9))),
        ]),
      ),
      body: Column(children: [
        // ── Crop filter ────────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                      label: const Text('🌿 All'),
                      selected: _filterCrop == 'All',
                      selectedColor: const Color(0xFFE3F2FD),
                      onSelected: (_) => setState(() => _filterCrop = 'All'),
                      side: BorderSide(
                          color: _filterCrop == 'All'
                              ? const Color(0xFF1565C0)
                              : Colors.grey.shade300))),
              ...kCrops.map((c) {
                final sel = _filterCrop == c;
                return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                        label: Text('${kCropEmojis[c]} $c'),
                        selected: sel,
                        selectedColor: const Color(0xFFE3F2FD),
                        onSelected: (_) => setState(() => _filterCrop = c),
                        side: BorderSide(
                            color: sel
                                ? const Color(0xFF1565C0)
                                : Colors.grey.shade300)));
              }),
            ]),
          ),
        ),

        // ── Listings ───────────────────────────────────────────────────
        Expanded(
            child: _filtered.isEmpty
                ? _emptyView()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _buyerCard(_filtered[i]))),
      ]),
    );
  }

  Widget _emptyView() => Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🌾', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 16),
        Text(
            _filterCrop == 'All'
                ? 'No listings yet!\nFarmers post பண்ணல.'
                : 'No $_filterCrop listings.\nTry another crop!',
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5)),
      ]));

  Widget _buyerCard(CropListing listing) {
    final qualityColors = {
      'A': kGreen700,
      'B': Colors.orange[700]!,
      'C': Colors.red[600]!
    };
    final timeAgo = _timeAgo(listing.postedAt);

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
                color: const Color(0xFFE3F2FD),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14))),
            child: Row(children: [
              Text(kCropEmojis[listing.crop] ?? '🌾',
                  style: const TextStyle(fontSize: 30)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      Text(listing.crop,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 8),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                              color:
                                  (qualityColors[listing.quality] ?? kGreen700)
                                      .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text('Grade ${listing.quality}',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: qualityColors[listing.quality] ??
                                      kGreen700))),
                    ]),
                    Text('${listing.quantity.toInt()} kg • $timeAgo',
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('₹${listing.pricePerKg.toInt()}',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0))),
                const Text('/kg',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ]),
            ])),

        // Farmer info
        Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Row(children: [
              Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: kGreen100,
                      borderRadius: BorderRadius.circular(18)),
                  child: const Center(
                      child: Text('👨‍🌾', style: TextStyle(fontSize: 18)))),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(listing.farmerName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('📍 ${listing.location}',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ])),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: kGreen100,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                      '₹${(listing.quantity * listing.pricePerKg).toStringAsFixed(0)} total',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: kGreen700))),
            ])),

        if (listing.notes.isNotEmpty)
          Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: kBg, borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                const Icon(Icons.notes, size: 13, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(listing.notes,
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey[600]))),
              ])),

        // ── Call + WhatsApp buttons ──────────────────────────────────────
        Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
            child: Row(children: [
              // 📞 CALL
              Expanded(
                  child: ElevatedButton.icon(
                      onPressed: () => _makeCall(context, listing),
                      icon: const Icon(Icons.call_rounded, size: 18),
                      label: Text('📞 ${listing.phone}',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: kGreen700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))))),

              const SizedBox(width: 10),

              // 💬 WHATSAPP
              Expanded(
                  child: ElevatedButton.icon(
                      onPressed: () => _openWhatsApp(context, listing),
                      icon: const Icon(Icons.chat_rounded, size: 18),
                      label: const Text('💬 WhatsApp',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))))),
            ])),
      ]),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
