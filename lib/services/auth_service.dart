// lib/services/auth_service.dart

import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  User? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  // ========== INITIALIZATION ==========

  /// Initialize auth state
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isLoggedIn = await _storageService.isLoggedIn();
      if (_isLoggedIn) {
        _currentUser = await _storageService.getUser();

        // Verify token masih valid dengan get user profile
        if (await _storageService.hasToken()) {
          try {
            _currentUser = await _apiService.getUserProfile();
            await _storageService.saveUser(_currentUser!);
          } catch (e) {
            // Token tidak valid, logout
            await logout();
          }
        }
      }
    } catch (e) {
      debugPrint('Error init auth: $e');
      _isLoggedIn = false;
      _currentUser = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // ========== LOGIN ==========

  /// Login
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.login(username, password);

      if (response['success'] == true) {
        final token = response['data']['token'];
        final userData = response['data']['user'];

        // Debug: print userData to see what we're getting
        debugPrint('Login response userData: $userData');

        final user = User.fromJson(userData);

        await _storageService.saveLoginData(token: token, user: user);

        _currentUser = user;
        _isLoggedIn = true;

        _isLoading = false;
        notifyListeners();

        return {
          'success': true,
          'message': response['message'] ?? 'Login berhasil'
        };
      } else {
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': response['message'] ?? 'Login gagal'
        };
      }
    } catch (e) {
      debugPrint('Login error: $e');
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Login gagal: ${e.toString()}'};
    }
  }

  // ========== REGISTER ==========

  /// Register
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String passwordConfirmation,
    required String namaPengguna,
    String? telpUser,
    String? bio,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.register(
        username: username,
        password: password,
        passwordConfirmation: passwordConfirmation,
        namaPengguna: namaPengguna,
        telpUser: telpUser,
        bio: bio,
      );

      if (response['success'] == true) {
        final token = response['data']['token'];
        final userData = response['data']['user'];

        // Debug: print userData to see what we're getting
        debugPrint('Register response userData: $userData');

        final user = User.fromJson(userData);

        await _storageService.saveLoginData(token: token, user: user);

        _currentUser = user;
        _isLoggedIn = true;

        _isLoading = false;
        notifyListeners();

        return {
          'success': true,
          'message': response['message'] ?? 'Registrasi berhasil'
        };
      } else {
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': response['message'] ?? 'Registrasi gagal'
        };
      }
    } catch (e) {
      debugPrint('Register error: $e');
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Registrasi gagal: ${e.toString()}'};
    }
  }

  // ========== LOGOUT ==========

  /// Logout
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Call logout API
      try {
        await _apiService.logout();
      } catch (e) {
        debugPrint('Error logout API: $e');
      }

      // Clear storage
      await _storageService.clearAll();

      _currentUser = null;
      _isLoggedIn = false;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error logout: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== REFRESH USER DATA ==========

  /// Refresh user data dari server
  Future<void> refreshUserData() async {
    try {
      _currentUser = await _apiService.getUserProfile();
      await _storageService.saveUser(_currentUser!);
      notifyListeners();
    } catch (e) {
      debugPrint('Error refresh user data: $e');
    }
  }

  // ========== UPDATE USER ==========

  /// Update user locally
  void updateUserLocal(User user) {
    _currentUser = user;
    _storageService.saveUser(user);
    notifyListeners();
  }
}
