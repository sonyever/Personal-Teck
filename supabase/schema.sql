-- ============================================================
-- Personal Teck — Schema Supabase
-- Cole no SQL Editor do dashboard e clique em "Run"
-- ============================================================

-- ── 1. PROFILES ──────────────────────────────────────────────
create table if not exists profiles (
  id         uuid references auth.users(id) on delete cascade primary key,
  name       text not null,
  email      text not null,
  avatar_url text,
  role       text not null check (role in ('trainer','student','nutritionist')),
  created_at timestamptz default now()
);

alter table profiles enable row level security;

create policy "profiles_select" on profiles
  for select to authenticated using (true);

create policy "profiles_insert" on profiles
  for insert to authenticated with check (auth.uid() = id);

create policy "profiles_update" on profiles
  for update to authenticated using (auth.uid() = id);

-- Cria profile automaticamente no cadastro
create or replace function handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into profiles (id, name, email, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'name', split_part(new.email,'@',1)),
    new.email,
    coalesce(new.raw_user_meta_data->>'role','student')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure handle_new_user();

-- ── 2. STUDENT PROFILES ──────────────────────────────────────
create table if not exists student_profiles (
  user_id          uuid references profiles(id) on delete cascade primary key,
  trainer_id       uuid references profiles(id) not null,
  age              integer not null,
  weight_kg        numeric(5,2) not null,
  height_cm        numeric(5,1) not null,
  primary_modality text not null,
  goal             text not null,
  restrictions     text,
  level            text not null check (level in ('beginner','intermediate','advanced')),
  is_active        boolean default true,
  has_wearable     boolean default false,
  max_heart_rate   integer,
  min_spo2         numeric(4,1),
  last_training    timestamptz,
  payment_status   text default 'upToDate' check (payment_status in ('upToDate','pending','overdue'))
);

alter table student_profiles enable row level security;

create policy "sp_trainer_all" on student_profiles
  for all to authenticated
  using (trainer_id = auth.uid()) with check (trainer_id = auth.uid());

create policy "sp_student_select" on student_profiles
  for select to authenticated using (user_id = auth.uid());

-- ── 3. EXERCISES ─────────────────────────────────────────────
create table if not exists exercises (
  id           uuid primary key default gen_random_uuid(),
  name         text not null,
  video_url    text,
  youtube_url  text,
  muscle_group text not null,
  modality     text not null,
  instructions text,
  created_by   uuid references profiles(id),
  created_at   timestamptz default now()
);

alter table exercises enable row level security;

create policy "exercises_select" on exercises
  for select to authenticated using (true);

create policy "exercises_insert" on exercises
  for insert to authenticated
  with check (
    created_by = auth.uid() and
    (select role from profiles where id = auth.uid()) in ('trainer','nutritionist')
  );

create policy "exercises_update" on exercises
  for update to authenticated using (created_by = auth.uid());

create policy "exercises_delete" on exercises
  for delete to authenticated using (created_by = auth.uid());

-- ── 4. WORKOUTS ──────────────────────────────────────────────
create table if not exists workouts (
  id           uuid primary key default gen_random_uuid(),
  student_id   uuid references profiles(id) not null,
  trainer_id   uuid references profiles(id) not null,
  name         text not null,
  modality     text not null,
  is_active    boolean default true,
  ai_generated text,
  created_at   timestamptz default now(),
  completed_at timestamptz
);

alter table workouts enable row level security;

create policy "workouts_trainer_all" on workouts
  for all to authenticated
  using (trainer_id = auth.uid()) with check (trainer_id = auth.uid());

create policy "workouts_student_select" on workouts
  for select to authenticated using (student_id = auth.uid());

