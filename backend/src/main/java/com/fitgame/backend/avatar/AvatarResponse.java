package com.fitgame.backend.avatar;

public record AvatarResponse(
        String avatarId,
        String name,
        String baseType,
        String styleType,
        String bodyType,
        String energyState,
        Integer level,
        Integer xp,
        Integer xpToNextLevel,
        AttributeResponse attributes,
        EquipmentResponse equipment
) {
    public static AvatarResponse from(Avatar avatar, AvatarAttributes attributes) {
        return new AvatarResponse(
                avatar.getId().toString(),
                avatar.getName(),
                avatar.getBaseType(),
                avatar.getStyleType(),
                avatar.getBodyType(),
                avatar.getEnergyState(),
                avatar.getLevel(),
                avatar.getXp(),
                avatar.getXpToNextLevel(),
                AttributeResponse.from(attributes),
                EquipmentResponse.from(avatar)
        );
    }
}

