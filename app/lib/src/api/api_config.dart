import 'api_client.dart';

const bool kUseRemoteApi = bool.fromEnvironment('FITGAME_USE_REMOTE_API');

const String kApiBaseUrl = String.fromEnvironment(
  'FITGAME_API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);

const String kStaticAccessToken = String.fromEnvironment(
  'FITGAME_ACCESS_TOKEN',
);

const bool kUseNativeUnityView = bool.fromEnvironment(
  'FITGAME_USE_NATIVE_UNITY',
);

ApiClient createConfiguredApiClient({String? accessToken}) {
  final token = accessToken ?? kStaticAccessToken;
  return ApiClient(
    baseUri: Uri.parse(kApiBaseUrl),
    accessToken: token.isEmpty ? null : token,
  );
}