-- ── 5. WORKOUT SETS ──────────────────────────────────────────
create table if not exists workout_sets (
  id               uuid primary key default gen_random_uuid(),
  workout_id       uuid references workouts(id) on delete cascade not null,
  exercise_id      uuid references exercises(id) not null,
  sets             integer not null,
  reps             integer not null,
  weight_kg        numeric(6,2),
  rest_seconds     integer default 60,
  duration_minutes integer,
  target_zone      text,
  notes            text,
  is_completed     boolean default false,
  order_index      integer not null default 0
);

alter table workout_sets enable row level security;

create policy "ws_trainer_all" on workout_sets
  for all to authenticated
  using ((select trainer_id from workouts where id = workout_id) = auth.uid())
  with check ((select trainer_id from workouts where id = workout_id) = auth.uid());

create policy "ws_student_select" on workout_sets
  for select to authenticated
  using ((select student_id from workouts where id = workout_id) = auth.uid());

create policy "ws_student_update" on workout_sets
  for update to authenticated
  using ((select student_id from workouts where id = workout_id) = auth.uid());

-- ── 6. PRE-WORKOUT CHECK-INS ─────────────────────────────────
create table if not exists pre_workout_checkins (
  id         uuid primary key default gen_random_uuid(),
  student_id uuid references profiles(id) not null,
  workout_id uuid references workouts(id) not null,
  energy     text not null,
  discomforts text[] default '{}',
  notes      text,
  created_at timestamptz default now()
);

alter table pre_workout_checkins enable row level security;

create policy "checkin_student_all" on pre_workout_checkins
  for all to authenticated
  using (student_id = auth.uid()) with check (student_id = auth.uid());

create policy "checkin_trainer_select" on pre_workout_checkins
  for select to authenticated
  using ((select trainer_id from workouts where id = workout_id) = auth.uid());

-- ── 7. WEARABLE SNAPSHOTS ────────────────────────────────────
create table if not exists wearable_snapshots (
  id              uuid primary key default gen_random_uuid(),
  student_id      uuid references profiles(id) not null,
  heart_rate_bpm  integer not null,
  spo2_pct        numeric(4,1),
  hrv_ms          numeric(6,1),
  calories_burned numeric(7,1),
  step_count      integer,
  timestamp       timestamptz default now()
);

alter table wearable_snapshots enable row level security;

create policy "wear_student_all" on wearable_snapshots
  for all to authenticated
  using (student_id = auth.uid()) with check (student_id = auth.uid());

create policy "wear_trainer_select" on wearable_snapshots
  for select to authenticated
  using (exists (
    select 1 from student_profiles
    where user_id = student_id and trainer_id = auth.uid()
  ));

-- ── 8. CHAT MESSAGES ─────────────────────────────────────────
create table if not exists chat_messages (
  id                 uuid primary key default gen_random_uuid(),
  sender_id          uuid references profiles(id) not null,
  receiver_id        uuid references profiles(id) not null,
  text               text not null,
  type               text default 'text' check (type in ('text','exerciseQuery','announcement')),
  linked_exercise_id uuid references exercises(id),
  linked_workout_id  uuid references workouts(id),
  sent_at            timestamptz default now(),
  is_read            boolean default false
);

alter table chat_messages enable row level security;

create policy "chat_select" on chat_messages
  for select to authenticated
  using (sender_id = auth.uid() or receiver_id = auth.uid());

create policy "chat_insert" on chat_messages
  for insert to authenticated with check (sender_id = auth.uid());

create policy "chat_update" on chat_messages
  for update to authenticated using (receiver_id = auth.uid());

-- Realtime para chat
alter publication supabase_realtime add table chat_messages;

-- ── 9. TRAINING SESSIONS ─────────────────────────────────────
create table if not exists training_sessions (
  id               uuid primary key default gen_random_uuid(),
  trainer_id       uuid references profiles(id) not null,
  student_id       uuid references profiles(id) not null,
  scheduled_at     timestamptz not null,
  duration_minutes integer default 60,
  location         text not null,
  status           text default 'pending' check (status in ('pending','confirmed','cancelled','completed')),
  notes            text
);

