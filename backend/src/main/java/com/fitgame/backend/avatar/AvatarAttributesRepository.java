package com.fitgame.backend.avatar;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface AvatarAttributesRepository extends JpaRepository<AvatarAttributes, UUID> {
    Optional<AvatarAttributes> findByAvatar(Avatar avatar);
}

