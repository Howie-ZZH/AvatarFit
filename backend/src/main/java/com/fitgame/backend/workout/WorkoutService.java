package com.fitgame.backend.workout;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fitgame.backend.avatar.*;
import com.fitgame.backend.common.ApiException;
import com.fitgame.backend.user.User;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
public class WorkoutService {
    private final ExerciseRepository exerciseRepository;
    private final WorkoutSessionRepository sessionRepository;
    private final AvatarRepository avatarRepository;
    private final AvatarAttributesRepository attributesRepository;
    private final ObjectMapper objectMapper;

    public WorkoutService(
            ExerciseRepository exerciseRepository,
            WorkoutSessionRepository sessionRepository,
            AvatarRepository avatarRepository,
            AvatarAttributesRepository attributesRepository,
            ObjectMapper objectMapper
    ) {
        this.exerciseRepository = exerciseRepository;
        this.sessionRepository = sessionRepository;
        this.avatarRepository = avatarRepository;
        this.attributesRepository = attributesRepository;
        this.objectMapper = objectMapper;
    }

    @Transactional(readOnly = true)
    public TodayWorkoutResponse today() {
        return TodayWorkoutResponse.from(activeExercises());
    }

    @Transactional
    public WorkoutSessionResponse createSession(User user) {
        var avatar = findAvatar(user);
        var session = sessionRepository.save(new WorkoutSession(user, avatar));
        return WorkoutSessionResponse.from(session, today());
    }

