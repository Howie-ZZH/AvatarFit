package com.fitgame.backend.avatar;

public record AttributeResponse(
        Integer strength,
        Integer endurance,
        Integer core,
        Integer flexibility,
        Integer fatBurn,
        Integer recovery
) {
    public static AttributeResponse from(AvatarAttributes attributes) {
        return new AttributeResponse(
                attributes.getStrength(),
                attributes.getEndurance(),
                attributes.getCore(),
                attributes.getFlexibility(),
                attributes.getFatBurn(),
                attributes.getRecovery()
        );
    }
}

