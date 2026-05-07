import 'avatar_models.dart';

class WorkoutExercise {
  const WorkoutExercise({
    required this.id,
    required this.name,
    required this.animationKey,
    required this.durationSeconds,
    required this.sets,
    required this.reps,
    required this.instruction,
  });

  final String id;
  final String name;
  final String animationKey;
  final int durationSeconds;
  final int sets;
  final int reps;
  final String instruction;

  factory WorkoutExercise.fromJson(Map<String, Object?> json) {
    return WorkoutExercise(
      id: _readString(
        json['exerciseId'] ?? json['id'],
        fallback: 'exercise_unknown',
      ),
      name: _readString(json['name'], fallback: '未命名动作'),
      animationKey: _readString(json['animationKey'], fallback: 'idle'),
      durationSeconds: _readInt(json['durationSeconds'], fallback: 30),
      sets: _readInt(json['sets'], fallback: 1),
      reps: _readInt(json['reps'], fallback: 1),
      instruction: _readString(json['instruction'], fallback: ''),
    );
  }

  Map<String, Object?> toJson() => {
        'exerciseId': id,
        'name': name,
        'animationKey': animationKey,
        'durationSeconds': durationSeconds,
        'sets': sets,
        'reps': reps,
        'instruction': instruction,
      };
}

class TodayWorkout {
  const TodayWorkout({
    required this.workoutId,
    required this.title,
    required this.estimatedDurationSeconds,
    required this.exercises,
  });

  final String workoutId;
  final String title;
  final int estimatedDurationSeconds;
  final List<WorkoutExercise> exercises;

  factory TodayWorkout.fromJson(Map<String, Object?> json) {
    final exercises = _readList(json['exercises'])
        .map((item) => WorkoutExercise.fromJson(_readMap(item)))
        .toList(growable: false);
    return TodayWorkout(
      workoutId: _readString(
        json['workoutId'],
        fallback: 'test_3_minute_foundation',
      ),
      title: _readString(json['title'], fallback: '今日训练'),
      estimatedDurationSeconds: _readInt(
        json['estimatedDurationSeconds'],
        fallback: exercises.fold<int>(
          0,
          (duration, exercise) => duration + exercise.durationSeconds,
        ),
      ),
      exercises: exercises,
    );
  }

  Map<String, Object?> toJson() => {
        'workoutId': workoutId,
        'title': title,
        'estimatedDurationSeconds': estimatedDurationSeconds,
        'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
      };
}

class WorkoutSession {
  const WorkoutSession({
    required this.sessionId,
    required this.status,
    this.startedAt,
    this.workout,
  });

  final String sessionId;
  final String status;
  final DateTime? startedAt;
  final TodayWorkout? workout;

  factory WorkoutSession.fromJson(Map<String, Object?> json) {
    return WorkoutSession(
      sessionId: _readString(json['sessionId'], fallback: 'local_session'),
      status: _readString(json['status'], fallback: 'in_progress'),
      startedAt: _readDateTime(json['startedAt']),
      workout: json['workout'] == null
          ? null
          : TodayWorkout.fromJson(_readMap(json['workout'])),
    );
  }
}

class CompletedExercise {
  const CompletedExercise({
    required this.exerciseId,
    required this.durationSeconds,
    required this.setsCompleted,
    required this.repsCompleted,
  });

  final String exerciseId;
  final int durationSeconds;
  final int setsCompleted;
  final int repsCompleted;

  factory CompletedExercise.fromWorkoutExercise(WorkoutExercise exercise) {
    return CompletedExercise(
      exerciseId: exercise.id,
      durationSeconds: exercise.durationSeconds,
      setsCompleted: exercise.sets,
      repsCompleted: exercise.reps,
    );
  }

  Map<String, Object?> toJson() => {
        'exerciseId': exerciseId,
        'durationSeconds': durationSeconds,
        'setsCompleted': setsCompleted,
        'repsCompleted': repsCompleted,
      };
}

class CompleteWorkoutRequest {
  const CompleteWorkoutRequest({
    this.clientRequestId,
    this.durationSeconds,
    this.exercises = const [],
  });

  final String? clientRequestId;
  final int? durationSeconds;
  final List<CompletedExercise> exercises;

  Map<String, Object?> toJson() => {
        if (clientRequestId != null) 'clientRequestId': clientRequestId,
        if (durationSeconds != null) 'durationSeconds': durationSeconds,
        if (exercises.isNotEmpty)
          'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
      };
}

class WorkoutCompletion {
  const WorkoutCompletion({
    required this.sessionId,
    required this.status,
    required this.durationSeconds,
    required this.xpGained,
    required this.levelBefore,
    required this.levelAfter,
    required this.attributeDelta,
    this.completedAt,
    this.avatar,
    this.unityEvent,
  });

