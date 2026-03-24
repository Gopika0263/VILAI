// ─────────────────────────────────────────────────────────────────────────────
//  screens/price_alert_screen.dart
//  Set target price → Check real mandi price → Notify via bell + phone
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../constants.dart';
import '../main.dart'; // alertState global
import '../services/market_service.dart';
import '../services/notification_service.dart';

class PriceAlertScreen extends StatefulWidget {
  const PriceAlertScreen({super.key});

  @override
  State<PriceAlertScreen> createState() => _PriceAlertScreenState();
}

class _PriceAlertScreenState extends State<PriceAlertScreen> {
  // ── Local alert list ──────────────────────────────────────────────────────
  final List<_AlertItem> _alerts = [];

  String _selectedCrop = 'Tomato';
  double _targetPrice = 50.0;
  bool _checking = false;

  // ── Add new alert ─────────────────────────────────────────────────────────
  void _addAlert() {
    // Prevent duplicate crop alerts
    if (_alerts.any((a) => a.crop == _selectedCrop)) {
      _snack(
          '$_selectedCrop alert already exists! Delete first.', Colors.orange);
      return;
    }

    setState(() => _alerts
        .add(_AlertItem(crop: _selectedCrop, targetPrice: _targetPrice)));

    _snack(
        '✅ Alert set! ${kCropEmojis[_selectedCrop]} '
        '$_selectedCrop @ ₹${_targetPrice.toInt()}/kg',
        kGreen700);
  }

  // ── Check all alerts against real mandi prices ────────────────────────────
  Future<void> _checkAllAlerts() async {
    if (_alerts.isEmpty) {
      _snack('No alerts! Add one first.', Colors.grey.shade700);
      return;
    }

    setState(() => _checking = true);

    try {
      final location = await MarketService.getUserLocation();
      int triggered = 0;

      for (final alert in _alerts) {
        // Fetch real prices for this crop
        final markets = await MarketService.getMarketsWithWeather(
            crop: alert.crop, userLocation: location);

        if (markets.isEmpty) continue;

        final best = markets.first; // highest price market
        final currentPrice = best.price;

        setState(() => alert.lastCheckedPrice = currentPrice);

        final wasTriggered = currentPrice >= alert.targetPrice;

        if (wasTriggered) {
          triggered++;
          setState(() => alert.isTriggered = true);

          // Push to global bell
          alertState.addNotification(AlertNotification(
            emoji: kCropEmojis[alert.crop]!,
            title: '${kCropEmojis[alert.crop]} ${alert.crop} Price Alert! 🎉',
            body: '${best.name}-ல் இப்போ ₹${currentPrice.toInt()}/kg — '
                'Target ₹${alert.targetPrice.toInt()} reach ஆச்சு! '
                'இப்போவே விக்கலாம்! 🌾',
          ));

          // Phone notification
          await NotificationService.checkAndNotify(
            crop: alert.crop,
            currentPrice: currentPrice,
            targetPrice: alert.targetPrice,
            marketName: best.name,
          );
        } else {
          // Info notification — not triggered yet
          alertState.addNotification(AlertNotification(
            emoji: '⏳',
            title: '${kCropEmojis[alert.crop]} ${alert.crop} Price Check',
            body: '${best.name}-ல் இப்போ ₹${currentPrice.toInt()}/kg — '
                'Target ₹${alert.targetPrice.toInt()} இன்னும் reach ஆகல. '
                'கொஞ்சம் காத்திருங்கள்!',
          ));
        }
      }

      _snack(
          triggered > 0
              ? '🔔 $triggered alert(s) triggered! Top bell பாருங்கள்.'
              : '✅ Checked! Target reach ஆகல. Bell-ல் details பாருங்கள்.',
          triggered > 0 ? kGreen700 : Colors.grey.shade700);
    } catch (e) {
      _snack('⚠️ ${e.toString().replaceFirst('Exception: ', '')}', Colors.red);
    } finally {
      setState(() => _checking = false);
    }
  }

