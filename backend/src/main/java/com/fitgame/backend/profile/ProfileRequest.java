package com.fitgame.backend.profile;

import jakarta.validation.constraints.*;

import java.math.BigDecimal;

public record ProfileRequest(
        String gender,
        @Min(13) @Max(100) Integer age,
        @DecimalMin("80.0") @DecimalMax("230.0") BigDecimal heightCm,
        @DecimalMin("25.0") @DecimalMax("250.0") BigDecimal weightKg,
        @DecimalMin("1.0") @DecimalMax("60.0") BigDecimal bodyFatPercentage,
        @NotBlank String fitnessGoal,
        @NotBlank String trainingExperience,
        @NotNull @Min(0) @Max(7) Integer weeklyTrainingDays
) {
}