  final String sessionId;
  final String status;
  final DateTime? completedAt;
  final int durationSeconds;
  final int xpGained;
  final int levelBefore;
  final int levelAfter;
  final AvatarAttributes attributeDelta;
  final AvatarState? avatar;
  final WorkoutUnityEvent? unityEvent;

  factory WorkoutCompletion.fromJson(Map<String, Object?> json) {
    return WorkoutCompletion(
      sessionId: _readString(json['sessionId'], fallback: 'local_session'),
      status: _readString(json['status'], fallback: 'completed'),
      completedAt: _readDateTime(json['completedAt']),
      durationSeconds: _readInt(json['durationSeconds'], fallback: 0),
      xpGained: _readInt(json['xpGained'], fallback: 0),
      levelBefore: _readInt(json['levelBefore'], fallback: 1),
      levelAfter: _readInt(json['levelAfter'], fallback: 1),
      attributeDelta: AvatarAttributes.fromJson(
        _readMap(json['attributeDelta']),
      ),
      avatar: json['avatar'] == null
          ? null
          : AvatarState.fromJson(_readMap(json['avatar'])),
      unityEvent: json['unityEvent'] == null
          ? null
          : WorkoutUnityEvent.fromJson(_readMap(json['unityEvent'])),
    );
  }
}

class WorkoutUnityEvent {
  const WorkoutUnityEvent({
    required this.type,
    this.requestId,
    this.payload = const {},
    this.success = true,
    this.error,
    Map<String, Object?>? rawJson,
  }) : _rawJson = rawJson;

  final String type;
  final String? requestId;
  final Map<String, Object?> payload;
  final bool success;
  final String? error;
  final Map<String, Object?>? _rawJson;

  factory WorkoutUnityEvent.fromJson(Map<String, Object?> json) {
    final success = json['success'];
    return WorkoutUnityEvent(
      type: _readString(json['type'], fallback: ''),
      requestId: _readNullableString(json['requestId']),
      payload: _readMap(json['payload']),
      success: success is bool ? success : true,
      error: _readNullableString(json['error']),
      rawJson: Map<String, Object?>.unmodifiable(_readMap(json)),
    );
  }

  Map<String, Object?> toJson() {
    final rawJson = _rawJson;
    if (rawJson != null) {
      return rawJson;
    }
    return {
      'type': type,
      if (requestId != null) 'requestId': requestId,
      'payload': payload,
      'success': success,
      if (error != null) 'error': error,
    };
  }
}

const testWorkout = [
  WorkoutExercise(
    id: 'squat_basic',
    name: '深蹲',
    animationKey: 'workout_squat',
    durationSeconds: 45,
    sets: 2,
    reps: 12,
    instruction: '脚跟稳定，膝盖跟随脚尖方向，下蹲后主动站起。',
  ),
  WorkoutExercise(
    id: 'jumping_jack_basic',
    name: '开合跳',
    animationKey: 'workout_jumping_jack',
    durationSeconds: 40,
    sets: 2,
    reps: 20,
    instruction: '保持轻快节奏，落地时膝盖微屈，呼吸不要憋住。',
  ),
  WorkoutExercise(
    id: 'plank_basic',
    name: '平板支撑',
    animationKey: 'workout_plank',
    durationSeconds: 35,
    sets: 1,
    reps: 1,
    instruction: '收紧核心，肩、髋、脚跟保持在一条直线上。',
  ),
  WorkoutExercise(
    id: 'stretch_basic',
    name: '拉伸',
    animationKey: 'workout_stretch',
    durationSeconds: 35,
    sets: 1,
    reps: 1,
    instruction: '放慢动作，保持呼吸，感受大腿后侧和髋部放松。',
  ),
];

final mockTodayWorkout = TodayWorkout(
  workoutId: 'test_3_minute_foundation',
  title: '3 分钟基础测试',
  estimatedDurationSeconds: testWorkout.fold<int>(
    0,
    (duration, exercise) => duration + exercise.durationSeconds,
  ),
  exercises: testWorkout,
);

int _readInt(Object? value, {required int fallback}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return fallback;
}

String _readString(Object? value, {required String fallback}) {
  if (value is String && value.isNotEmpty) {
    return value;
  }
  return fallback;
}

String? _readNullableString(Object? value) {
  return value is String ? value : null;
}

Map<String, Object?> _readMap(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, value) => MapEntry('$key', value));
  }
  return const {};
}

List<Object?> _readList(Object? value) {
  if (value is List<Object?>) {
    return value;
  }
  if (value is List) {
    return value.cast<Object?>();
  }
  return const [];
}

DateTime? _readDateTime(Object? value) {
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}
