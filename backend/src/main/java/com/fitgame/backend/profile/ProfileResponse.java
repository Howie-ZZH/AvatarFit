package com.fitgame.backend.profile;

import java.math.BigDecimal;

public record ProfileResponse(
        String profileId,
        String userId,
        String gender,
        Integer age,
        BigDecimal heightCm,
        BigDecimal weightKg,
        BigDecimal bodyFatPercentage,
        String fitnessGoal,
        String trainingExperience,
        Integer weeklyTrainingDays
) {
    public static ProfileResponse from(UserProfile profile) {
        return new ProfileResponse(
                profile.getId().toString(),
                profile.getUser().getId().toString(),
                profile.getGender(),
                profile.getAge(),
                profile.getHeightCm(),
                profile.getWeightKg(),
                profile.getBodyFatPercentage(),
                profile.getFitnessGoal(),
                profile.getTrainingExperience(),
                profile.getWeeklyTrainingDays()
        );
    }
}

