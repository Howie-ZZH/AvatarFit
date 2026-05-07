import 'package:fitgame_app/src/models/avatar_models.dart';
import 'package:fitgame_app/src/models/onboarding_models.dart';
import 'package:fitgame_app/src/services/auth_service.dart';
import 'package:fitgame_app/src/services/avatar_service.dart';
import 'package:fitgame_app/src/services/profile_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('auth session parses token response', () {
    final session = AuthSession.fromJson({
      'accessToken': 'access-token',
      'refreshToken': 'refresh-token',
      'expiresIn': 3600,
    });

    expect(session.accessToken, 'access-token');
    expect(session.refreshToken, 'refresh-token');
    expect(session.expiresIn, 3600);
  });

  test('mock auth service returns a local session', () async {
    const service = MockAuthService();

    final session = await service.register(
      const AuthCredentials(
        email: 'demo@fitgame.local',
        password: 'password123',
      ),
    );

    expect(session.accessToken, isNotEmpty);
  });

  test('mock profile service preserves onboarding body data', () async {
    const service = MockProfileService();
    const profile = BodyProfileDraft(
      age: 32,
      heightCm: 180,
      weightKg: 75,
      fitnessGoal: '增肌',
      trainingExperience: 'intermediate',
      weeklyTrainingDays: 4,
    );

    final saved = await service.saveProfile(profile);

    expect(saved.age, 32);
    expect(saved.fitnessGoal, '增肌');
    expect(saved.trainingExperience, 'intermediate');
  });

  test('mock avatar service creates from draft and current avatar', () async {
    const service = MockAvatarService();
    const current = AvatarState(name: 'Rex', xp: 12);

    final avatar = await service.createAvatar(
      const CreateAvatarDraft(
        name: 'Ada',
        baseType: 'female',
        styleType: 'balanced',
      ),
      current: current,
    );

    expect(avatar.name, 'Ada');
    expect(avatar.xp, 12);
    expect(avatar.bodyType, 'female');
  });

  test('neutral avatar draft resets local preview body type', () {
    const current = AvatarState(name: 'Rex', bodyType: 'female');

    final avatar = const CreateAvatarDraft(
      name: 'Rex',
      baseType: 'neutral',
      styleType: 'balanced',
    ).toLocalAvatar(current);

    expect(avatar.bodyType, 'normal');
  });
}
