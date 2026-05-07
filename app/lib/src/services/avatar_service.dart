import '../api/api_client.dart';
import '../api/api_config.dart';
import '../models/avatar_models.dart';
import '../models/onboarding_models.dart';

abstract class AvatarService {
  const AvatarService();

  Future<AvatarState> createAvatar(
    CreateAvatarDraft draft, {
    AvatarState current = const AvatarState(),
  });

  Future<AvatarState> getAvatar();
}

class MockAvatarService extends AvatarService {
  const MockAvatarService();

  @override
  Future<AvatarState> createAvatar(
    CreateAvatarDraft draft, {
    AvatarState current = const AvatarState(),
  }) async {
    return draft.toLocalAvatar(current);
  }

  @override
  Future<AvatarState> getAvatar() async {
    return const AvatarState();
  }
}

class RemoteAvatarService extends AvatarService {
  const RemoteAvatarService(this.apiClient);

  final ApiClient apiClient;

  @override
  Future<AvatarState> createAvatar(
    CreateAvatarDraft draft, {
    AvatarState current = const AvatarState(),
  }) async {
    final json = await _createOrGetAvatar(draft);
    return AvatarState.fromJson(json);
  }

  @override
  Future<AvatarState> getAvatar() async {
    final json = await apiClient.getJson('/api/avatars/me');
    return AvatarState.fromJson(json);
  }

  Future<Map<String, Object?>> _createOrGetAvatar(
    CreateAvatarDraft draft,
  ) async {
    try {
      return await apiClient.postJson('/api/avatars', body: draft.toJson());
    } on ApiException catch (error) {
      if (error.statusCode != 409) {
        rethrow;
      }
      return apiClient.getJson('/api/avatars/me');
    }
  }
}

AvatarService createAvatarService({
  String? accessToken,
  bool useRemote = kUseRemoteApi,
  ApiClient? apiClient,
}) {
  if (!useRemote) {
    return const MockAvatarService();
  }
  return RemoteAvatarService(
    apiClient ?? createConfiguredApiClient(accessToken: accessToken),
  );
}
