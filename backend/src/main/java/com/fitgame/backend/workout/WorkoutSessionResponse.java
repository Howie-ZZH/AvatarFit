package com.fitgame.backend.workout;

import java.time.Instant;

public record WorkoutSessionResponse(
        String sessionId,
        String status,
        Instant startedAt,
        TodayWorkoutResponse workout
) {
    static WorkoutSessionResponse from(WorkoutSession session, TodayWorkoutResponse workout) {
        return new WorkoutSessionResponse(
                session.getId().toString(),
                session.getStatus(),
                session.getStartedAt(),
                workout
        );
    }
}
