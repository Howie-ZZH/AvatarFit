package com.fitgame.backend.avatar;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateAvatarRequest(
        @NotBlank @Size(max = 64) String name,
        @NotBlank String baseType,
        @NotBlank String styleType
) {
}

