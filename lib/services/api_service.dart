// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';
import '../models/pengaduan.dart';
import '../models/item.dart';
import 'storage_service.dart';

class ApiService {
  final StorageService _storageService = StorageService();

  // ========== HELPER METHODS ==========

  /// Get headers dengan token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    if (token != null) {
      return ApiConfig.headersWithToken(token);
    }
    return ApiConfig.headersWithoutToken();
  }

  /// Handle API response
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Unauthorized');
      } else if (response.statusCode == 422) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Validation error');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to parse response: $e');
    }
  }

  // ========== AUTH ENDPOINTS ==========

  /// Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.fullUrl(ApiConfig.login)),
            headers: ApiConfig.headersWithoutToken(),
            body: json.encode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Login gagal: $e');
    }
  }

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
      final response = await http
          .post(
            Uri.parse(ApiConfig.fullUrl(ApiConfig.register)),
            headers: ApiConfig.headersWithoutToken(),
            body: json.encode({
              'username': username,
              'password': password,
              'password_confirmation': passwordConfirmation,
              'nama_pengguna': namaPengguna,
              'telp_user': telpUser,
              'bio': bio,
            }),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Register gagal: $e');
    }
  }

  /// Logout
  Future<Map<String, dynamic>> logout() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse(ApiConfig.fullUrl(ApiConfig.logout)),
            headers: headers,
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Logout gagal: $e');
    }
  }

  /// Get User Profile
  Future<User> getUserProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse(ApiConfig.fullUrl(ApiConfig.user)),
            headers: headers,
          )
          .timeout(ApiConfig.timeout);

      final data = _handleResponse(response);
      return User.fromJson(data['data']);
    } catch (e) {
      throw Exception('Gagal mengambil profil: $e');
    }
  }

  // ========== PROFILE ENDPOINTS ==========

  /// Update Profile
  Future<User> updateProfile({
    String? namaPengguna,
    String? bio,
    String? telpUser,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse(ApiConfig.fullUrl(ApiConfig.profileUpdate)),
            headers: headers,
            body: json.encode({
              if (namaPengguna != null) 'nama_pengguna': namaPengguna,
              if (bio != null) 'bio': bio,
              if (telpUser != null) 'telp_user': telpUser,
            }),
          )
          .timeout(ApiConfig.timeout);

      final data = _handleResponse(response);
      return User.fromJson(data['data']);
    } catch (e) {
      throw Exception('Gagal update profil: $e');
    }
  }

  /// Update Profile Photo
  Future<String> updateProfilePhoto(File imageFile) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.fullUrl(ApiConfig.profileUpdatePhoto)),
      );

      request.headers.addAll(ApiConfig.headersMultipart(token));
      request.files.add(
        await http.MultipartFile.fromPath('foto_profil', imageFile.path),
      );

      final streamedResponse = await request.send().timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamedResponse);

      final data = _handleResponse(response);
      return data['data']['foto_profil'];
    } catch (e) {
      throw Exception('Gagal update foto profil: $e');
    }
  }

  /// Change Password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse(ApiConfig.fullUrl(ApiConfig.profileChangePassword)),
            headers: headers,
            body: json.encode({
              'current_password': currentPassword,
              'new_password': newPassword,
              'new_password_confirmation': newPasswordConfirmation,
            }),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Gagal ubah password: $e');
    }
  }

  // ========== ITEM ENDPOINTS ==========

  /// Get All Items
  Future<List<Item>> getItems() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse(ApiConfig.fullUrl(ApiConfig.items)),
            headers: headers,
          )
          .timeout(ApiConfig.timeout);

      final data = _handleResponse(response);
      return (data['data'] as List).map((json) => Item.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil items: $e');
    }
  }

  /// Get Item Detail
  Future<Item> getItemDetail(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse(ApiConfig.fullUrl(ApiConfig.itemDetail(id))),
            headers: headers,
          )
          .timeout(ApiConfig.timeout);

      final data = _handleResponse(response);
      return Item.fromJson(data['data']);
    } catch (e) {
      throw Exception('Gagal mengambil detail item: $e');
    }
  }

  // ========== PENGADUAN ENDPOINTS ==========

  /// Get All Pengaduan
  Future<List<Pengaduan>> getPengaduans() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse(ApiConfig.fullUrl(ApiConfig.pengaduan)),
            headers: headers,
          )
          .timeout(ApiConfig.timeout);

      final data = _handleResponse(response);
      return (data['data'] as List)
          .map((json) => Pengaduan.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil pengaduan: $e');
    }
  }

  /// Get Pengaduan by Status
  Future<List<Pengaduan>> getPengaduansByStatus(String status) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse(ApiConfig.fullUrl(ApiConfig.pengaduanByStatus(status))),
            headers: headers,
          )
          .timeout(ApiConfig.timeout);

      final data = _handleResponse(response);
      return (data['data'] as List)
          .map((json) => Pengaduan.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil pengaduan by status: $e');
    }
  }

  /// Get Pengaduan Detail
  Future<Pengaduan> getPengaduanDetail(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse(ApiConfig.fullUrl(ApiConfig.pengaduanDetail(id))),
            headers: headers,
          )
          .timeout(ApiConfig.timeout);

      final data = _handleResponse(response);
      return Pengaduan.fromJson(data['data']);
    } catch (e) {
      throw Exception('Gagal mengambil detail pengaduan: $e');
    }
  }

  /// Create Pengaduan
  Future<Pengaduan> createPengaduan({
    required String namaPengaduan,
    required String deskripsi,
    required String lokasi,
    required int idItem,
    File? foto,
  }) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.fullUrl(ApiConfig.pengaduan)),
      );

      request.headers.addAll(ApiConfig.headersMultipart(token));

      request.fields['nama_pengaduan'] = namaPengaduan;
      request.fields['deskripsi'] = deskripsi;
      request.fields['lokasi'] = lokasi;
      request.fields['id_item'] = idItem.toString();

      if (foto != null) {
        request.files.add(
          await http.MultipartFile.fromPath('foto', foto.path),
        );
      }

      final streamedResponse = await request.send().timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamedResponse);

      final data = _handleResponse(response);
      return Pengaduan.fromJson(data['data']);
    } catch (e) {
      throw Exception('Gagal membuat pengaduan: $e');
    }
  }

  /// Update Pengaduan
  Future<Pengaduan> updatePengaduan({
    required int id,
    String? namaPengaduan,
    String? deskripsi,
    String? lokasi,
    int? idItem,
    File? foto,
  }) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            ApiConfig.fullUrl('${ApiConfig.pengaduanDetail(id)}?_method=PUT')),
      );

      request.headers.addAll(ApiConfig.headersMultipart(token));

      if (namaPengaduan != null)
        request.fields['nama_pengaduan'] = namaPengaduan;
      if (deskripsi != null) request.fields['deskripsi'] = deskripsi;
      if (lokasi != null) request.fields['lokasi'] = lokasi;
      if (idItem != null) request.fields['id_item'] = idItem.toString();

      if (foto != null) {
        request.files.add(
          await http.MultipartFile.fromPath('foto', foto.path),
        );
      }

      final streamedResponse = await request.send().timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamedResponse);

      final data = _handleResponse(response);
      return Pengaduan.fromJson(data['data']);
    } catch (e) {
      throw Exception('Gagal update pengaduan: $e');
    }
  }

  /// Delete Pengaduan
  Future<void> deletePengaduan(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(
            Uri.parse(ApiConfig.fullUrl(ApiConfig.pengaduanDetail(id))),
            headers: headers,
          )
          .timeout(ApiConfig.timeout);

      _handleResponse(response);
    } catch (e) {
      throw Exception('Gagal hapus pengaduan: $e');
    }
  }
}
