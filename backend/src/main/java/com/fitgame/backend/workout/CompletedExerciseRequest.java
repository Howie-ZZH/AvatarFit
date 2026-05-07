package com.fitgame.backend.workout;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;

public record CompletedExerciseRequest(
        @NotBlank
        String exerciseId,
        @Positive
        Integer durationSeconds,
        @Positive
        Integer setsCompleted,
        @Positive
        Integer repsCompleted
) {
}