alter table training_sessions enable row level security;

create policy "ts_trainer_all" on training_sessions
  for all to authenticated
  using (trainer_id = auth.uid()) with check (trainer_id = auth.uid());

create policy "ts_student_select" on training_sessions
  for select to authenticated using (student_id = auth.uid());

-- ── 10. BODY MEASUREMENTS ────────────────────────────────────
create table if not exists body_measurements (
  id           uuid primary key default gen_random_uuid(),
  student_id   uuid references profiles(id) not null,
  date         date not null,
  weight_kg    numeric(5,2) not null,
  body_fat_pct numeric(4,1),
  waist_cm     numeric(5,1),
  hip_cm       numeric(5,1),
  chest_cm     numeric(5,1),
  arm_cm       numeric(5,1),
  thigh_cm     numeric(5,1)
);

alter table body_measurements enable row level security;

create policy "bm_student_all" on body_measurements
  for all to authenticated
  using (student_id = auth.uid()) with check (student_id = auth.uid());

create policy "bm_trainer_select" on body_measurements
  for select to authenticated
  using (exists (
    select 1 from student_profiles
    where user_id = student_id and trainer_id = auth.uid()
  ));

-- ── 11. APP NOTIFICATIONS ────────────────────────────────────
create table if not exists app_notifications (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid references profiles(id) not null,
  type         text not null,
  title        text not null,
  body         text not null,
  created_at   timestamptz default now(),
  is_read      boolean default false,
  action_route text
);

alter table app_notifications enable row level security;

create policy "notif_select" on app_notifications
  for select to authenticated using (user_id = auth.uid());

create policy "notif_update" on app_notifications
  for update to authenticated using (user_id = auth.uid());

-- Realtime para notificações
alter publication supabase_realtime add table app_notifications;

-- ── 12. STUDENT ANAMNESE ─────────────────────────────────────
create table if not exists student_anamnese (
  student_id             uuid references profiles(id) on delete cascade primary key,
  birth_date             date,
  sex                    text,
  profession             text,
  emergency_contact      text,
  conditions             text[] default '{}',
  medications            text,
  has_surgery            boolean default false,
  surgery_details        text,
  parq_answers           boolean[] default '{false,false,false,false,false,false,false}',
  sleep_hours            integer,
  stress_level           text,
  smoking                text,
  alcohol_days_per_week  integer,
  work_type              text,
  has_prior_experience   boolean default false,
  prior_experience_years integer,
  previous_activities    text[] default '{}',
  injuries               text,
  primary_goal           text,
  secondary_goal         text,
  time_frame             text,
  available_days         text[] default '{}',
  created_at             timestamptz default now(),
  updated_at             timestamptz
);

alter table student_anamnese enable row level security;

create policy "anamnese_student_all" on student_anamnese
  for all to authenticated
  using (student_id = auth.uid()) with check (student_id = auth.uid());

create policy "anamnese_trainer_select" on student_anamnese
  for select to authenticated
  using (exists (
    select 1 from student_profiles
    where user_id = student_id and trainer_id = auth.uid()
  ));

-- ── ÍNDICES ───────────────────────────────────────────────────
create index if not exists idx_workouts_student    on workouts(student_id);
create index if not exists idx_workouts_trainer    on workouts(trainer_id);
create index if not exists idx_workout_sets_workout on workout_sets(workout_id);
create index if not exists idx_chat_sender         on chat_messages(sender_id);
create index if not exists idx_chat_receiver       on chat_messages(receiver_id);
create index if not exists idx_chat_sent_at        on chat_messages(sent_at desc);
create index if not exists idx_wearable_student    on wearable_snapshots(student_id, timestamp desc);
create index if not exists idx_sessions_trainer    on training_sessions(trainer_id, scheduled_at);
create index if not exists idx_notif_user          on app_notifications(user_id, created_at desc);
create index if not exists idx_measurements_student on body_measurements(student_id, date desc);
