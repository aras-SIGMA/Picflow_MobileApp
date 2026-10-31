/// Standardized exception model for PicFlow API interactions.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final List<String> errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors = const [],
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;
  bool get isServerError => statusCode != null && statusCode! >= 500;

  @override
  String toString() {
    if (errors.isNotEmpty) {
      return '$message: ${errors.join(', ')}';
    }
    return message;
  }
}

/// Specialized exception for network connectivity failures (e.g., USB tunnel not established).
class NetworkConnectionException extends ApiException {
  NetworkConnectionException([String? detail])
      : super(
          message:
              'Tidak dapat terhubung ke server backend PicFlow. '
              'Pastikan server backend berjalan di port 8000 dan jalankan '
              '"adb reverse tcp:8000 tcp:8000" pada terminal jika menggunakan HP fisik via USB.${detail != null ? ' ($detail)' : ''}',
          statusCode: 0,
        );
}
