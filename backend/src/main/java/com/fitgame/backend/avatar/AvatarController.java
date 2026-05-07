package com.fitgame.backend.avatar;

import com.fitgame.backend.user.User;
import jakarta.validation.Valid;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/avatars")
public class AvatarController {
    private final AvatarService avatarService;

    public AvatarController(AvatarService avatarService) {
        this.avatarService = avatarService;
    }

    @PostMapping
    AvatarResponse create(@AuthenticationPrincipal User user, @Valid @RequestBody CreateAvatarRequest request) {
        return avatarService.create(user, request);
    }

    @GetMapping("/me")
    AvatarResponse get(@AuthenticationPrincipal User user) {
        return avatarService.get(user);
    }

    @GetMapping("/me/attributes")
    AttributeResponse attributes(@AuthenticationPrincipal User user) {
        return avatarService.getAttributes(user);
    }
}