    @Transactional
    public WorkoutCompleteResponse complete(
            User user,
            UUID sessionId,
            CompleteWorkoutRequest request
    ) {
        var session = sessionRepository.findByIdAndUser(sessionId, user)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "训练 session 不存在"));
        if ("completed".equals(session.getStatus())) {
            return completedResponse(session);
        }

        var avatar = session.getAvatar();
        var attributes = findAttributes(avatar);
        var completedExercises = completedExercises(request);
        var durationSeconds = durationSeconds(request, completedExercises);
        var delta = sumAttributeDelta(completedExercises);
        var xpGained = calculateXp(durationSeconds, completedExercises.size());
        var levelBefore = avatar.getLevel();

        attributes.applyDelta(
                delta.strength(),
                delta.endurance(),
                delta.core(),
                delta.flexibility(),
                delta.fatBurn(),
                delta.recovery()
        );
        avatar.applyGrowth(xpGained);
        session.complete(durationSeconds, xpGained, request == null ? null : request.clientRequestId());

        var unlockedItems = unlockedItems(levelBefore, avatar.getLevel());
        var attributeDelta = delta.toResponse();
        var avatarResponse = AvatarResponse.from(avatar, attributes);
        var unityEvent = unityWorkoutCompleteEvent(
                session,
                xpGained,
                levelBefore,
                avatar.getLevel(),
                attributeDelta,
                unlockedItems
        );

        var response = new WorkoutCompleteResponse(
                session.getId().toString(),
                session.getStatus(),
                session.getCompletedAt(),
                session.getDurationSeconds(),
                session.getXpGained(),
                levelBefore,
                avatar.getLevel(),
                attributeDelta,
                unlockedItems,
                avatarResponse,
                unityEvent
        );
        session.saveGrowthResult(writeGrowthResult(response));
        return response;
    }

    private WorkoutCompleteResponse completedResponse(WorkoutSession session) {
        var growthResultJson = session.getGrowthResultJson();
        if (growthResultJson != null && !growthResultJson.isBlank()) {
            try {
                return objectMapper.readValue(growthResultJson, WorkoutCompleteResponse.class);
            } catch (JsonProcessingException ex) {
                throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, "训练完成结果读取失败");
            }
        }

        var avatar = session.getAvatar();
        var attributes = findAttributes(avatar);
        var avatarResponse = AvatarResponse.from(avatar, attributes);
        var emptyDelta = new AttributeResponse(0, 0, 0, 0, 0, 0);
        return new WorkoutCompleteResponse(
                session.getId().toString(),
                session.getStatus(),
                session.getCompletedAt(),
                session.getDurationSeconds(),
                session.getXpGained(),
                avatar.getLevel(),
                avatar.getLevel(),
                emptyDelta,
                List.of(),
                avatarResponse,
                unityWorkoutCompleteEvent(
                        session,
                        session.getXpGained() == null ? 0 : session.getXpGained(),
                        avatar.getLevel(),
                        avatar.getLevel(),
                        emptyDelta,
                        List.of()
                )
        );
    }

    private String writeGrowthResult(WorkoutCompleteResponse response) {
        try {
            return objectMapper.writeValueAsString(response);
        } catch (JsonProcessingException ex) {
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, "训练完成结果保存失败");
        }
    }

    private Avatar findAvatar(User user) {
        return avatarRepository.findByUser(user)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "角色不存在"));
    }

    private AvatarAttributes findAttributes(Avatar avatar) {
        return attributesRepository.findByAvatar(avatar)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "角色属性不存在"));
    }

    private List<Exercise> activeExercises() {
        var exercises = exerciseRepository.findAllByStatusOrderBySortOrderAsc("active");
        if (exercises.isEmpty()) {
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, "今日训练未配置");
        }
        return exercises;
    }

    private List<CompletedExerciseEntry> completedExercises(CompleteWorkoutRequest request) {
        var active = activeExercises();
        if (request == null || request.exercises() == null || request.exercises().isEmpty()) {
            return active.stream()
                    .map(exercise -> new CompletedExerciseEntry(exercise, null))
                    .toList();
        }

        var requestedById = new LinkedHashMap<String, CompletedExerciseRequest>();
        for (var completed : request.exercises()) {
            var exerciseId = completed.exerciseId();
            if (requestedById.putIfAbsent(exerciseId, completed) != null) {
                throw new ApiException(HttpStatus.BAD_REQUEST, "训练动作重复: " + exerciseId);
            }
        }

        var byId = new HashMap<String, Exercise>();
        for (var exercise : active) {
            byId.put(exercise.getId(), exercise);
        }

        var completed = new ArrayList<CompletedExerciseEntry>();
        for (var entry : requestedById.entrySet()) {
            var id = entry.getKey();
            var exercise = byId.get(id);
            if (exercise == null) {
                throw new ApiException(HttpStatus.BAD_REQUEST, "训练动作不存在: " + id);
            }
            completed.add(new CompletedExerciseEntry(exercise, entry.getValue()));
        }
        return completed;
    }

    private int durationSeconds(CompleteWorkoutRequest request, List<CompletedExerciseEntry> completedExercises) {
        var reportedOrPlannedDuration = completedExercises.stream()
                .mapToInt(CompletedExerciseEntry::durationSeconds)
                .sum();
        if (request != null && request.durationSeconds() != null && request.durationSeconds() > 0) {
            return Math.min(request.durationSeconds(), reportedOrPlannedDuration);
        }
        return reportedOrPlannedDuration;
    }

    private AttributeDelta sumAttributeDelta(List<CompletedExerciseEntry> completedExercises) {
        var delta = new AttributeDelta();
        for (var completed : completedExercises) {
            delta.add(completed.exercise());
        }
        return delta;
    }

    private int calculateXp(int durationSeconds, int completedExerciseCount) {
        return Math.max(10, durationSeconds / 2 + Math.max(0, completedExerciseCount - 1));
    }

    private List<UnlockedItemResponse> unlockedItems(int levelBefore, int levelAfter) {
        if (levelAfter > levelBefore) {
            return List.of(new UnlockedItemResponse(
                    "outfit",
                    "starter_gloves",
                    "outfit_starter_gloves",
                    "新手手套"
            ));
        }
        return List.of();
    }

    private UnityEventResponse unityWorkoutCompleteEvent(
            WorkoutSession session,
            int xpGained,
            int levelBefore,
            int levelAfter,
            AttributeResponse attributeDelta,
            List<UnlockedItemResponse> unlockedItems
    ) {
        var payload = new LinkedHashMap<String, Object>();
        payload.put("sessionId", session.getId().toString());
        payload.put("xpGained", xpGained);
        payload.put("levelBefore", levelBefore);
        payload.put("levelAfter", levelAfter);
        payload.put("attributeDelta", Map.of(
                "strength", attributeDelta.strength(),
                "endurance", attributeDelta.endurance(),
                "core", attributeDelta.core(),
                "flexibility", attributeDelta.flexibility(),
                "fatBurn", attributeDelta.fatBurn(),
                "recovery", attributeDelta.recovery()
        ));
        payload.put("unlockedItems", unlockedItems.stream()
                .map(item -> Map.of(
                        "type", item.type(),
                        "id", item.id(),
                        "assetKey", item.assetKey(),
                        "name", item.name()
                ))
                .toList());
        return new UnityEventResponse(
                "WORKOUT_COMPLETE",
                "backend_" + session.getId(),
                payload,
                true,
                null
        );
    }

    private static class AttributeDelta {
        private int strength;
        private int endurance;
        private int core;
        private int flexibility;
        private int fatBurn;
        private int recovery;

        void add(Exercise exercise) {
            strength += exercise.getStrengthImpact();
            endurance += exercise.getEnduranceImpact();
            core += exercise.getCoreImpact();
            flexibility += exercise.getFlexibilityImpact();
            fatBurn += exercise.getFatBurnImpact();
            recovery += exercise.getRecoveryImpact();
        }

        int strength() { return strength; }
        int endurance() { return endurance; }
        int core() { return core; }
        int flexibility() { return flexibility; }
        int fatBurn() { return fatBurn; }
        int recovery() { return recovery; }

        AttributeResponse toResponse() {
            return new AttributeResponse(strength, endurance, core, flexibility, fatBurn, recovery);
        }
    }

    private record CompletedExerciseEntry(Exercise exercise, CompletedExerciseRequest report) {
        int durationSeconds() {
            var plannedDuration = exercise.getDurationSeconds();
            if (report == null || report.durationSeconds() == null) {
                return plannedDuration;
            }
            return Math.min(report.durationSeconds(), plannedDuration);
        }
    }
}
