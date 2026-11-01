/// Network and API constants for PicFlow Mobile.
/// Connects to Express backend over local HTTP / USB reverse proxy (`adb reverse tcp:8000 tcp:8000`).
class AppConstants {
  AppConstants._();

  static const String baseUrl = 'http://localhost:8000/api';
  static const String fileBaseUrl = 'http://localhost:8000';

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String profile = '/auth/profile';

  // Category endpoints
  static const String categories = '/categories';

  // Photo endpoints
  static const String photos = '/photos';
  static String photoDetail(dynamic id) => '/photos/$id';
  static String photoLike(dynamic id) => '/photos/$id/like';

  // User endpoints
  static String userProfile(dynamic idOrUsername) => '/users/$idOrUsername';

  /// Resolves relative image paths (e.g., `/uploads/xyz.jpg`) into full URLs.
  static String resolveImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final cleanPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$fileBaseUrl$cleanPath';
  }
}
