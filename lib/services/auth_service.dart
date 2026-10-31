import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'storage_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthService(
    apiService: apiService,
    storageService: storageService,
  );
});

class AuthService {
  final ApiService apiService;
  final StorageService storageService;

  AuthService({
    required this.apiService,
    required this.storageService,
  });

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await apiService.post(
      AppConstants.login,
      body: {
        'email': email.trim(),
        'password': password,
      },
      auth: false,
    );

    final data = response['data'] as Map<String, dynamic>;
    final authResponse = AuthResponse.fromJson(data);

    if (authResponse.token != null && authResponse.token!.isNotEmpty) {
      await storageService.saveToken(authResponse.token!);
    }

    return authResponse.user;
  }

  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await apiService.post(
      AppConstants.register,
      body: {
        'username': username.trim(),
        'email': email.trim(),
        'password': password,
      },
      auth: false,
    );

    final data = response['data'] as Map<String, dynamic>;
    final authResponse = AuthResponse.fromJson(data);

    if (authResponse.token != null && authResponse.token!.isNotEmpty) {
      await storageService.saveToken(authResponse.token!);
    }

    return authResponse.user;
  }

  Future<UserModel> getMe() async {
    final response = await apiService.get(
      AppConstants.me,
      auth: true,
    );

    final data = response['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  Future<bool> hasStoredToken() async {
    return await storageService.hasToken();
  }

  Future<void> logout() async {
    await storageService.deleteToken();
  }
}
