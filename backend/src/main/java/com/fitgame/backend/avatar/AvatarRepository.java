package com.fitgame.backend.avatar;

import com.fitgame.backend.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface AvatarRepository extends JpaRepository<Avatar, UUID> {
    Optional<Avatar> findByUser(User user);
    boolean existsByUser(User user);
}

