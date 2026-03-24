// ─────────────────────────────────────────────────────────────────────────────
//  services/auth_service.dart
//  Simple auth — demo-க்கு memory store, real app-ல் Firebase use பண்ணலாம்
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

enum UserRole { farmer, buyer }

class AppUser {
  final String name;
  final String phone;
  final String location;
  final UserRole role;
  final String password;

  // Farmer specific
  final String? farmSize;
  final List<String> crops;

  // Buyer specific
  final String? businessName;
  final String? businessType; // Restaurant, Hotel, Shop

  AppUser({
    required this.name,
    required this.phone,
    required this.location,
    required this.role,
    required this.password,
    this.farmSize,
    this.crops = const [],
    this.businessName,
    this.businessType,
  });
}

// ── Global Auth State ─────────────────────────────────────────────────────────
class AuthService extends ChangeNotifier {
  AppUser? _currentUser;
  final List<AppUser> _registeredUsers = [];

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isFarmer => _currentUser?.role == UserRole.farmer;
  bool get isBuyer => _currentUser?.role == UserRole.buyer;

  // ── Register ──────────────────────────────────────────────────────────────
  String? register(AppUser user) {
    // Check if phone already exists
    final exists = _registeredUsers.any((u) => u.phone == user.phone);
    if (exists) return 'இந்த phone number already registered!';

    _registeredUsers.add(user);
    _currentUser = user;
    notifyListeners();
    return null; // null = success
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  String? login(String phone, String password) {
    try {
      final user = _registeredUsers
          .firstWhere((u) => u.phone == phone && u.password == password);
      _currentUser = user;
      notifyListeners();
      return null; // success
    } catch (_) {
      return 'Phone number அல்லது password தவறு!';
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}

// Global instance
final authService = AuthService();
