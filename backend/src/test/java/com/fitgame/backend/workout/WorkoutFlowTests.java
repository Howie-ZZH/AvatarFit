package com.fitgame.backend.workout;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.greaterThan;
import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class WorkoutFlowTests {
    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void completesWorkoutAndReturnsUnityGrowthEvent() throws Exception {
        var token = registerAndGetToken();
        createAvatar(token);

        mockMvc.perform(get("/api/workouts/today")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.workoutId", is("test_3_minute_foundation")))
                .andExpect(jsonPath("$.exercises.length()", is(4)));

        var sessionJson = mockMvc.perform(post("/api/workouts/sessions")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status", is("in_progress")))
                .andReturn()
                .getResponse()
                .getContentAsString();
        var sessionId = objectMapper.readTree(sessionJson).get("sessionId").asText();

        var completedJson = mockMvc.perform(post("/api/workouts/sessions/{sessionId}/complete", sessionId)
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "clientRequestId": "req_workout_test_1"
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status", is("completed")))
                .andExpect(jsonPath("$.xpGained", is(80)))
                .andExpect(jsonPath("$.attributeDelta.strength", is(2)))
                .andExpect(jsonPath("$.avatar.attributes.strength", greaterThan(5)))
                .andExpect(jsonPath("$.unityEvent.type", is("WORKOUT_COMPLETE")))
                .andExpect(jsonPath("$.unityEvent.payload.sessionId", is(sessionId)))
                .andReturn()
                .getResponse()
                .getContentAsString();
        var completedAt = objectMapper.readTree(completedJson).get("completedAt").asText();

        mockMvc.perform(post("/api/workouts/sessions/{sessionId}/complete", sessionId)
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "clientRequestId": "req_workout_test_1"
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status", is("completed")))
                .andExpect(jsonPath("$.completedAt", is(completedAt)))
                .andExpect(jsonPath("$.xpGained", is(80)))
                .andExpect(jsonPath("$.avatar.xp", is(80)))
                .andExpect(jsonPath("$.attributeDelta.strength", is(2)))
                .andExpect(jsonPath("$.unityEvent.type", is("WORKOUT_COMPLETE")));
    }

    @Test
    void rejectsCompleteWorkoutForUnknownExerciseId() throws Exception {
        var token = registerAndGetToken();
        createAvatar(token);
        var sessionId = createSession(token);

        mockMvc.perform(post("/api/workouts/sessions/{sessionId}/complete", sessionId)
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "exercises": [
                                    {
                                      "exerciseId": "missing_exercise"
                                    }
                                  ]
                                }
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.status", is(400)))
                .andExpect(jsonPath("$.message", is("训练动作不存在: missing_exercise")));
    }

    @Test
    void settlesWorkoutWithReportedExerciseDurationAndCapsAtPlan() throws Exception {
        var token = registerAndGetToken();
        createAvatar(token);
        var sessionId = createSession(token);

        mockMvc.perform(post("/api/workouts/sessions/{sessionId}/complete", sessionId)
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "durationSeconds": 999,
                                  "exercises": [
                                    {
                                      "exerciseId": "squat_basic",
                                      "durationSeconds": 10,
                                      "setsCompleted": 1,
                                      "repsCompleted": 8
                                    }
                                  ]
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.durationSeconds", is(10)))
                .andExpect(jsonPath("$.xpGained", is(10)))
                .andExpect(jsonPath("$.attributeDelta.strength", is(2)))
                .andExpect(jsonPath("$.unityEvent.payload.xpGained", is(10)));
    }

    @Test
    void validatesCompleteWorkoutRequestBody() throws Exception {
        var token = registerAndGetToken();
        createAvatar(token);
        var sessionId = createSession(token);

        mockMvc.perform(post("/api/workouts/sessions/{sessionId}/complete", sessionId)
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "durationSeconds": -1
                                }
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message", is("请求参数不合法")));

        mockMvc.perform(post("/api/workouts/sessions/{sessionId}/complete", sessionId)
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "exercises": [
                                    {
                                      "exerciseId": "squat_basic"
                                    },
                                    {
                                      "exerciseId": "squat_basic"
                                    }
                                  ]
                                }
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message", is("训练动作重复: squat_basic")));

        mockMvc.perform(post("/api/workouts/sessions/{sessionId}/complete", sessionId)
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "exercises": []
                                }
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message", is("请求参数不合法")));

        mockMvc.perform(post("/api/workouts/sessions/{sessionId}/complete", sessionId)
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "exercises": [
                                    {
                                      "exerciseId": " "
                                    }
                                  ]
                                }
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message", is("请求参数不合法")));

        mockMvc.perform(post("/api/workouts/sessions/{sessionId}/complete", sessionId)
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "exercises": [
                                }
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message", is("请求体不合法")));
    }

    @Test
    void rejectsCompleteWorkoutForAnotherUsersSession() throws Exception {
        var ownerToken = registerAndGetToken();
        createAvatar(ownerToken);
        var otherToken = registerAndGetToken();
        createAvatar(otherToken);
        var ownerSessionId = createSession(ownerToken);

        mockMvc.perform(post("/api/workouts/sessions/{sessionId}/complete", ownerSessionId)
                        .header("Authorization", "Bearer " + otherToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "clientRequestId": "req_cross_user"
                                }
                                """))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message", is("训练 session 不存在")));
    }

    @Test
    void rejectsWorkoutSessionCreationWhenAvatarDoesNotExist() throws Exception {
        var token = registerAndGetToken();

        mockMvc.perform(post("/api/workouts/sessions")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message", is("角色不存在")));
    }

    private String registerAndGetToken() throws Exception {
        var email = "workout-" + System.nanoTime() + "@example.com";
        var response = mockMvc.perform(post("/api/auth/register")
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
                .andReturn()
                .getResponse()
                .getContentAsString();
        return objectMapper.readTree(response).get("accessToken").asText();
    }

    private String createSession(String token) throws Exception {
        var sessionJson = mockMvc.perform(post("/api/workouts/sessions")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status", is("in_progress")))
                .andReturn()
                .getResponse()
                .getContentAsString();
        return objectMapper.readTree(sessionJson).get("sessionId").asText();
    }

    private void createAvatar(String token) throws Exception {
        mockMvc.perform(post("/api/avatars")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "name": "Rex",
                                  "baseType": "neutral",
                                  "styleType": "balanced"
                                }
                                """))
                .andExpect(status().isOk());
    }
}
