import '../api/api_client.dart';
import '../api/api_config.dart';
import '../models/onboarding_models.dart';

abstract class AuthService {
  const AuthService();

  Future<AuthSession> register(AuthCredentials credentials);

  Future<AuthSession> login(AuthCredentials credentials);
}

class MockAuthService extends AuthService {
  const MockAuthService();

  @override
  Future<AuthSession> register(AuthCredentials credentials) async {
    return const AuthSession(
      accessToken: 'mock_access_token',
      refreshToken: 'mock_refresh_token',
      expiresIn: 3600,
    );
  }

  @override
  Future<AuthSession> login(AuthCredentials credentials) =>
      register(credentials);
}

class RemoteAuthService extends AuthService {
  const RemoteAuthService(this.apiClient);

  final ApiClient apiClient;

  @override
  Future<AuthSession> register(AuthCredentials credentials) async {
    try {
      final json = await apiClient.postJson(
        '/api/auth/register',
        body: credentials.toRegisterJson(),
      );
      return AuthSession.fromJson(json);
    } on ApiException catch (error) {
      if (error.statusCode != 409) {
        rethrow;
      }
      return login(credentials);
    }
  }

  @override
  Future<AuthSession> login(AuthCredentials credentials) async {
    final json = await apiClient.postJson(
      '/api/auth/login',
      body: credentials.toLoginJson(),
    );
    return AuthSession.fromJson(json);
  }
}

AuthService createAuthService({
  bool useRemote = kUseRemoteApi,
  ApiClient? apiClient,
}) {
  if (!useRemote) {
    return const MockAuthService();
  }
  return RemoteAuthService(apiClient ?? createConfiguredApiClient());
}
