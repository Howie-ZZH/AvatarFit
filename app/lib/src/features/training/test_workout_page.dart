import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/avatar_models.dart';
import '../../models/workout_models.dart';
import '../../services/workout_service.dart';
import '../unity_bridge/unity_avatar_view.dart';
import '../unity_bridge/unity_bridge_service.dart';

class TestWorkoutPage extends StatefulWidget {
  TestWorkoutPage({
    super.key,
    required this.avatar,
    required this.unity,
    required this.onCompleted,
    WorkoutService? workoutService,
  }) : workoutService =
            workoutService ?? MockWorkoutService(initialAvatar: avatar);

  final AvatarState avatar;
  final UnityBridgeService unity;
  final ValueChanged<AvatarState> onCompleted;
  final WorkoutService workoutService;

  @override
  State<TestWorkoutPage> createState() => _TestWorkoutPageState();
}

class _TestWorkoutPageState extends State<TestWorkoutPage> {
  var _index = 0;
  var _remaining = 0;
  Timer? _timer;
  bool _paused = false;
  bool _completing = false;
  TodayWorkout? _workout;
  WorkoutSession? _session;
  Object? _loadError;

  WorkoutExercise get _current => _workout!.exercises[_index];
  List<WorkoutExercise> get _exercises => _workout?.exercises ?? const [];

  @override
  void initState() {
    super.initState();
    _loadWorkout();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadWorkout() async {
    try {
      final workout = await widget.workoutService.getTodayWorkout();
      final session = await widget.workoutService.createSession();
      final loadedWorkout = session.workout ?? workout;
      if (loadedWorkout.exercises.isEmpty) {
        throw const FormatException('Today workout has no exercises.');
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _workout = loadedWorkout;
        _session = session;
        _index = 0;
        _remaining = _exercises.first.durationSeconds;
        _loadError = null;
        _completing = false;
      });
      _startCurrentExercise();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _loadError = error);
    }
  }

  void _startCurrentExercise() {
    _timer?.cancel();
    _remaining = _current.durationSeconds;
    widget.unity.startExercise(_current);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_paused) {
        return;
      }
      if (_remaining <= 1) {
        _nextExercise();
      } else {
        setState(() => _remaining -= 1);
      }
    });
  }

  void _nextExercise() {
    if (_index == _exercises.length - 1) {
      _completeWorkout();
      return;
    }
    setState(() {
      _index += 1;
      _remaining = _exercises[_index].durationSeconds;
    });
    _startCurrentExercise();
  }

  Future<void> _completeWorkout() async {
    if (_completing || _session == null || _workout == null) {
      return;
    }
    setState(() => _completing = true);
    _timer?.cancel();
    final completedExercises = _exercises
        .map(CompletedExercise.fromWorkoutExercise)
        .toList(growable: false);
    final durationSeconds = completedExercises.fold<int>(
      0,
      (duration, exercise) => duration + exercise.durationSeconds,
    );
    final request = CompleteWorkoutRequest(
      clientRequestId: 'workout_${DateTime.now().millisecondsSinceEpoch}',
      durationSeconds: durationSeconds,
      exercises: completedExercises,
    );
    try {
      final completion = await widget.workoutService.completeSession(
        _session!.sessionId,
        request,
      );
      final updated = completion.avatar ??
          widget.avatar.copyWith(
            level: completion.levelAfter,
            xp: widget.avatar.xp + completion.xpGained,
            energyState: 'confident',
            attributes: widget.avatar.attributes.add(completion.attributeDelta),
          );
      final unityEvent = completion.unityEvent;
      if (unityEvent != null) {
        await widget.unity.sendUnityEvent(unityEvent);
      } else {
        await widget.unity.workoutComplete(
          xpGained: completion.xpGained,
          levelBefore: completion.levelBefore,
          levelAfter: completion.levelAfter,
          attributeDelta: completion.attributeDelta,
        );
      }
      widget.onCompleted(updated);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _completing = false;
        _loadError = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadError != null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 42),
                  const SizedBox(height: 12),
                  Text(
                    '训练加载失败',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_loadError',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: _loadWorkout,
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_workout == null || _exercises.isEmpty) {
      return const Scaffold(
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final progress =
        (_current.durationSeconds - _remaining) / _current.durationSeconds;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            UnityAvatarView(
              avatar: widget.avatar,
              animationKey: _current.animationKey,
              compact: true,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                children: [
                  Text(
                    _workout!.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '动作 ${_index + 1}/${_exercises.length}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _current.name,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(_current.instruction),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _Metric(
                          label: '倒计时',
                          value: '$_remaining 秒',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Metric(
                          label: '组数 / 次数',
                          value: '${_current.sets} 组 / ${_current.reps}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => setState(() => _paused = !_paused),
                          icon: Icon(
                            _paused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                          ),
                          label: Text(_paused ? '继续' : '暂停'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _completing ? null : _nextExercise,
                          icon: const Icon(Icons.skip_next_rounded),
                          label: const Text('跳过'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _completing ? null : _completeWorkout,
                    icon: const Icon(Icons.check_rounded),
                    label: Text(_completing ? '提交中' : '完成训练'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF10141B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF252B36)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 6),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
