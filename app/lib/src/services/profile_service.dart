import '../api/api_client.dart';
import '../api/api_config.dart';
import '../models/onboarding_models.dart';

abstract class ProfileService {
  const ProfileService();

  Future<BodyProfileDraft> saveProfile(BodyProfileDraft profile);

  Future<BodyProfileDraft> getProfile();
}

class MockProfileService extends ProfileService {
  const MockProfileService();

  @override
  Future<BodyProfileDraft> saveProfile(BodyProfileDraft profile) async {
    return profile;
  }

  @override
  Future<BodyProfileDraft> getProfile() async {
    return const BodyProfileDraft();
  }
}

class RemoteProfileService extends ProfileService {
  const RemoteProfileService(this.apiClient);

  final ApiClient apiClient;

  @override
  Future<BodyProfileDraft> saveProfile(BodyProfileDraft profile) async {
    final json = await _createOrUpdateProfile(profile);
    return BodyProfileDraft.fromJson(json);
  }

  @override
  Future<BodyProfileDraft> getProfile() async {
    final json = await apiClient.getJson('/api/profiles/me');
    return BodyProfileDraft.fromJson(json);
  }

  Future<Map<String, Object?>> _createOrUpdateProfile(
    BodyProfileDraft profile,
  ) async {
    try {
      return await apiClient.postJson('/api/profiles', body: profile.toJson());
    } on ApiException catch (error) {
      if (error.statusCode != 409) {
        rethrow;
      }
      return apiClient.putJson('/api/profiles/me', body: profile.toJson());
    }
  }
}

ProfileService createProfileService({
  String? accessToken,
  bool useRemote = kUseRemoteApi,
  ApiClient? apiClient,
}) {
  if (!useRemote) {
    return const MockProfileService();
  }
  return RemoteProfileService(
    apiClient ?? createConfiguredApiClient(accessToken: accessToken),
  );
}
