# Database

This folder contains the shared database SQL for the project.

## Structure

- `migrations/` stores ordered SQL files used to create or change database structure.
- `queries/` stores optional manual SQL, helper scripts, or analysis queries.

## Convention

- Name migration files in execution order, for example `000_init.sql`, `001_...sql`, `002_...sql`.
- Treat migrations as history. After a migration is shared, add a new file instead of rewriting the old one.
- Keep each migration focused on one clear change set.
- Use `queries/` only for SQL that is not part of the canonical schema history.

## Initial Schema

The current application schema lives in `migrations/001_initial_schema.sql`.

### Main Table Groups

- `users`, `user_auth`, `user_profiles`
  Core account data, login data, and optional profile / health data.
- `meals`, `meal_items`
  A meal log plus its detailed ingredients or detected items.
- `workouts`, `workout_exercises`
  A workout log plus optional exercise-level breakdown.
- `exp_events`, `user_progress`
  Experience history and the user's current progression state.
- `challenges`, `user_challenges`
  Challenge definitions and each user's progress in them.
- `achievements`, `user_achievements`
  Achievement definitions and each user's unlock progress.

### Relationship Summary

- One `users` row can have one `user_auth` row.
- One `users` row can have zero or one `user_profiles` row.
- One user can have many meals and many workouts.
- One meal can have many `meal_items`.
- One workout can have many `workout_exercises`.
- One user can have many `exp_events`.
- One user has one `user_progress` row.
- Challenge and achievement tables are split into:
  definition table + per-user join/progress table.

### Less Obvious Columns

- `NUMERIC(5,2)` or `NUMERIC(8,2)`
  Fixed precision decimal values. Example: `NUMERIC(5,2)` fits values like `180.50`.
- `TIMESTAMPTZ`
  Timestamp with timezone. Use this for actions that happen at a real moment in time.
- `ai_confidence`
  Number from `0` to `1` describing how confident the AI is in a meal classification or estimate.
- `health_score`
  Manual or AI-generated score on a `1-10` scale for meals or workouts.
- `quantity`, `unit`, `grams`
  `quantity` + `unit` represent user-friendly input like `2 pcs` or `250 ml`, while `grams` gives a normalized amount for calculations.
- `exercise_order`
  Keeps exercise display order inside one workout.
- `source_type` and `source_id` in `exp_events`
  Polymorphic reference to where EXP came from, for example a workout, challenge, achievement, or meal-related action.
- Recommended `exp_events.source_type` values
  `workout`, `meal`, `challenge`, `achievement`, `manual`, and optionally `streak` if streak rewards are handled as separate EXP events.
- `progress_value`
  Current progress toward a challenge or achievement target.
- `claimed_at`
  Timestamp for reward claim if unlocking and claiming are treated as separate actions.

### Why Some Data Is Repeated

- `meals` stores total macros for the full meal.
- `meal_items` stores item-level data for the meal breakdown.
- `workouts` stores workout-level data.
- `workout_exercises` stores exercise-level details.

This is intentional. Parent tables are optimized for quick reads of the full object, while child tables keep the detailed breakdown shown in the UI.

### Action Flows

#### User Registration

1. Insert into `users`.
2. Insert login credentials into `user_auth`.
3. Optionally create `user_profiles`.
4. Create initial `user_progress` row.

#### User Completes Profile

1. Insert or update `user_profiles`.
2. Keep `users` and `user_auth` unchanged unless account data changes.

#### User Logs a Meal

1. Insert one row into `meals`.
2. Insert one or more rows into `meal_items`.
3. Recalculate and persist `meals.total_calories`, `total_protein_g`, `total_carbs_g`, `total_fat_g`.
4. If the meal grants EXP, insert into `exp_events`.
5. Update `user_progress`.

#### User Logs a Workout

1. Insert one row into `workouts`.
2. Optionally insert many rows into `workout_exercises`.
3. If the workout grants EXP, insert into `exp_events`.
4. Update `user_progress`.

#### User Progresses a Challenge

1. Insert definition into `challenges` once.
2. Insert or update the user's row in `user_challenges`.
3. When completed, set `completed_at` and optionally `claimed_at`.
4. If the reward includes EXP, insert into `exp_events` and update `user_progress`.

#### User Unlocks an Achievement

1. Insert definition into `achievements` once.
2. Insert or update the user's row in `user_achievements`.
3. Set `unlocked_at` when the condition is met.
4. If claim is separate, set `claimed_at` later.
5. If the reward includes EXP, insert into `exp_events` and update `user_progress`.

### Current Modeling Decisions

- `user_profiles` is optional, so a user account can exist before profile completion.
- The schema does not currently use `foods`, `products`, or `exercises` reference tables.
- Meal and workout detail tables store direct logged values instead of referencing external dictionaries.
- Email uniqueness is case-insensitive through a unique index on `LOWER(email)`.
- `exp_events.source_type` is currently flexible in SQL and should be kept consistent by the backend until a database-level constraint is added.
