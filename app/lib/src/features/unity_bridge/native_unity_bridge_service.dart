import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import '../../models/avatar_models.dart';
import '../../models/workout_models.dart';
import 'unity_bridge_service.dart';
import 'unity_message.dart';

class NativeUnityBridgeService implements UnityBridgeService {
  NativeUnityBridgeService({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  })  : _methodChannel =
            methodChannel ?? const MethodChannel('fitgame/unity_commands'),
        _eventChannel =
            eventChannel ?? const EventChannel('fitgame/unity_events');

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  int _sequence = 0;
  Stream<UnityEvent>? _events;

  @override
  Stream<UnityEvent> get events {
    return _events ??= _eventChannel
        .receiveBroadcastStream()
        .where((event) => event is String)
        .map((event) => UnityEvent.decode(event as String));
  }

  @override
  Future<void> setAvatarState(AvatarState state) {
    return _send('SET_AVATAR_STATE', state.toUnityPayload());
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
    );
  }

  @override
  Future<void> sendUnityEvent(WorkoutUnityEvent event) {
    return _methodChannel.invokeMethod<void>(
      'postMessage',
      jsonEncode(event.toJson()),
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
    );
  }

  @override
  Future<void> changeOutfit(String outfitId) {
    return _send('CHANGE_OUTFIT', {'outfitId': outfitId});
  }

  Future<void> _send(String type, Map<String, Object?> payload) {
    final command = UnityCommand(
      type: type,
      requestId: 'flutter_${++_sequence}',
      payload: payload,
    );
    return _methodChannel.invokeMethod<void>('postMessage', command.encode());
  }

  @override
  Future<void> dispose() async {}
}
