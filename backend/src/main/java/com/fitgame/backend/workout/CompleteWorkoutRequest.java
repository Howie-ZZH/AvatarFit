package com.fitgame.backend.workout;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import java.util.List;

public record CompleteWorkoutRequest(
        @Size(max = 128)
        String clientRequestId,
        @Positive
        Integer durationSeconds,
        @Size(min = 1, max = 32)
        List<@NotNull @Valid CompletedExerciseRequest> exercises
) {
}
