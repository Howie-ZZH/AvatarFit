import 'dart:async';

import 'package:fitgame_app/src/features/training/test_workout_page.dart';
import 'package:fitgame_app/src/features/unity_bridge/unity_bridge_service.dart';
import 'package:fitgame_app/src/features/unity_bridge/unity_message.dart';
import 'package:fitgame_app/src/models/avatar_models.dart';
import 'package:fitgame_app/src/models/workout_models.dart';
import 'package:fitgame_app/src/services/workout_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('training completion forwards backend unity event first',
      (tester) async {
    final unity = _RecordingUnityBridgeService();
    const avatar = AvatarState(name: 'Ada');
    AvatarState? completedAvatar;

    await tester.pumpWidget(
      MaterialApp(
        home: TestWorkoutPage(
          avatar: avatar,
          unity: unity,
          workoutService: const _BackendUnityEventWorkoutService(),
          onCompleted: (avatar) => completedAvatar = avatar,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));

    expect(find.text('测试训练'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('完成训练'), 300);
    await tester.tap(find.text('完成训练'));
    await tester.pump();
    await tester.pump();

    expect(unity.forwardedEvents, hasLength(1));
    expect(unity.workoutCompleteCalls, 0);
    expect(unity.forwardedEvents.single.toJson()['traceId'], 'trace-123');
    expect(
      unity.forwardedEvents.single.payload['newBackendField'],
      {'comboRank': 'S'},
    );
    expect(completedAvatar?.level, 3);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _BackendUnityEventWorkoutService extends WorkoutService {
  const _BackendUnityEventWorkoutService();

  @override
  Future<TodayWorkout> getTodayWorkout() async => const TodayWorkout(
        workoutId: 'workout-1',
        title: '测试训练',
        estimatedDurationSeconds: 10,
        exercises: [
          WorkoutExercise(
            id: 'squat_basic',
            name: '深蹲',
            animationKey: 'workout_squat',
            durationSeconds: 10,
            sets: 1,
            reps: 3,
            instruction: '保持稳定。',
          ),
        ],
      );

  @override
  Future<WorkoutSession> createSession() async => WorkoutSession(
        sessionId: 'session-1',
        status: 'in_progress',
        workout: await getTodayWorkout(),
      );

  @override
  Future<WorkoutCompletion> completeSession(
    String sessionId,
    CompleteWorkoutRequest request,
  ) async {
    return WorkoutCompletion.fromJson({
      'sessionId': sessionId,
      'status': 'completed',
      'durationSeconds': request.durationSeconds,
      'xpGained': 120,
      'levelBefore': 2,
      'levelAfter': 3,
      'attributeDelta': {'strength': 2},
      'avatar': {
        'name': 'Ada',
        'level': 3,
        'xp': 25,
        'attributes': {'strength': 10},
      },
      'unityEvent': {
        'type': 'WORKOUT_COMPLETE',
        'requestId': 'backend-request-1',
        'payload': {
          'sessionId': sessionId,
          'xpGained': 120,
          'newBackendField': {'comboRank': 'S'},
        },
        'success': true,
        'traceId': 'trace-123',
      },
    });
  }
}

class _RecordingUnityBridgeService implements UnityBridgeService {
  final _events = StreamController<UnityEvent>.broadcast();
  final forwardedEvents = <WorkoutUnityEvent>[];
  var workoutCompleteCalls = 0;

  @override
  Stream<UnityEvent> get events => _events.stream;

  @override
  Future<void> changeOutfit(String outfitId) async {}

  @override
  Future<void> dispose() async {
    await _events.close();
  }

  @override
  Future<void> playAnimation(String animationKey, {bool loop = true}) async {}

  @override
  Future<void> sendUnityEvent(WorkoutUnityEvent event) async {
    forwardedEvents.add(event);
  }

  @override
  Future<void> setAvatarState(AvatarState state) async {}

  @override
  Future<void> startExercise(WorkoutExercise exercise) async {}

  @override
  Future<void> workoutComplete({
    required int xpGained,
    required int levelBefore,
    required int levelAfter,
    required AvatarAttributes attributeDelta,
  }) async {
    workoutCompleteCalls += 1;
  }
}