  // ── Delete alert ──────────────────────────────────────────────────────────
  void _deleteAlert(int index) {
    final crop = _alerts[index].crop;
    setState(() => _alerts.removeAt(index));
    _snack('🗑️ $crop alert removed', Colors.grey.shade700);
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  WIDGETS
  // ─────────────────────────────────────────────────────────────────────────

  // ── How it works ──────────────────────────────────────────────────────────
  Widget _howItWorks() => Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: const Color(0xFFE8EAF6),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: const Color(0xFF3949AB).withOpacity(0.3))),
        child: const Row(children: [
          Text('💡', style: TextStyle(fontSize: 22)),
          SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('How Price Alerts Work',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF3949AB))),
                SizedBox(height: 4),
                Text(
                    '1. Crop & target price set பண்ணு\n'
                    '2. "Check Now" press பண்ணு\n'
                    '3. Real mandi price fetch ஆகும்\n'
                    '4. Target reach ஆனா 🔔 bell + phone notify!',
                    style: TextStyle(
                        fontSize: 12, height: 1.5, color: Color(0xFF1A1A1A))),
              ])),
        ]),
      );

  // ── Add alert form ────────────────────────────────────────────────────────
  Widget _addAlertForm() => Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Title
          const Row(children: [
            Text('🔔', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('Set New Alert',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 16),

          // Crop selector
          const Text('Select Crop',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF424242))),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: kCrops.map((c) {
              final sel = _selectedCrop == c;
              return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                      label: Text('${kCropEmojis[c]} $c'),
                      selected: sel,
                      selectedColor: kGreen100,
                      onSelected: (_) => setState(() => _selectedCrop = c),
                      side: BorderSide(
                          color: sel ? kGreen700 : Colors.grey.shade300)));
            }).toList()),
          ),
          const SizedBox(height: 16),

          // Target price
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Target Price',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF424242))),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: kGreen100, borderRadius: BorderRadius.circular(20)),
                child: Text('₹${_targetPrice.toInt()}/kg',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kGreen700,
                        fontSize: 15))),
          ]),
          Slider(
              value: _targetPrice,
              min: 10,
              max: 500,
              divisions: 49,
              activeColor: kGreen700,
              label: '₹${_targetPrice.toInt()}',
              onChanged: (v) => setState(() => _targetPrice = v)),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('₹10',
                style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            Text('₹500',
                style: TextStyle(fontSize: 10, color: Colors.grey[500])),
          ]),
          const SizedBox(height: 14),

          // Preview chip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: kBg, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Text(kCropEmojis[_selectedCrop]!,
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(
                      '$_selectedCrop ₹${_targetPrice.toInt()}/kg reach ஆனா '
                      'top 🔔 bell + phone notification வரும்!',
                      style: const TextStyle(fontSize: 12, height: 1.4))),
            ]),
          ),
          const SizedBox(height: 16),

          // Add button
          SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                  onPressed: _addAlert,
                  icon: const Icon(Icons.add_alert_rounded),
                  label: const Text('Add Alert',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))))),
        ]),
      );

  // ── Check Now button ──────────────────────────────────────────────────────
  Widget _checkButton() => Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: ElevatedButton.icon(
            onPressed: _checking ? null : _checkAllAlerts,
            icon: _checking
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.refresh_rounded),
            label: Text(
                _checking
                    ? 'Checking real prices...'
                    : '🔍 Check Now — Real Mandi Prices',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    _checking ? Colors.grey : const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)))),
      );

  // ── Active alerts list ────────────────────────────────────────────────────
  Widget _alertsList() {
    if (_alerts.isEmpty) {
      return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: const Column(children: [
            Text('🔕', style: TextStyle(fontSize: 44)),
            SizedBox(height: 10),
            Text('No alerts yet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            SizedBox(height: 4),
            Text('Above form-ல் add பண்ணுங்கள்!',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ]));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('📋 Active Alerts (${_alerts.length})',
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
      ..._alerts.asMap().entries.map((e) => _alertCard(e.value, e.key)),
    ]);
  }

  // ── Single alert card ─────────────────────────────────────────────────────
  Widget _alertCard(_AlertItem alert, int index) {
    final triggered = alert.isTriggered;
    final checked = alert.lastCheckedPrice;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: triggered ? kGreen700 : Colors.grey.shade200,
              width: triggered ? 2 : 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ]),
      child: Row(children: [
        // Crop emoji box
        Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                color: triggered ? kGreen100 : kBg,
                borderRadius: BorderRadius.circular(12)),
            child: Center(
                child: Text(kCropEmojis[alert.crop]!,
                    style: const TextStyle(fontSize: 24)))),
        const SizedBox(width: 12),

        // Details
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Crop name + triggered badge
          Row(children: [
            Text(alert.crop,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: triggered ? kGreen700 : const Color(0xFF1A1A1A))),
            if (triggered) ...[
              const SizedBox(width: 8),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                      color: kGreen700, borderRadius: BorderRadius.circular(8)),
                  child: const Text('🔔 TRIGGERED!',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold))),
            ],
          ]),
          const SizedBox(height: 3),

          // Target price
          Text('Target: ₹${alert.targetPrice.toInt()}/kg',
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),

          // Last checked result
          if (checked != null) ...[
            const SizedBox(height: 2),
            Text(
                'Checked: ₹${checked.toInt()}/kg — '
                '${checked >= alert.targetPrice ? "✅ Reached!" : "⏳ Not yet"}',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: checked >= alert.targetPrice
                        ? kGreen700
                        : Colors.orange[700])),
          ],
        ])),

        // Delete button
        IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
            onPressed: () => _deleteAlert(index)),
      ]),
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
        backgroundColor: kGreen700,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🔔 Price Alerts',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text('Get notified when price reaches target',
                  style: TextStyle(fontSize: 11, color: Color(0xFFA5D6A7))),
            ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(children: [
          _howItWorks(),
          _addAlertForm(),
          _checkButton(),
          _alertsList(),
        ]),
      ),
    );
  }
}

// ── Local alert model ─────────────────────────────────────────────────────────
class _AlertItem {
  final String crop;
  final double targetPrice;
  bool isTriggered = false;
  double? lastCheckedPrice;

  _AlertItem({required this.crop, required this.targetPrice});
}
