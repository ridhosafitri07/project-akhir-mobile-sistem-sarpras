// lib/config/api_config.dart

class ApiConfig {
  // ⚠️ GANTI baseUrl INI SESUAI DENGAN BACKEND ANDA
  // Contoh: 
  // - Lokal PC: 'http://127.0.0.1:8000/api/v1'
  // - Emulator Android: 'http://10.0.2.2:8000/api/v1'
  // - Real Device (same network): 'http://192.168.43.46:8000/api/v1'
  static const String baseUrl = 'http://192.168.43.46:8000/api/v1';
  
  // Storage Base URL (untuk menampilkan foto)
  static const String storageUrl = 'http://192.168.43.46:8000/storage';

  // Timeout
  static const Duration timeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ========== AUTH ENDPOINTS ==========
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String user = '/user';

  // ========== PROFILE ENDPOINTS ==========
  static const String profile = '/profile';
  static const String profileUpdate = '/profile/update';
  static const String profileUpdatePhoto = '/profile/update-photo';
  static const String profileChangePassword = '/profile/change-password';

  // ========== ITEM ENDPOINTS ==========
  static const String items = '/items';
  static String itemDetail(int id) => '/items/$id';

  // ========== PENGADUAN ENDPOINTS ==========
  static const String pengaduan = '/pengaduan';
  static String pengaduanDetail(int id) => '/pengaduan/$id';
  static String pengaduanByStatus(String status) => '/pengaduan/status/$status';

  // ========== HELPER METHODS ==========
  
  /// Get full URL dari endpoint
  static String fullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  /// Get full storage URL untuk foto
  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    
    // Jika sudah full URL, return as is
    if (path.startsWith('http')) return path;
    
    // Jika path storage
    return '$storageUrl/$path';
  }

  /// Headers dengan token
  static Map<String, String> headersWithToken(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Headers tanpa token
  static Map<String, String> headersWithoutToken() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Headers untuk multipart (upload file)
  static Map<String, String> headersMultipart(String token) {
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
class ApiResponseCode {
  static const int success = 200;
  static const int created = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int validationError = 422;
  static const int serverError = 500;
  static const int noInternet = 0;
}

// ========== API ERROR MESSAGES ==========
class ApiErrorMessages {
  static const String noInternet = 'Tidak ada koneksi internet';
  static const String timeout = 'Request timeout, silakan coba lagi';
  static const String serverError = 'Terjadi kesalahan pada server';
  static const String unknownError = 'Terjadi kesalahan tidak diketahui';
  static const String unauthorized = 'Sesi Anda telah berakhir, silakan login kembali';
}

// ========== STATUS PENGADUAN ==========
class PengaduanStatus {
  static const String pending = 'pending';      // Diajukan
  static const String proses = 'proses';        // Diproses
  static const String selesai = 'selesai';      // Disetujui/Selesai
  static const String ditolak = 'ditolak';      // Ditolak

  static String getLabel(String status) {
    switch (status.toLowerCase()) {
      case pending:
        return 'Menunggu';
      case proses:
        return 'Diproses';
      case selesai:
        return 'Selesai';
      case ditolak:
        return 'Ditolak';
      default:
        return status;
    }
  }
}