-- ============================================================
-- Koshly — Supabase PostgreSQL Schema
-- Run this in the Supabase SQL Editor (in order, top to bottom).
-- ============================================================


-- ------------------------------------------------------------
-- 1. ENUM TYPES
-- ------------------------------------------------------------
create type exam_type as enum ('ielts', 'pte', 'det', 'celpip');
create type subscription_status as enum ('free', 'premium');


-- ------------------------------------------------------------
-- 2. USERS
-- Mirrors auth.users. Auto-populated via trigger on signup.
-- ------------------------------------------------------------
create table users (
  id                    uuid primary key references auth.users(id) on delete cascade,
  email                 text not null,
  full_name             text,
  subscription_status   subscription_status not null default 'free',
  free_tests_remaining  int not null default 3,
  primary_exam          exam_type,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);


-- ------------------------------------------------------------
-- 3. MOCK TESTS
-- Top-level test container per exam.
-- ------------------------------------------------------------
create table mock_tests (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,
  exam_type   exam_type not null,
  created_at  timestamptz not null default now()
);


-- ------------------------------------------------------------
-- 4. TEST SECTIONS
-- Each section belongs to a mock_test.
-- layout_components (JSONB) stores the full UI schema dynamically.
--
-- Example layout_components value:
-- [
--   { "type": "image_stimulus",   "url": "https://..." },
--   { "type": "audio_player",     "url": "https://...", "max_plays": 2 },
--   { "type": "long_text_passage","content": "..." },
--   { "type": "multiple_choice",  "question": "...", "options": ["A","B","C","D"], "correct_index": 2 },
--   { "type": "microphone",       "prompt": "Describe the image.", "max_seconds": 60 }
-- ]
-- ------------------------------------------------------------
create table test_sections (
  id                  uuid primary key default gen_random_uuid(),
  mock_test_id        uuid not null references mock_tests(id) on delete cascade,
  section_name        text not null,
  section_type        text not null,   -- 'reading' | 'writing' | 'speaking' | 'listening'
  order_index         int not null default 0,
  layout_components   jsonb not null default '[]',
  created_at          timestamptz not null default now()
);


-- ------------------------------------------------------------
-- 5. AI EVALUATIONS  (Premium Moat)
-- Stores AI-graded writing and speaking submissions.
--
-- sub_scores JSONB example (IELTS Writing):
-- {
--   "task_achievement": 7.0,
--   "coherence_cohesion": 6.5,
--   "lexical_resource": 7.0,
--   "grammatical_range": 6.5
-- }
--
-- detailed_feedback JSONB example:
-- {
--   "strengths": ["Clear thesis", "Good use of linking words"],
--   "improvements": ["Vary sentence structure", "Expand vocabulary range"],
--   "model_answer_excerpt": "..."
-- }
-- ------------------------------------------------------------
create table ai_evaluations (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null references users(id) on delete cascade,
  test_section_id   uuid not null references test_sections(id) on delete cascade,
  audio_url         text,           -- null for text-only submissions
  text_response     text,           -- null for audio-only submissions
  overall_score     numeric(4,1),
  sub_scores        jsonb not null default '{}',
  detailed_feedback jsonb not null default '{}',
  created_at        timestamptz not null default now()
);


-- ------------------------------------------------------------
-- 6. USER TEST RESULTS  (Static scores: Reading, Listening)
-- Tracks objective, auto-marked section scores.
--
-- section_scores JSONB example:
-- { "reading": 32, "listening": 28 }
-- ------------------------------------------------------------
create table user_test_results (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references users(id) on delete cascade,
  mock_test_id    uuid not null references mock_tests(id) on delete cascade,
  section_scores  jsonb not null default '{}',
  total_score     numeric(5,2),
  completed_at    timestamptz,
  created_at      timestamptz not null default now()
);


-- ------------------------------------------------------------
-- 7. INDEXES
-- ------------------------------------------------------------
create index on test_sections(mock_test_id);
create index on ai_evaluations(user_id);
create index on ai_evaluations(test_section_id);
create index on user_test_results(user_id);
create index on user_test_results(mock_test_id);


-- ------------------------------------------------------------
-- 8. UPDATED_AT TRIGGER (users table)
-- ------------------------------------------------------------
create or replace function handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger users_updated_at
  before update on users
  for each row execute function handle_updated_at();


-- ------------------------------------------------------------
-- 9. AUTO-CREATE USER PROFILE ON GOOGLE OAUTH SIGNUP
-- Fires after a new row is inserted into auth.users.
-- ------------------------------------------------------------
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into public.users (id, email, full_name)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data->>'full_name'
  );
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();


-- ------------------------------------------------------------
-- 10. ROW LEVEL SECURITY (RLS)
-- All tables locked down. Policies grant minimum required access.
-- ------------------------------------------------------------
alter table users             enable row level security;
alter table mock_tests        enable row level security;
alter table test_sections     enable row level security;
alter table ai_evaluations    enable row level security;
alter table user_test_results enable row level security;

-- users: each user reads/updates only their own row
create policy "users: select own"
  on users for select
  using (auth.uid() = id);

create policy "users: update own"
  on users for update
  using (auth.uid() = id);

-- mock_tests: all authenticated users can read (content is not user-specific)
create policy "mock_tests: select authenticated"
  on mock_tests for select
  to authenticated
  using (true);

-- test_sections: all authenticated users can read
create policy "test_sections: select authenticated"
  on test_sections for select
  to authenticated
  using (true);

-- ai_evaluations: users access only their own evaluations
create policy "ai_evaluations: select own"
  on ai_evaluations for select
  using (auth.uid() = user_id);

create policy "ai_evaluations: insert own"
  on ai_evaluations for insert
  with check (auth.uid() = user_id);

-- user_test_results: users access only their own results
create policy "user_test_results: select own"
  on user_test_results for select
  using (auth.uid() = user_id);

create policy "user_test_results: insert own"
  on user_test_results for insert
  with check (auth.uid() = user_id);
