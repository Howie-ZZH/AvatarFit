package com.fitgame.backend.workout;

import com.fitgame.backend.user.User;
import jakarta.validation.Valid;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/workouts")
public class WorkoutController {
    private final WorkoutService workoutService;

    public WorkoutController(WorkoutService workoutService) {
        this.workoutService = workoutService;
    }

    @GetMapping("/today")
    TodayWorkoutResponse today() {
        return workoutService.today();
    }

    @PostMapping("/sessions")
    WorkoutSessionResponse createSession(@AuthenticationPrincipal User user) {
        return workoutService.createSession(user);
    }

    @PostMapping("/sessions/{sessionId}/complete")
    WorkoutCompleteResponse complete(
            @AuthenticationPrincipal User user,
            @PathVariable UUID sessionId,
            @Valid @RequestBody(required = false) CompleteWorkoutRequest request
    ) {
        return workoutService.complete(user, sessionId, request);
    }
}
