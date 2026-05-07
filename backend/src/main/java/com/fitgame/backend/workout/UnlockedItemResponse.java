package com.fitgame.backend.workout;

public record UnlockedItemResponse(
        String type,
        String id,
        String assetKey,
        String name
) {
}
