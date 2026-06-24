-- EDITH - Supabase Schema
-- Run this in your Supabase SQL Editor (idempotent)

-- Enable necessary extensions
create extension if not exists "pgcrypto";

-- 1. identities
create table if not exists public.identities (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  handle text not null,
  created_at timestamptz not null default now(),
  rotated_at timestamptz not null default now()
);
alter table public.identities enable row level security;

create index if not exists idx_identities_user_id on public.identities(user_id);

drop policy if exists "Users can read own identities" on public.identities;
create policy "Users can read own identities"
  on public.identities for select
  using (auth.uid() = user_id);

drop policy if exists "Users can insert own identities" on public.identities;
create policy "Users can insert own identities"
  on public.identities for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users can delete own identities" on public.identities;
create policy "Users can delete own identities"
  on public.identities for delete
  using (auth.uid() = user_id);

-- 2. channels
create table if not exists public.channels (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz not null default now()
);
alter table public.channels enable row level security;

drop policy if exists "Users can read channels they belong to" on public.channels;
create policy "Users can read channels they belong to"
  on public.channels for select
  using (
    exists (
      select 1 from public.channel_members
      where channel_id = id and user_id = auth.uid()
    )
  );

drop policy if exists "Users can delete channels they belong to" on public.channels;
create policy "Users can delete channels they belong to"
  on public.channels for delete
  using (
    exists (
      select 1 from public.channel_members
      where channel_id = id and user_id = auth.uid()
    )
  );

-- 3. channel_members
create table if not exists public.channel_members (
  id uuid primary key default gen_random_uuid(),
  channel_id uuid not null references public.channels(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(channel_id, user_id)
);
alter table public.channel_members enable row level security;

create index if not exists idx_channel_members_user_id on public.channel_members(user_id);
create index if not exists idx_channel_members_channel_id on public.channel_members(channel_id);

drop policy if exists "Users can read own memberships" on public.channel_members;
create policy "Users can read own memberships"
  on public.channel_members for select
  using (auth.uid() = user_id);

drop policy if exists "Users can delete own memberships" on public.channel_members;
create policy "Users can delete own memberships"
  on public.channel_members for delete
  using (auth.uid() = user_id);

-- 4. messages
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  channel_id uuid not null references public.channels(id) on delete cascade,
  sender_id uuid not null references auth.users(id) on delete cascade,
  content text not null,
  media_url text,
  media_type text,
  expires_at timestamptz,
  created_at timestamptz not null default now()
);
alter table public.messages enable row level security;

create index if not exists idx_messages_channel_id on public.messages(channel_id);
create index if not exists idx_messages_sender_id on public.messages(sender_id);

drop policy if exists "Users can read messages in their channels" on public.messages;
create policy "Users can read messages in their channels"
  on public.messages for select
  using (
    exists (
      select 1 from public.channel_members
      where channel_id = messages.channel_id and user_id = auth.uid()
    )
  );

drop policy if exists "Users can insert messages in their channels" on public.messages;
create policy "Users can insert messages in their channels"
  on public.messages for insert
  with check (
    sender_id = auth.uid()
    and exists (
      select 1 from public.channel_members
      where channel_id = messages.channel_id and user_id = auth.uid()
    )
  );

drop policy if exists "Users can delete own messages" on public.messages;
create policy "Users can delete own messages"
  on public.messages for delete
  using (sender_id = auth.uid());

-- Enable realtime for messages (idempotent)
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and tablename = 'messages' and schemaname = 'public'
  ) then
    alter publication supabase_realtime add table public.messages;
  end if;
end $$;

-- 5. vault_items
create table if not exists public.vault_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  media_url text not null,
  type text not null check (type in ('photo', 'video', 'document')),
  secret_code text not null,
  thumbnail_url text,
  saved_at timestamptz not null default now()
);
alter table public.vault_items enable row level security;

create index if not exists idx_vault_items_user_id on public.vault_items(user_id);

drop policy if exists "Users can read own vault items" on public.vault_items;
create policy "Users can read own vault items"
  on public.vault_items for select
  using (auth.uid() = user_id);

drop policy if exists "Users can insert own vault items" on public.vault_items;
create policy "Users can insert own vault items"
  on public.vault_items for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users can delete own vault items" on public.vault_items;
create policy "Users can delete own vault items"
  on public.vault_items for delete
  using (auth.uid() = user_id);

-- 6. user_stats
create table if not exists public.user_stats (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade unique,
  messages_destroyed bigint not null default 0,
  media_expired bigint not null default 0,
  identities_rotated bigint not null default 0,
  tokens_recycled bigint not null default 0,
  data_purity numeric(5,2) not null default 100.00,
  storage_used_mb numeric(10,2) not null default 0.00,
  updated_at timestamptz not null default now()
);
alter table public.user_stats enable row level security;

create index if not exists idx_user_stats_user_id on public.user_stats(user_id);

drop policy if exists "Users can read own stats" on public.user_stats;
create policy "Users can read own stats"
  on public.user_stats for select
  using (auth.uid() = user_id);

-- 7. invite_tokens
create table if not exists public.invite_tokens (
  id uuid primary key default gen_random_uuid(),
  token text not null unique,
  created_by uuid not null references auth.users(id) on delete cascade,
  expires_at timestamptz not null,
  created_at timestamptz not null default now()
);
alter table public.invite_tokens enable row level security;

create index if not exists idx_invite_tokens_created_by on public.invite_tokens(created_by);

drop policy if exists "Users can read own tokens" on public.invite_tokens;
create policy "Users can read own tokens"
  on public.invite_tokens for select
  using (auth.uid() = created_by);

drop policy if exists "Users can insert own tokens" on public.invite_tokens;
create policy "Users can insert own tokens"
  on public.invite_tokens for insert
  with check (auth.uid() = created_by);

drop policy if exists "Users can delete own tokens" on public.invite_tokens;
create policy "Users can delete own tokens"
  on public.invite_tokens for delete
  using (auth.uid() = created_by);
