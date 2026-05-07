package com.fitgame.backend.profile;

import com.fitgame.backend.user.User;
import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "user_profiles")
public class UserProfile {
    @Id
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    private String gender;
    private Integer age;

    @Column(name = "height_cm")
    private BigDecimal heightCm;

    @Column(name = "weight_kg")
    private BigDecimal weightKg;

    @Column(name = "body_fat_percentage")
    private BigDecimal bodyFatPercentage;

    @Column(name = "fitness_goal", nullable = false)
    private String fitnessGoal;

    @Column(name = "training_experience", nullable = false)
    private String trainingExperience;

    @Column(name = "weekly_training_days", nullable = false)
    private Integer weeklyTrainingDays;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    protected UserProfile() {
    }

    public UserProfile(User user, ProfileRequest request) {
        this.id = UUID.randomUUID();
        this.user = user;
        apply(request);
        this.createdAt = Instant.now();
        this.updatedAt = this.createdAt;
    }

    public void apply(ProfileRequest request) {
        this.gender = request.gender();
        this.age = request.age();
        this.heightCm = request.heightCm();
        this.weightKg = request.weightKg();
        this.bodyFatPercentage = request.bodyFatPercentage();
        this.fitnessGoal = request.fitnessGoal();
        this.trainingExperience = request.trainingExperience();
        this.weeklyTrainingDays = request.weeklyTrainingDays();
        this.updatedAt = Instant.now();
    }

    public UUID getId() { return id; }
    public User getUser() { return user; }
    public String getGender() { return gender; }
    public Integer getAge() { return age; }
    public BigDecimal getHeightCm() { return heightCm; }
    public BigDecimal getWeightKg() { return weightKg; }
    public BigDecimal getBodyFatPercentage() { return bodyFatPercentage; }
    public String getFitnessGoal() { return fitnessGoal; }
    public String getTrainingExperience() { return trainingExperience; }
    public Integer getWeeklyTrainingDays() { return weeklyTrainingDays; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
}

