// lib/services/storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/user.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Keys
  static const String _keyToken = 'token';
  static const String _keyUser = 'user';
  static const String _keyIsLoggedIn = 'isLoggedIn';

  // ========== TOKEN METHODS ==========
  
  /// Save token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  /// Get token
  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  /// Delete token
  Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }

  /// Check if token exists
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ========== USER METHODS ==========
  
  /// Save user data
  Future<void> saveUser(User user) async {
    final userJson = json.encode(user.toJson());
    await _storage.write(key: _keyUser, value: userJson);
  }

  /// Get user data
  Future<User?> getUser() async {
    final userJson = await _storage.read(key: _keyUser);
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    return null;
  }

  /// Delete user data
  Future<void> deleteUser() async {
    await _storage.delete(key: _keyUser);
  }

  // ========== LOGIN STATE METHODS ==========
  
  /// Set logged in state
  Future<void> setLoggedIn(bool isLoggedIn) async {
    await _storage.write(key: _keyIsLoggedIn, value: isLoggedIn.toString());
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final value = await _storage.read(key: _keyIsLoggedIn);
    return value == 'true';
  }

  // ========== CLEAR ALL DATA ==========
  
  /// Clear all stored data (logout)
  Future<void> clearAll() async {
    await deleteToken();
    await deleteUser();
    await setLoggedIn(false);
  }

  /// Save login data (token + user)
  Future<void> saveLoginData({
    required String token,
    required User user,
  }) async {
    await saveToken(token);
    await saveUser(user);
    await setLoggedIn(true);
  }
}