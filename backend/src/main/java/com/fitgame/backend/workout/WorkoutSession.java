package com.fitgame.backend.workout;

import com.fitgame.backend.avatar.Avatar;
import com.fitgame.backend.user.User;
import jakarta.persistence.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "workout_sessions")
public class WorkoutSession {
    @Id
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "avatar_id", nullable = false)
    private Avatar avatar;

    @Column(nullable = false)
    private String status;

    @Column(name = "started_at", nullable = false)
    private Instant startedAt;

    @Column(name = "completed_at")
    private Instant completedAt;

    @Column(name = "duration_seconds")
    private Integer durationSeconds;

    @Column(name = "xp_gained")
    private Integer xpGained;

    @Column(name = "client_request_id")
    private String clientRequestId;

    @Column(name = "growth_result_json", columnDefinition = "TEXT")
    private String growthResultJson;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    protected WorkoutSession() {
    }

    public WorkoutSession(User user, Avatar avatar) {
        this.id = UUID.randomUUID();
        this.user = user;
        this.avatar = avatar;
        this.status = "in_progress";
        this.startedAt = Instant.now();
        this.createdAt = this.startedAt;
        this.updatedAt = this.startedAt;
    }

    public void complete(int durationSeconds, int xpGained, String clientRequestId) {
        var now = Instant.now();
        this.status = "completed";
        this.completedAt = now;
        this.durationSeconds = durationSeconds;
        this.xpGained = xpGained;
        this.clientRequestId = clientRequestId;
        this.updatedAt = now;
    }

    public void saveGrowthResult(String growthResultJson) {
        this.growthResultJson = growthResultJson;
        this.updatedAt = Instant.now();
    }

    public UUID getId() { return id; }
    public User getUser() { return user; }
    public Avatar getAvatar() { return avatar; }
    public String getStatus() { return status; }
    public Instant getStartedAt() { return startedAt; }
    public Instant getCompletedAt() { return completedAt; }
    public Integer getDurationSeconds() { return durationSeconds; }
    public Integer getXpGained() { return xpGained; }
    public String getGrowthResultJson() { return growthResultJson; }
}
