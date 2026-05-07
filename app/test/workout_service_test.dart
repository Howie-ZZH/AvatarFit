import 'package:fitgame_app/src/models/avatar_models.dart';
import 'package:fitgame_app/src/models/workout_models.dart';
import 'package:fitgame_app/src/services/workout_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses today workout response', () {
    final workout = TodayWorkout.fromJson({
      'workoutId': 'test_3_minute_foundation',
      'title': '3 分钟基础测试',
      'estimatedDurationSeconds': 85,
      'exercises': [
        {
          'exerciseId': 'squat_basic',
          'name': '深蹲',
          'animationKey': 'workout_squat',
          'durationSeconds': 45,
          'sets': 2,
          'reps': 12,
          'instruction': '保持脚跟稳定',
        },
      ],
    });

    expect(workout.workoutId, 'test_3_minute_foundation');
    expect(workout.exercises.single.id, 'squat_basic');
    expect(workout.exercises.single.durationSeconds, 45);
  });

  test('parses completion response avatar and unity event', () {
    final completion = WorkoutCompletion.fromJson({
      'sessionId': 'session-1',
      'status': 'completed',
      'completedAt': '2026-05-06T12:00:00Z',
      'durationSeconds': 155,
      'xpGained': 80,
      'levelBefore': 1,
      'levelAfter': 2,
      'attributeDelta': {
        'strength': 2,
        'endurance': 1,
        'core': 1,
        'flexibility': 1,
        'fatBurn': 1,
        'recovery': 0,
      },
      'avatar': {
        'avatarId': 'avatar-1',
        'name': 'Rex',
        'bodyType': 'normal',
        'energyState': 'confident',
        'level': 2,
        'xp': 20,
        'xpToNextLevel': 140,
        'attributes': {
          'strength': 10,
          'endurance': 9,
          'core': 9,
          'flexibility': 8,
          'fatBurn': 8,
          'recovery': 8,
        },
        'equipment': {
          'outfitId': 'outfit_starter_black',
          'shoesId': 'shoes_basic_01',
        },
      },
      'unityEvent': {
        'type': 'WORKOUT_COMPLETE',
        'payload': {'sessionId': 'session-1'},
      },
    });

    expect(completion.attributeDelta.strength, 2);
    expect(completion.avatar?.level, 2);
    expect(completion.unityEvent?.type, 'WORKOUT_COMPLETE');
  });

  test('preserves backend unity event json for forwarding', () {
    final completion = WorkoutCompletion.fromJson({
      'sessionId': 'session-1',
      'status': 'completed',
      'attributeDelta': const {},
      'unityEvent': {
        'type': 'WORKOUT_COMPLETE',
        'requestId': 'backend-request-1',
        'payload': {
          'sessionId': 'session-1',
          'xpGained': 80,
          'newBackendField': {
            'comboRank': 'S',
            'effects': ['glow', 'confetti'],
          },
        },
        'success': true,
        'traceId': 'trace-123',
      },
    });

    final unityEventJson = completion.unityEvent?.toJson();

    expect(unityEventJson?['requestId'], 'backend-request-1');
    expect(unityEventJson?['traceId'], 'trace-123');
    final payload = unityEventJson?['payload'] as Map<String, Object?>?;
    final backendField = payload?['newBackendField'] as Map<String, Object?>?;
    expect(backendField?['comboRank'], 'S');
    expect(backendField?['effects'], ['glow', 'confetti']);
  });

  test('mock workout service preserves initial avatar during completion',
      () async {
    const avatar = AvatarState(name: 'Ada', xp: 5);
    const service = MockWorkoutService(initialAvatar: avatar);

    final workout = await service.getTodayWorkout();
    final session = await service.createSession();
    final completion = await service.completeSession(
      session.sessionId,
      CompleteWorkoutRequest(
        durationSeconds: workout.estimatedDurationSeconds,
        exercises: workout.exercises
            .map(CompletedExercise.fromWorkoutExercise)
            .toList(growable: false),
      ),
    );

    expect(completion.avatar?.name, 'Ada');
    expect(completion.avatar?.xp, 20);
    expect(completion.xpGained, 80);
  });
}
