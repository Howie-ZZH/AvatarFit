import 'avatar_models.dart';

class AuthCredentials {
  const AuthCredentials({
    required this.email,
    required this.password,
    this.region = 'CN',
    this.language = 'zh-CN',
  });

  final String email;
  final String password;
  final String region;
  final String language;

  Map<String, Object?> toRegisterJson() => {
        'email': email,
        'password': password,
        'region': region,
        'language': language,
      };

  Map<String, Object?> toLoginJson() => {
        'email': email,
        'password': password,
      };
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    this.refreshToken,
    this.expiresIn,
  });

  final String accessToken;
  final String? refreshToken;
  final int? expiresIn;

  factory AuthSession.fromJson(Map<String, Object?> json) {
    return AuthSession(
      accessToken: _readString(json['accessToken'], fallback: ''),
      refreshToken: _readNullableString(json['refreshToken']),
      expiresIn: _readNullableInt(json['expiresIn']),
    );
  }
}

class BodyProfileDraft {
  const BodyProfileDraft({
    this.gender = 'unspecified',
    this.age = 28,
    this.heightCm = 170,
    this.weightKg = 65,
    this.bodyFatPercentage,
    this.fitnessGoal = '减脂',
    this.trainingExperience = 'beginner',
    this.weeklyTrainingDays = 3,
  });

  final String gender;
  final int age;
  final double heightCm;
  final double weightKg;
  final double? bodyFatPercentage;
  final String fitnessGoal;
  final String trainingExperience;
  final int weeklyTrainingDays;

  BodyProfileDraft copyWith({
    String? gender,
    int? age,
    double? heightCm,
    double? weightKg,
    double? bodyFatPercentage,
    String? fitnessGoal,
    String? trainingExperience,
    int? weeklyTrainingDays,
  }) {
    return BodyProfileDraft(
      gender: gender ?? this.gender,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      trainingExperience: trainingExperience ?? this.trainingExperience,
      weeklyTrainingDays: weeklyTrainingDays ?? this.weeklyTrainingDays,
    );
  }

  Map<String, Object?> toJson() => {
        'gender': gender,
        'age': age,
        'heightCm': heightCm,
        'weightKg': weightKg,
        if (bodyFatPercentage != null) 'bodyFatPercentage': bodyFatPercentage,
        'fitnessGoal': fitnessGoal,
        'trainingExperience': trainingExperience,
        'weeklyTrainingDays': weeklyTrainingDays,
      };

  factory BodyProfileDraft.fromJson(Map<String, Object?> json) {
    return BodyProfileDraft(
      gender: _readString(json['gender'], fallback: 'unspecified'),
      age: _readInt(json['age'], fallback: 28),
      heightCm: _readDouble(json['heightCm'], fallback: 170),
      weightKg: _readDouble(json['weightKg'], fallback: 65),
      bodyFatPercentage: _readNullableDouble(json['bodyFatPercentage']),
      fitnessGoal: _readString(json['fitnessGoal'], fallback: '减脂'),
      trainingExperience: _readString(
        json['trainingExperience'],
        fallback: 'beginner',
      ),
      weeklyTrainingDays: _readInt(json['weeklyTrainingDays'], fallback: 3),
    );
  }
}

class CreateAvatarDraft {
  const CreateAvatarDraft({
    required this.name,
    this.baseType = 'neutral',
    this.styleType = 'balanced',
  });

  final String name;
  final String baseType;
  final String styleType;

  Map<String, Object?> toJson() => {
        'name': name,
        'baseType': baseType,
        'styleType': styleType,
      };

  AvatarState toLocalAvatar(AvatarState current) {
    return current.copyWith(
      name: name,
      bodyType: baseType == 'neutral' ? 'normal' : baseType,
    );
  }
}

int _readInt(Object? value, {required int fallback}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return fallback;
}

int? _readNullableInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return null;
}

double _readDouble(Object? value, {required double fallback}) {
  if (value is num) {
    return value.toDouble();
  }
  return fallback;
}

double? _readNullableDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  return null;
}

String _readString(Object? value, {required String fallback}) {
  if (value is String && value.isNotEmpty) {
    return value;
  }
  return fallback;
}

String? _readNullableString(Object? value) {
  if (value is String && value.isNotEmpty) {
    return value;
  }
  return null;
}
