package com.fitgame.backend.avatar;

import com.fitgame.backend.common.ApiException;
import com.fitgame.backend.user.User;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AvatarService {
    private final AvatarRepository avatarRepository;
    private final AvatarAttributesRepository attributesRepository;

    public AvatarService(AvatarRepository avatarRepository, AvatarAttributesRepository attributesRepository) {
        this.avatarRepository = avatarRepository;
        this.attributesRepository = attributesRepository;
    }

    @Transactional
    public AvatarResponse create(User user, CreateAvatarRequest request) {
        if (avatarRepository.existsByUser(user)) {
            throw new ApiException(HttpStatus.CONFLICT, "角色已存在");
        }
        Avatar avatar = avatarRepository.save(new Avatar(user, request));
        AvatarAttributes attributes = attributesRepository.save(new AvatarAttributes(avatar));
        return AvatarResponse.from(avatar, attributes);
    }

    @Transactional(readOnly = true)
    public AvatarResponse get(User user) {
        Avatar avatar = findAvatar(user);
        return AvatarResponse.from(avatar, findAttributes(avatar));
    }

    @Transactional(readOnly = true)
    public AttributeResponse getAttributes(User user) {
        return AttributeResponse.from(findAttributes(findAvatar(user)));
    }

    private Avatar findAvatar(User user) {
        return avatarRepository.findByUser(user)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "角色不存在"));
    }

    private AvatarAttributes findAttributes(Avatar avatar) {
        return attributesRepository.findByAvatar(avatar)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "角色属性不存在"));
    }
}

