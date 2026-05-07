package com.fitgame.backend.workout;

import java.util.Map;

public record UnityEventResponse(
        String type,
        String requestId,
        Map<String, Object> payload,
        Boolean success,
        String error
) {
}
