package com.fitgame.backend.avatar;

import jakarta.persistence.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "avatar_attributes")
public class AvatarAttributes {
    @Id
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "avatar_id", nullable = false, unique = true)
    private Avatar avatar;

    private Integer strength;
    private Integer endurance;
    private Integer core;
    private Integer flexibility;

    @Column(name = "fat_burn")
    private Integer fatBurn;

    private Integer recovery;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    protected AvatarAttributes() {
    }

    public AvatarAttributes(Avatar avatar) {
        this.id = UUID.randomUUID();
        this.avatar = avatar;
        this.strength = 5;
        this.endurance = 5;
        this.core = 5;
        this.flexibility = 5;
        this.fatBurn = 5;
        this.recovery = 5;
        this.createdAt = Instant.now();
        this.updatedAt = this.createdAt;
    }

    public void applyDelta(
            int strength,
            int endurance,
            int core,
            int flexibility,
            int fatBurn,
            int recovery
    ) {
        this.strength += strength;
        this.endurance += endurance;
        this.core += core;
        this.flexibility += flexibility;
        this.fatBurn += fatBurn;
        this.recovery += recovery;
        this.updatedAt = Instant.now();
    }

    public UUID getId() { return id; }
    public Avatar getAvatar() { return avatar; }
    public Integer getStrength() { return strength; }
    public Integer getEndurance() { return endurance; }
    public Integer getCore() { return core; }
    public Integer getFlexibility() { return flexibility; }
    public Integer getFatBurn() { return fatBurn; }
    public Integer getRecovery() { return recovery; }
}
