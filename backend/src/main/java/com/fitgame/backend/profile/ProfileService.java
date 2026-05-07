package com.fitgame.backend.profile;

import com.fitgame.backend.common.ApiException;
import com.fitgame.backend.user.User;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ProfileService {
    private final UserProfileRepository profileRepository;

    public ProfileService(UserProfileRepository profileRepository) {
        this.profileRepository = profileRepository;
    }

    @Transactional
    public ProfileResponse create(User user, ProfileRequest request) {
        if (profileRepository.existsByUser(user)) {
            throw new ApiException(HttpStatus.CONFLICT, "身体档案已存在");
        }
        return ProfileResponse.from(profileRepository.save(new UserProfile(user, request)));
    }

    @Transactional(readOnly = true)
    public ProfileResponse get(User user) {
        return profileRepository.findByUser(user)
                .map(ProfileResponse::from)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "身体档案不存在"));
    }

    @Transactional
    public ProfileResponse update(User user, ProfileRequest request) {
        UserProfile profile = profileRepository.findByUser(user)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "身体档案不存在"));
        profile.apply(request);
        return ProfileResponse.from(profile);
    }
}

