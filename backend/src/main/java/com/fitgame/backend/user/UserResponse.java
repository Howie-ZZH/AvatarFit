package com.fitgame.backend.user;

public record UserResponse(
        String userId,
        String email,
        String region,
        String language
) {
    public static UserResponse from(User user) {
        return new UserResponse(
                user.getId().toString(),
                user.getEmail(),
                user.getRegion(),
                user.getLanguage()
        );
    }
}

