package com.fitgame.backend.avatar;

public record EquipmentResponse(
        String outfitId,
        String shoesId,
        String accessoryId
) {
    public static EquipmentResponse from(Avatar avatar) {
        return new EquipmentResponse(
                avatar.getCurrentOutfitId(),
                avatar.getCurrentShoesId(),
                avatar.getCurrentAccessoryId()
        );
    }
}

