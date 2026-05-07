package com.fitgame.backend.onboarding;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.greaterThan;
import static org.hamcrest.Matchers.not;
import static org.hamcrest.Matchers.isEmptyOrNullString;
import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class OnboardingFlowTests {
    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void protectsProfileAvatarAndWorkoutEndpoints() throws Exception {
        mockMvc.perform(get("/api/profiles/me"))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(get("/api/avatars/me"))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(post("/api/workouts/sessions"))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(get("/api/users/me")
                        .header("Authorization", "Bearer invalid-token"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void supportsFlutterFirstDayOnboardingAndTrainingFlow() throws Exception {
        var email = "onboarding-" + System.nanoTime() + "@example.com";
        var registerJson = mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "email": "%s",
                                  "password": "password123",
                                  "region": "CN",
                                  "language": "zh-CN"
                                }
                                """.formatted(email)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.accessToken", not(isEmptyOrNullString())))
                .andExpect(jsonPath("$.refreshToken", not(isEmptyOrNullString())))
                .andExpect(jsonPath("$.expiresIn", greaterThan(0)))
                .andReturn()
                .getResponse()
                .getContentAsString();
        var registerToken = objectMapper.readTree(registerJson).get("accessToken").asText();

        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "email": "%s",
                                  "password": "password123",
                                  "region": "CN",
                                  "language": "zh-CN"
                                }
                                """.formatted(email.toUpperCase())))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.status").value(409))
                .andExpect(jsonPath("$.message").value("邮箱已注册"));

        var loginJson = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "email": "%s",
                                  "password": "password123"
                                }
                                """.formatted(email)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.accessToken", not(isEmptyOrNullString())))
                .andExpect(jsonPath("$.refreshToken", not(isEmptyOrNullString())))
                .andExpect(jsonPath("$.expiresIn", greaterThan(0)))
                .andReturn()
                .getResponse()
                .getContentAsString();
        var loginToken = objectMapper.readTree(loginJson).get("accessToken").asText();

        mockMvc.perform(get("/api/users/me")
                        .header("Authorization", "Bearer " + registerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.userId", not(isEmptyOrNullString())))
                .andExpect(jsonPath("$.email").value(email))
                .andExpect(jsonPath("$.region").value("CN"))
                .andExpect(jsonPath("$.language").value("zh-CN"));

        mockMvc.perform(get("/api/profiles/me")
                        .header("Authorization", "Bearer " + loginToken))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("身体档案不存在"));

        mockMvc.perform(post("/api/profiles")
                        .header("Authorization", "Bearer " + loginToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(profileRequest()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.profileId", not(isEmptyOrNullString())))
                .andExpect(jsonPath("$.userId", not(isEmptyOrNullString())))
                .andExpect(jsonPath("$.fitnessGoal").value("muscle_gain"))
                .andExpect(jsonPath("$.trainingExperience").value("beginner"))
                .andExpect(jsonPath("$.weeklyTrainingDays").value(3));

        mockMvc.perform(post("/api/profiles")
                        .header("Authorization", "Bearer " + loginToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(profileRequest()))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.status").value(409))
                .andExpect(jsonPath("$.message").value("身体档案已存在"));

        mockMvc.perform(get("/api/avatars/me")
                        .header("Authorization", "Bearer " + loginToken))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("角色不存在"));

        mockMvc.perform(post("/api/avatars")
                        .header("Authorization", "Bearer " + loginToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "name": "Rex",
                                  "baseType": "neutral",
                                  "styleType": "balanced"
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.avatarId", not(isEmptyOrNullString())))
                .andExpect(jsonPath("$.name").value("Rex"))
                .andExpect(jsonPath("$.bodyType").value("normal"))
                .andExpect(jsonPath("$.energyState").value("normal"))
                .andExpect(jsonPath("$.level").value(1))
                .andExpect(jsonPath("$.xp").value(0))
                .andExpect(jsonPath("$.xpToNextLevel", greaterThan(0)))
                .andExpect(jsonPath("$.attributes.strength").value(5))
                .andExpect(jsonPath("$.equipment.outfitId").value("outfit_starter_black"));

        mockMvc.perform(post("/api/avatars")
                        .header("Authorization", "Bearer " + loginToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "name": "Rex",
                                  "baseType": "neutral",
                                  "styleType": "balanced"
                                }
                                """))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.status").value(409))
                .andExpect(jsonPath("$.message").value("角色已存在"));

        mockMvc.perform(get("/api/avatars/me")
                        .header("Authorization", "Bearer " + loginToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.avatarId", not(isEmptyOrNullString())))
                .andExpect(jsonPath("$.attributes.endurance").value(5))
                .andExpect(jsonPath("$.equipment.shoesId").value("shoes_basic_01"));

        mockMvc.perform(get("/api/workouts/today")
                        .header("Authorization", "Bearer " + loginToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.workoutId").value("test_3_minute_foundation"))
                .andExpect(jsonPath("$.estimatedDurationSeconds", greaterThan(0)))
                .andExpect(jsonPath("$.exercises.length()", is(4)))
                .andExpect(jsonPath("$.exercises[0].animationKey", not(isEmptyOrNullString())));

        var sessionJson = mockMvc.perform(post("/api/workouts/sessions")
                        .header("Authorization", "Bearer " + loginToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.sessionId", not(isEmptyOrNullString())))
                .andExpect(jsonPath("$.status").value("in_progress"))
                .andExpect(jsonPath("$.workout.workoutId").value("test_3_minute_foundation"))
                .andReturn()
                .getResponse()
                .getContentAsString();
        var sessionId = objectMapper.readTree(sessionJson).get("sessionId").asText();

        mockMvc.perform(post("/api/workouts/sessions/{sessionId}/complete", sessionId)
                        .header("Authorization", "Bearer " + loginToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "clientRequestId": "req_onboarding_first_day"
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("completed"))
                .andExpect(jsonPath("$.xpGained").value(80))
                .andExpect(jsonPath("$.avatar.avatarId", not(isEmptyOrNullString())))
                .andExpect(jsonPath("$.avatar.energyState").value("confident"))
                .andExpect(jsonPath("$.unityEvent.type").value("WORKOUT_COMPLETE"))
                .andExpect(jsonPath("$.unityEvent.payload.sessionId").value(sessionId));
    }

    private String profileRequest() {
        return """
                {
                  "gender": "male",
                  "age": 28,
                  "heightCm": 178,
                  "weightKg": 75,
                  "bodyFatPercentage": 18,
                  "fitnessGoal": "muscle_gain",
                  "trainingExperience": "beginner",
                  "weeklyTrainingDays": 3
                }
                """;
    }
}
