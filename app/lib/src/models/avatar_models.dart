class AvatarAttributes {
  const AvatarAttributes({
    this.strength = 8,
    this.endurance = 8,
    this.core = 8,
    this.flexibility = 7,
    this.fatBurn = 7,
    this.recovery = 8,
  });

  final int strength;
  final int endurance;
  final int core;
  final int flexibility;
  final int fatBurn;
  final int recovery;

  factory AvatarAttributes.fromJson(Map<String, Object?> json) {
    return AvatarAttributes(
      strength: _readInt(json['strength'], fallback: 8),
      endurance: _readInt(json['endurance'], fallback: 8),
      core: _readInt(json['core'], fallback: 8),
      flexibility: _readInt(json['flexibility'], fallback: 7),
      fatBurn: _readInt(json['fatBurn'], fallback: 7),
      recovery: _readInt(json['recovery'], fallback: 8),
    );
  }

  Map<String, int> toJson() => {
        'strength': strength,
        'endurance': endurance,
        'core': core,
        'flexibility': flexibility,
        'fatBurn': fatBurn,
        'recovery': recovery,
      };

  AvatarAttributes add(AvatarAttributes delta) {
    return AvatarAttributes(
      strength: strength + delta.strength,
      endurance: endurance + delta.endurance,
      core: core + delta.core,
      flexibility: flexibility + delta.flexibility,
      fatBurn: fatBurn + delta.fatBurn,
      recovery: recovery + delta.recovery,
    );
  }
}

class AvatarState {
  const AvatarState({
    this.avatarId = 'avatar_local_001',
    this.name = 'Rex',
    this.level = 1,
    this.xp = 0,
    this.xpToNextLevel = 122,
    this.bodyType = 'normal',
    this.energyState = 'normal',
    this.outfitId = 'outfit_starter_black',
    this.shoesId = 'shoes_basic_01',
    this.attributes = const AvatarAttributes(),
  });

  final String avatarId;
  final String name;
  final int level;
  final int xp;
  final int xpToNextLevel;
  final String bodyType;
  final String energyState;
  final String outfitId;
  final String shoesId;
  final AvatarAttributes attributes;

  factory AvatarState.fromJson(Map<String, Object?> json) {
    final equipment = _readMap(json['equipment']);
    return AvatarState(
      avatarId: _readString(json['avatarId'], fallback: 'avatar_local_001'),
      name: _readString(json['name'], fallback: 'Rex'),
      level: _readInt(json['level'], fallback: 1),
      xp: _readInt(json['xp'], fallback: 0),
      xpToNextLevel: _readInt(json['xpToNextLevel'], fallback: 122),
      bodyType: _readString(json['bodyType'], fallback: 'normal'),
      energyState: _readString(json['energyState'], fallback: 'normal'),
      outfitId: _readString(
        equipment['outfitId'],
        fallback: 'outfit_starter_black',
      ),
      shoesId: _readString(equipment['shoesId'], fallback: 'shoes_basic_01'),
      attributes: AvatarAttributes.fromJson(_readMap(json['attributes'])),
    );
  }

  Map<String, Object?> toUnityPayload() => {
        'avatarId': avatarId,
        'name': name,
        'level': level,
        'xp': xp,
        'xpToNextLevel': xpToNextLevel,
        'bodyType': bodyType,
        'energyState': energyState,
        'attributes': attributes.toJson(),
        'equipment': {
          'outfitId': outfitId,
          'shoesId': shoesId,
          'accessoryId': null,
        },
      };

  AvatarState copyWith({
    String? avatarId,
    String? name,
    int? level,
    int? xp,
    int? xpToNextLevel,
    String? bodyType,
    String? energyState,
    String? outfitId,
    String? shoesId,
    AvatarAttributes? attributes,
  }) {
    return AvatarState(
      avatarId: avatarId ?? this.avatarId,
      name: name ?? this.name,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      bodyType: bodyType ?? this.bodyType,
      energyState: energyState ?? this.energyState,
      outfitId: outfitId ?? this.outfitId,
      shoesId: shoesId ?? this.shoesId,
      attributes: attributes ?? this.attributes,
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

String _readString(Object? value, {required String fallback}) {
  if (value is String && value.isNotEmpty) {
    return value;
  }
  return fallback;
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
