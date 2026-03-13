CREATE TABLE users (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email VARCHAR(254) NOT NULL,
    status TEXT NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT users_status_check 
        CHECK (status IN ('active', 'inactive', 'banned'))
);

CREATE UNIQUE INDEX users_email_unique_lower_idx
    ON users (LOWER(email));

CREATE TABLE user_auth (
    user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    password_hash TEXT NOT NULL,
    password_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_login_at TIMESTAMPTZ,

    CONSTRAINT user_auth_password_hash_not_blank
        CHECK (char_length(trim(password_hash)) > 0)
);

CREATE TABLE user_profiles (
    user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    username VARCHAR(30) UNIQUE,
    display_name VARCHAR(50),
    birth_date DATE,
    sex TEXT,
    height_cm NUMERIC(5,2),
    weight_kg NUMERIC(5,2),
    goal TEXT,
    activity_level TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT user_profiles_username_not_blank
        CHECK (username IS NULL OR char_length(trim(username)) > 0),

    CONSTRAINT user_profiles_username_format_check
        CHECK (username IS NULL OR username ~ '^[a-zA-Z0-9_]{3,30}$'),

    CONSTRAINT user_profiles_display_name_not_blank
        CHECK (display_name IS NULL OR char_length(trim(display_name)) > 0),

    CONSTRAINT user_profiles_height_check
        CHECK (height_cm IS NULL OR height_cm > 0),

    CONSTRAINT user_profiles_weight_check
        CHECK (weight_kg IS NULL OR weight_kg > 0)
);

CREATE TABLE meals (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    meal_type TEXT,
    eaten_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    title VARCHAR(100),
    photo_url TEXT,
    notes TEXT,
    health_score SMALLINT,
    ai_confidence NUMERIC(4,3),
    total_calories NUMERIC(8,2),
    total_protein_g NUMERIC(8,2),
    total_carbs_g NUMERIC(8,2),
    total_fat_g NUMERIC(8,2),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT meals_health_score_check
        CHECK (health_score IS NULL OR health_score BETWEEN 1 AND 10),

    CONSTRAINT meals_ai_confidence_check
        CHECK (ai_confidence IS NULL OR ai_confidence BETWEEN 0 AND 1),

    CONSTRAINT meals_total_calories_check
        CHECK (total_calories IS NULL OR total_calories >= 0),

    CONSTRAINT meals_total_protein_check
        CHECK (total_protein_g IS NULL OR total_protein_g >= 0),

    CONSTRAINT meals_total_carbs_check
        CHECK (total_carbs_g IS NULL OR total_carbs_g >= 0),

    CONSTRAINT meals_total_fat_check
        CHECK (total_fat_g IS NULL OR total_fat_g >= 0)
);

CREATE TABLE meal_items (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    meal_id BIGINT NOT NULL REFERENCES meals(id) ON DELETE CASCADE,
    item_name VARCHAR(100) NOT NULL,
    quantity NUMERIC(8,2),
    unit VARCHAR(20),
    grams NUMERIC(8,2),
    calories NUMERIC(8,2),
    protein_g NUMERIC(8,2),
    carbs_g NUMERIC(8,2),
    fat_g NUMERIC(8,2),
    health_score SMALLINT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT meal_items_item_name_not_blank
        CHECK (char_length(trim(item_name)) > 0),

    CONSTRAINT meal_items_quantity_check
        CHECK (quantity IS NULL OR quantity > 0),

    CONSTRAINT meal_items_grams_check
        CHECK (grams IS NULL OR grams > 0),

    CONSTRAINT meal_items_calories_check
        CHECK (calories IS NULL OR calories >= 0),

    CONSTRAINT meal_items_protein_check
        CHECK (protein_g IS NULL OR protein_g >= 0),

    CONSTRAINT meal_items_carbs_check
        CHECK (carbs_g IS NULL OR carbs_g >= 0),

    CONSTRAINT meal_items_fat_check
        CHECK (fat_g IS NULL OR fat_g >= 0),

    CONSTRAINT meal_items_health_score_check
        CHECK (health_score IS NULL OR health_score BETWEEN 1 AND 10)
);

CREATE TABLE workouts (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    workout_type TEXT,
    title VARCHAR(100),
    performed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    duration_min INTEGER,
    calories_burned NUMERIC(8,2),
    health_score SMALLINT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT workouts_duration_check
        CHECK (duration_min IS NULL OR duration_min > 0),

    CONSTRAINT workouts_calories_burned_check
        CHECK (calories_burned IS NULL OR calories_burned >= 0),

    CONSTRAINT workouts_health_score_check
        CHECK (health_score IS NULL OR health_score BETWEEN 1 AND 10)
);

