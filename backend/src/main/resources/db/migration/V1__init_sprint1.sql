CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(32),
    password_hash VARCHAR(255) NOT NULL,
    region VARCHAR(16) NOT NULL,
    language VARCHAR(16) NOT NULL,
    status VARCHAR(32) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE user_profiles (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL UNIQUE REFERENCES users(id),
    gender VARCHAR(32),
    age INTEGER,
    height_cm NUMERIC(5, 2),
    weight_kg NUMERIC(5, 2),
    body_fat_percentage NUMERIC(5, 2),
    fitness_goal VARCHAR(32) NOT NULL,
    training_experience VARCHAR(32) NOT NULL,
    weekly_training_days INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE avatars (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL UNIQUE REFERENCES users(id),
    name VARCHAR(64) NOT NULL,
    base_type VARCHAR(32) NOT NULL,
    style_type VARCHAR(32) NOT NULL,
    body_type VARCHAR(32) NOT NULL,
    energy_state VARCHAR(32) NOT NULL,
    level INTEGER NOT NULL,
    xp INTEGER NOT NULL,
    xp_to_next_level INTEGER NOT NULL,
    current_outfit_id VARCHAR(64),
    current_shoes_id VARCHAR(64),
    current_accessory_id VARCHAR(64),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE avatar_attributes (
    id UUID PRIMARY KEY,
    avatar_id UUID NOT NULL UNIQUE REFERENCES avatars(id),
    strength INTEGER NOT NULL,
    endurance INTEGER NOT NULL,
    core INTEGER NOT NULL,
    flexibility INTEGER NOT NULL,
    fat_burn INTEGER NOT NULL,
    recovery INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);
