package com.fitgame.backend.profile;

import com.fitgame.backend.user.User;
import jakarta.validation.Valid;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/profiles")
public class ProfileController {
    private final ProfileService profileService;

    public ProfileController(ProfileService profileService) {
        this.profileService = profileService;
    }

    @PostMapping
    ProfileResponse create(@AuthenticationPrincipal User user, @Valid @RequestBody ProfileRequest request) {
        return profileService.create(user, request);
    }

    @GetMapping("/me")
    ProfileResponse get(@AuthenticationPrincipal User user) {
        return profileService.get(user);
    }

    @PutMapping("/me")
    ProfileResponse update(@AuthenticationPrincipal User user, @Valid @RequestBody ProfileRequest request) {
        return profileService.update(user, request);
    }
}