CREATE TABLE workout_exercises (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workout_id BIGINT NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
    exercise_name VARCHAR(100) NOT NULL,
    exercise_order INTEGER,
    sets INTEGER,
    reps INTEGER,
    weight_kg NUMERIC(8,2),
    duration_sec INTEGER,
    distance_m NUMERIC(10,2),
    calories_burned NUMERIC(8,2),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT workout_exercises_name_not_blank
        CHECK (char_length(trim(exercise_name)) > 0),

    CONSTRAINT workout_exercises_order_check
        CHECK (exercise_order IS NULL OR exercise_order > 0),

    CONSTRAINT workout_exercises_sets_check
        CHECK (sets IS NULL OR sets > 0),

    CONSTRAINT workout_exercises_reps_check
        CHECK (reps IS NULL OR reps > 0),

    CONSTRAINT workout_exercises_weight_check
        CHECK (weight_kg IS NULL OR weight_kg >= 0),

    CONSTRAINT workout_exercises_duration_check
        CHECK (duration_sec IS NULL OR duration_sec > 0),

    CONSTRAINT workout_exercises_distance_check
        CHECK (distance_m IS NULL OR distance_m >= 0),

    CONSTRAINT workout_exercises_calories_check
        CHECK (calories_burned IS NULL OR calories_burned >= 0)
);

CREATE INDEX meal_items_meal_id_idx ON meal_items(meal_id);
CREATE INDEX workout_exercises_workout_id_idx ON workout_exercises(workout_id);


CREATE TABLE exp_events (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    source_type TEXT NOT NULL,
    source_id BIGINT NOT NULL,
    exp_amount INTEGER NOT NULL,
    reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT exp_events_exp_amount_check
        CHECK (exp_amount <> 0)
);

CREATE TABLE user_progress (
    user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    total_exp INTEGER NOT NULL DEFAULT 0,
    level INTEGER NOT NULL DEFAULT 1,
    current_streak_days INTEGER NOT NULL DEFAULT 0,
    longest_streak_days INTEGER NOT NULL DEFAULT 0,
    last_activity_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT user_progress_total_exp_check
        CHECK (total_exp >= 0),

    CONSTRAINT user_progress_level_check
        CHECK (level >= 1),

    CONSTRAINT user_progress_current_streak_check
        CHECK (current_streak_days >= 0),

    CONSTRAINT user_progress_longest_streak_check
        CHECK (longest_streak_days >= 0)
);

CREATE TABLE challenges (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    challenge_type TEXT,
    goal_value NUMERIC(10,2),
    reward_exp INTEGER NOT NULL DEFAULT 0,
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT challenges_title_not_blank
        CHECK (char_length(trim(title)) > 0),

    CONSTRAINT challenges_goal_value_check
        CHECK (goal_value IS NULL OR goal_value > 0),

    CONSTRAINT challenges_reward_exp_check
        CHECK (reward_exp >= 0),

    CONSTRAINT challenges_date_range_check
        CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date)
);

CREATE TABLE user_challenges (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    challenge_id BIGINT NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
    progress_value NUMERIC(10,2) NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'active',
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    claimed_at TIMESTAMPTZ,

    CONSTRAINT user_challenges_progress_check
        CHECK (progress_value >= 0),

    CONSTRAINT user_challenges_status_check
        CHECK (status IN ('active', 'completed', 'claimed', 'failed')),

    CONSTRAINT user_challenges_unique
        UNIQUE (user_id, challenge_id)
);

CREATE INDEX user_challenges_user_id_idx ON user_challenges(user_id);
CREATE INDEX user_challenges_challenge_id_idx ON user_challenges(challenge_id);

CREATE TABLE achievements (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    achievement_type TEXT,
    target_value NUMERIC(10,2),
    reward_exp INTEGER NOT NULL DEFAULT 0,
    icon_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT achievements_code_not_blank
        CHECK (char_length(trim(code)) > 0),

    CONSTRAINT achievements_title_not_blank
        CHECK (char_length(trim(title)) > 0),

    CONSTRAINT achievements_target_value_check
        CHECK (target_value IS NULL OR target_value > 0),

    CONSTRAINT achievements_reward_exp_check
        CHECK (reward_exp >= 0)
);

CREATE TABLE user_achievements (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_id BIGINT NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
    progress_value NUMERIC(10,2) NOT NULL DEFAULT 0,
    unlocked_at TIMESTAMPTZ,
    claimed_at TIMESTAMPTZ,

    CONSTRAINT user_achievements_progress_check
        CHECK (progress_value >= 0),

    CONSTRAINT user_achievements_unique
        UNIQUE (user_id, achievement_id)
);

CREATE INDEX user_achievements_user_id_idx ON user_achievements(user_id);
CREATE INDEX user_achievements_achievement_id_idx ON user_achievements(achievement_id);