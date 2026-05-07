package com.fitgame.backend.workout;

import java.util.List;

public record TodayWorkoutResponse(
        String workoutId,
        String title,
        Integer estimatedDurationSeconds,
        List<WorkoutExerciseResponse> exercises
) {
    static TodayWorkoutResponse from(List<Exercise> exercises) {
        var duration = exercises.stream()
                .mapToInt(Exercise::getDurationSeconds)
                .sum();
        return new TodayWorkoutResponse(
                "test_3_minute_foundation",
                "3 分钟基础测试",
                duration,
                exercises.stream().map(WorkoutExerciseResponse::from).toList()
        );
    }
}
