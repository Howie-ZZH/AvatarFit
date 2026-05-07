package com.fitgame.backend.workout;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "exercises")
public class Exercise {
    @Id
    private String id;

    @Column(nullable = false)
    private String name;

    @Column(name = "animation_key", nullable = false)
    private String animationKey;

    @Column(name = "duration_seconds", nullable = false)
    private Integer durationSeconds;

    @Column(name = "default_sets", nullable = false)
    private Integer defaultSets;

    @Column(name = "default_reps", nullable = false)
    private Integer defaultReps;

    @Column(nullable = false)
    private String instruction;

    @Column(name = "strength_impact", nullable = false)
    private Integer strengthImpact;

    @Column(name = "endurance_impact", nullable = false)
    private Integer enduranceImpact;

    @Column(name = "core_impact", nullable = false)
    private Integer coreImpact;

    @Column(name = "flexibility_impact", nullable = false)
    private Integer flexibilityImpact;

    @Column(name = "fat_burn_impact", nullable = false)
    private Integer fatBurnImpact;

    @Column(name = "recovery_impact", nullable = false)
    private Integer recoveryImpact;

    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder;

    @Column(nullable = false)
    private String status;

    protected Exercise() {
    }

    public String getId() { return id; }
    public String getName() { return name; }
    public String getAnimationKey() { return animationKey; }
    public Integer getDurationSeconds() { return durationSeconds; }
    public Integer getDefaultSets() { return defaultSets; }
    public Integer getDefaultReps() { return defaultReps; }
    public String getInstruction() { return instruction; }
    public Integer getStrengthImpact() { return strengthImpact; }
    public Integer getEnduranceImpact() { return enduranceImpact; }
    public Integer getCoreImpact() { return coreImpact; }
    public Integer getFlexibilityImpact() { return flexibilityImpact; }
    public Integer getFatBurnImpact() { return fatBurnImpact; }
    public Integer getRecoveryImpact() { return recoveryImpact; }
}
