import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import '../../models/avatar_models.dart';
import '../../models/workout_models.dart';
import 'unity_message.dart';

abstract class UnityBridgeService {
  Stream<UnityEvent> get events;

  Future<void> setAvatarState(AvatarState state);
  Future<void> playAnimation(String animationKey, {bool loop = true});
  Future<void> startExercise(WorkoutExercise exercise);
  Future<void> sendUnityEvent(WorkoutUnityEvent event);
  Future<void> workoutComplete({
    required int xpGained,
    required int levelBefore,
    required int levelAfter,
    required AvatarAttributes attributeDelta,
  });
  Future<void> changeOutfit(String outfitId);
  Future<void> dispose();
}

class MockUnityBridgeService implements UnityBridgeService {
  final _events = StreamController<UnityEvent>.broadcast();
  int _sequence = 0;

  @override
  Stream<UnityEvent> get events => _events.stream;

  @override
  Future<void> setAvatarState(AvatarState state) {
    return _send(
      'SET_AVATAR_STATE',
      state.toUnityPayload(),
      eventType: 'UNITY_READY',
    );
  }

  @override
  Future<void> playAnimation(String animationKey, {bool loop = true}) {
    return _send(
      'PLAY_ANIMATION',
      {
        'animationKey': animationKey,
        'loop': loop,
        'transitionSeconds': 0.2,
      },
      eventType: 'ANIMATION_STARTED',
    );
  }

  @override
  Future<void> startExercise(WorkoutExercise exercise) {
    return _send(
      'START_EXERCISE',
      {
        'exerciseId': exercise.id,
        'animationKey': exercise.animationKey,
        'durationSeconds': exercise.durationSeconds,
        'sets': exercise.sets,
        'reps': exercise.reps,
      },
      eventType: 'ANIMATION_STARTED',
    );
  }

  @override
  Future<void> sendUnityEvent(WorkoutUnityEvent event) async {
    log(jsonEncode(event.toJson()), name: 'UnityBridge');
    await Future<void>.delayed(const Duration(milliseconds: 160));
    _events.add(
      UnityEvent(
        type: 'ANIMATION_FINISHED',
        requestId: event.requestId ?? 'flutter_${++_sequence}',
        payload: event.payload,
        success: event.success,
        error: event.error,
      ),
    );
  }

  @override
  Future<void> workoutComplete({
    required int xpGained,
    required int levelBefore,
    required int levelAfter,
    required AvatarAttributes attributeDelta,
  }) {
    return _send(
      'WORKOUT_COMPLETE',
      {
        'xpGained': xpGained,
        'levelBefore': levelBefore,
        'levelAfter': levelAfter,
        'attributeDelta': attributeDelta.toJson(),
        'unlockedItems': [
          {
            'type': 'outfit',
            'id': 'starter_gloves',
            'assetKey': 'outfit_starter_gloves',
          },
        ],
      },
      eventType: 'ANIMATION_FINISHED',
    );
  }

  @override
  Future<void> changeOutfit(String outfitId) {
    return _send(
      'CHANGE_OUTFIT',
      {'outfitId': outfitId},
      eventType: 'OUTFIT_CHANGED',
    );
  }

  Future<void> _send(
    String type,
    Map<String, Object?> payload, {
    required String eventType,
  }) async {
    final requestId = 'flutter_${++_sequence}';
    final command = UnityCommand(
      type: type,
      requestId: requestId,
      payload: payload,
    );
    log(command.encode(), name: 'UnityBridge');
    await Future<void>.delayed(const Duration(milliseconds: 160));
    _events.add(
      UnityEvent(
        type: eventType,
        requestId: requestId,
        payload: payload,
        success: true,
      ),
    );
  }

  @override
  Future<void> dispose() async {
    await _events.close();
  }
}
