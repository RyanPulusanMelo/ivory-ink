import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool _isLoading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  static const _kUsers = 'pm_users';
  static const _kCurrentUser = 'pm_current_user';

  AuthProvider() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_kCurrentUser);
    if (userJson != null) {
      try {
        _user = AppUser.fromJson(jsonDecode(userJson));
        notifyListeners();
      } catch (_) {}
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password + 'phonemart_salt_2024');
    return sha256.convert(bytes).toString();
  }

  Future<Map<String, Map<String, dynamic>>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUsers);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v as Map<String, dynamic>));
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveUsers(Map<String, Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsers, jsonEncode(users));
  }

  /// Sign up a new user. Returns null on success, error message on failure.
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600)); // simulate network

    try {
      final users = await _getUsers();
      final emailKey = email.toLowerCase().trim();

      if (users.containsKey(emailKey)) {
        _isLoading = false;
        _error = 'An account with this email already exists.';
        notifyListeners();
        return _error;
      }

      final newUser = AppUser(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        email: emailKey,
        phone: phone.trim(),
        createdAt: DateTime.now(),
      );

      users[emailKey] = {
        ...newUser.toJson(),
        'passwordHash': _hashPassword(password),
      };
      await _saveUsers(users);

      _user = newUser;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kCurrentUser, jsonEncode(newUser.toJson()));

      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Sign up failed. Please try again.';
      notifyListeners();
      return _error;
    }
  }

  /// Login. Returns null on success, error message on failure.
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final users = await _getUsers();
      final emailKey = email.toLowerCase().trim();
      final userData = users[emailKey];

      if (userData == null) {
        _isLoading = false;
        _error = 'No account found with this email.';
        notifyListeners();
        return _error;
      }

      if (userData['passwordHash'] != _hashPassword(password)) {
        _isLoading = false;
        _error = 'Incorrect password.';
        notifyListeners();
        return _error;
      }

      _user = AppUser.fromJson(userData);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kCurrentUser, jsonEncode(_user!.toJson()));

      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Login failed. Please try again.';
      notifyListeners();
      return _error;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCurrentUser);
    _user = null;
    notifyListeners();
  }

  Future<String?> updateProfile({
    required String name,
    required String phone,
  }) async {
    if (_user == null) return 'Not logged in';
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    try {
      final users = await _getUsers();
      final emailKey = _user!.email;

      if (!users.containsKey(emailKey)) {
        _isLoading = false;
        notifyListeners();
        return 'User not found';
      }

      final updated = AppUser(
        id: _user!.id,
        name: name.trim(),
        email: _user!.email,
        phone: phone.trim(),
        createdAt: _user!.createdAt,
      );

      users[emailKey] = {
        ...users[emailKey]!,
        ...updated.toJson(),
      };
      await _saveUsers(users);

      _user = updated;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kCurrentUser, jsonEncode(updated.toJson()));

      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Update failed';
    }
  }
}