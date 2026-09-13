-- RESOVERSE — the shared world, on Supabase's free tier.
--
-- Run this once in your project's SQL editor (Supabase → SQL Editor → New
-- query → paste → Run). Then put the Project URL and the anon key into
-- RV_CONFIG near the bottom of index.html and the campus is shared: everyone
-- sees each other, one Ludo table, live chat, live jamming, shared roster,
-- shared event board, shared leaderboards. No accounts for anybody.

create table if not exists kv (
  path       text primary key,
  data       jsonb not null,
  updated_at timestamptz not null default now()
);

alter table kv enable row level security;

-- Anybody who can open the page can read and write this table. That is the
-- deliberate trade for "nobody has to sign up": there is nothing in here but
-- a game world. If you ever store something you would mind a stranger
-- changing, add Supabase Auth and replace `true` with a real check — the
-- game's code will not need touching.
drop policy if exists "read"   on kv;
drop policy if exists "insert" on kv;
drop policy if exists "update" on kv;
drop policy if exists "delete" on kv;

create policy "read"   on kv for select using (true);
create policy "insert" on kv for insert with check (true);
create policy "update" on kv for update using (true);
create policy "delete" on kv for delete using (true);

-- live updates
alter publication supabase_realtime add table kv;

-- Housekeeping you may want later: a finished Ludo table and a stale claim
-- both age out on their own in the game, but this clears anything abandoned.
-- delete from kv where path like 'tables/%' and updated_at < now() - interval '1 day';
