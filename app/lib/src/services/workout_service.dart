import '../api/api_client.dart';
import '../api/api_config.dart';
import '../models/avatar_models.dart';
import '../models/workout_models.dart';

abstract class WorkoutService {
  const WorkoutService();

  Future<TodayWorkout> getTodayWorkout();

  Future<WorkoutSession> createSession();

  Future<WorkoutCompletion> completeSession(
    String sessionId,
    CompleteWorkoutRequest request,
  );
}

class MockWorkoutService extends WorkoutService {
  const MockWorkoutService({this.initialAvatar = const AvatarState()});

  final AvatarState initialAvatar;

  @override
  Future<TodayWorkout> getTodayWorkout() async => mockTodayWorkout;

  @override
  Future<WorkoutSession> createSession() async {
    return WorkoutSession(
      sessionId: 'local_session_${DateTime.now().millisecondsSinceEpoch}',
      status: 'in_progress',
      startedAt: DateTime.now(),
      workout: mockTodayWorkout,
    );
  }

  @override
  Future<WorkoutCompletion> completeSession(
    String sessionId,
    CompleteWorkoutRequest request,
  ) async {
    const delta = AvatarAttributes(
      strength: 2,
      endurance: 1,
      core: 1,
      flexibility: 1,
      fatBurn: 1,
      recovery: 0,
    );
    final updated = initialAvatar.copyWith(
      level: 2,
      xp: 20,
      xpToNextLevel: 140,
      energyState: 'confident',
      attributes: initialAvatar.attributes.add(delta),
    );
    return WorkoutCompletion(
      sessionId: sessionId,
      status: 'completed',
      completedAt: DateTime.now(),
      durationSeconds: request.durationSeconds ?? 155,
      xpGained: 80,
      levelBefore: initialAvatar.level,
      levelAfter: updated.level,
      attributeDelta: delta,
      avatar: updated,
      unityEvent: WorkoutUnityEvent(
        type: 'WORKOUT_COMPLETE',
        payload: {
          'sessionId': sessionId,
          'xpGained': 80,
          'levelBefore': initialAvatar.level,
          'levelAfter': updated.level,
          'attributeDelta': delta.toJson(),
          'unlockedItems': const [],
        },
      ),
    );
  }
}

class RemoteWorkoutService extends WorkoutService {
  const RemoteWorkoutService(this.apiClient);

  final ApiClient apiClient;

  @override
  Future<TodayWorkout> getTodayWorkout() async {
    final json = await apiClient.getJson('/api/workouts/today');
    return TodayWorkout.fromJson(json);
  }

  @override
  Future<WorkoutSession> createSession() async {
    final json = await apiClient.postJson('/api/workouts/sessions');
    return WorkoutSession.fromJson(json);
  }

  @override
  Future<WorkoutCompletion> completeSession(
    String sessionId,
    CompleteWorkoutRequest request,
  ) async {
    final json = await apiClient.postJson(
      '/api/workouts/sessions/$sessionId/complete',
      body: request.toJson(),
    );
    return WorkoutCompletion.fromJson(json);
  }
}

WorkoutService createWorkoutService({
  AvatarState initialAvatar = const AvatarState(),
  bool useRemote = kUseRemoteApi,
  String? accessToken,
  ApiClient? apiClient,
}) {
  if (!useRemote) {
    return MockWorkoutService(initialAvatar: initialAvatar);
  }
  return RemoteWorkoutService(
    apiClient ?? createConfiguredApiClient(accessToken: accessToken),
  );
}
