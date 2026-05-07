package com.fitgame.backend.avatar;

import com.fitgame.backend.user.User;
import jakarta.persistence.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "avatars")
public class Avatar {
    @Id
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(nullable = false)
    private String name;

    @Column(name = "base_type", nullable = false)
    private String baseType;

    @Column(name = "style_type", nullable = false)
    private String styleType;

    @Column(name = "body_type", nullable = false)
    private String bodyType;

    @Column(name = "energy_state", nullable = false)
    private String energyState;

    @Column(nullable = false)
    private Integer level;

    @Column(nullable = false)
    private Integer xp;

    @Column(name = "xp_to_next_level", nullable = false)
    private Integer xpToNextLevel;

    @Column(name = "current_outfit_id")
    private String currentOutfitId;

    @Column(name = "current_shoes_id")
    private String currentShoesId;

    @Column(name = "current_accessory_id")
    private String currentAccessoryId;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    protected Avatar() {
    }

    public Avatar(User user, CreateAvatarRequest request) {
        this.id = UUID.randomUUID();
        this.user = user;
        this.name = request.name();
        this.baseType = request.baseType();
        this.styleType = request.styleType();
        this.bodyType = "normal";
        this.energyState = "normal";
        this.level = 1;
        this.xp = 0;
        this.xpToNextLevel = 122;
        this.currentOutfitId = "outfit_starter_black";
        this.currentShoesId = "shoes_basic_01";
        this.createdAt = Instant.now();
        this.updatedAt = this.createdAt;
    }

    public void applyGrowth(int xpGained) {
        var nextXp = this.xp + xpGained;
        var nextLevel = this.level;
        var nextThreshold = this.xpToNextLevel;

        while (nextXp >= nextThreshold) {
            nextXp -= nextThreshold;
            nextLevel += 1;
            nextThreshold = calculateXpToNextLevel(nextLevel);
        }

        this.xp = nextXp;
        this.level = nextLevel;
        this.xpToNextLevel = nextThreshold;
        this.energyState = "confident";
        this.updatedAt = Instant.now();
    }

    private static int calculateXpToNextLevel(int level) {
        return 100 + level * 40;
    }

    public UUID getId() { return id; }
    public User getUser() { return user; }
    public String getName() { return name; }
    public String getBaseType() { return baseType; }
    public String getStyleType() { return styleType; }
    public String getBodyType() { return bodyType; }
    public String getEnergyState() { return energyState; }
    public Integer getLevel() { return level; }
    public Integer getXp() { return xp; }
    public Integer getXpToNextLevel() { return xpToNextLevel; }
    public String getCurrentOutfitId() { return currentOutfitId; }
    public String getCurrentShoesId() { return currentShoesId; }
    public String getCurrentAccessoryId() { return currentAccessoryId; }
}
