package com.fitgame.backend.workout;

public record WorkoutExerciseResponse(
        String exerciseId,
        String name,
        String animationKey,
        Integer durationSeconds,
        Integer sets,
        Integer reps,
        String instruction
) {
    static WorkoutExerciseResponse from(Exercise exercise) {
        return new WorkoutExerciseResponse(
                exercise.getId(),
                exercise.getName(),
                exercise.getAnimationKey(),
                exercise.getDurationSeconds(),
                exercise.getDefaultSets(),
                exercise.getDefaultReps(),
                exercise.getInstruction()
        );
    }
}
