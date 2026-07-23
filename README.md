# ProTracker

Esports fan app built with Flutter. Browse upcoming matches filtered by game, search pro players, and follow them to see their next scheduled match.

## Stack

- Flutter + `provider` for state management
- [Supabase](https://supabase.com) for auth (email/password) and storing followed players
- [PandaScore](https://pandascore.co) API (free tier) for match/player data

## Setup

### 1. Install dependencies

```
flutter pub get
```

### 2. Create a Supabase project

1. Create a free project at [supabase.com](https://supabase.com).
2. In the SQL Editor, run:

```sql
create table if not exists public.followed_players (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  player_id bigint not null,
  player_name text not null,
  player_image_url text,
  team_id bigint,
  team_name text,
  created_at timestamptz not null default now(),
  unique (user_id, player_id)
);

alter table public.followed_players enable row level security;

create policy "select own follows" on public.followed_players for select using (auth.uid() = user_id);
create policy "insert own follows" on public.followed_players for insert with check (auth.uid() = user_id);
create policy "delete own follows" on public.followed_players for delete using (auth.uid() = user_id);
```

3. Under Authentication → Providers, confirm Email is enabled. Optionally disable "Confirm email" under Authentication → Settings for faster local testing.

### 3. Configure secrets

Copy `.env.example` to `.env` and fill in the values (never commit `.env` — it's gitignored):

```
SUPABASE_URL=          # Project Settings -> API
SUPABASE_ANON_KEY=     # Project Settings -> API (anon/publishable key)
PANDASCORE_API_KEY=    # your PandaScore API key
```

### 4. Run

```
flutter run -d windows
```

(or `-d chrome`, `-d android`, `-d ios`, depending on target device.)

## Project structure

```
lib/
  config/      # env var loading
  models/      # data classes (Match, Player, Team, ...)
  services/    # PandaScore API client, Supabase auth/follows
  providers/   # ChangeNotifier state (auth, matches, followed players)
  screens/     # UI screens (auth, matches, players, followed)
  widgets/     # shared UI components
  utils/       # date formatting, etc.
```

## Tests

```
flutter test
```
