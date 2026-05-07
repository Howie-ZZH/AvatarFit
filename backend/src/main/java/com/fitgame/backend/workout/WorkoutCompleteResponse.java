package com.fitgame.backend.workout;

import com.fitgame.backend.avatar.AttributeResponse;
import com.fitgame.backend.avatar.AvatarResponse;

import java.time.Instant;
import java.util.List;

public record WorkoutCompleteResponse(
        String sessionId,
        String status,
        Instant completedAt,
        Integer durationSeconds,
        Integer xpGained,
        Integer levelBefore,
        Integer levelAfter,
        AttributeResponse attributeDelta,
        List<UnlockedItemResponse> unlockedItems,
        AvatarResponse avatar,
        UnityEventResponse unityEvent
) {
}
