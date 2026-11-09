-- Run this once in Supabase SQL Editor. It sets up a single-school workspace.
create table if not exists public.members (
 user_id uuid primary key references auth.users(id) on delete cascade,
 role text not null default 'cashier' check (role in ('admin','cashier')),
 active boolean not null default true
);
create table if not exists public.transactions (
 id uuid primary key default gen_random_uuid(), date date not null,
 type text not null check(type in ('in','out')), amount numeric(14,2) not null check(amount>0),
 category text not null, reason text not null, person text not null default '',
 created_at timestamptz not null default now(), created_by uuid not null default auth.uid() references auth.users(id)
);
create table if not exists public.dues (
 id uuid primary key default gen_random_uuid(), name text not null, class_name text not null default '',
 expected numeric(14,2) not null check(expected>=0), paid numeric(14,2) not null default 0 check(paid>=0),
 due_date date, created_at timestamptz not null default now(), created_by uuid not null default auth.uid() references auth.users(id)
);
create table if not exists public.settings (
 id uuid primary key default gen_random_uuid(), opening_balance numeric(14,2) not null default 0,
 updated_at timestamptz not null default now(), updated_by uuid not null default auth.uid() references auth.users(id)
);
alter table public.members enable row level security;
alter table public.transactions enable row level security;
alter table public.dues enable row level security;
alter table public.settings enable row level security;
-- Only enabled members can use the school data. Admins and cashiers may manage finance rows.
drop policy if exists member_self_read on public.members;
create policy member_self_read on public.members for select to authenticated using (user_id=auth.uid());
drop policy if exists finance_member_all on public.transactions;
create policy finance_member_all on public.transactions for all to authenticated using (exists(select 1 from public.members m where m.user_id=auth.uid() and m.active)) with check (exists(select 1 from public.members m where m.user_id=auth.uid() and m.active));
drop policy if exists dues_member_all on public.dues;
create policy dues_member_all on public.dues for all to authenticated using (exists(select 1 from public.members m where m.user_id=auth.uid() and m.active)) with check (exists(select 1 from public.members m where m.user_id=auth.uid() and m.active));
drop policy if exists settings_member_all on public.settings;
create policy settings_member_all on public.settings for all to authenticated using (exists(select 1 from public.members m where m.user_id=auth.uid() and m.active)) with check (exists(select 1 from public.members m where m.user_id=auth.uid() and m.active));
-- Realtime publishes updates to other logged-in members.
do $$ begin alter publication supabase_realtime add table public.transactions; exception when duplicate_object then null; end $$;
do $$ begin alter publication supabase_realtime add table public.dues; exception when duplicate_object then null; end $$;
do $$ begin alter publication supabase_realtime add table public.settings; exception when duplicate_object then null; end $$;
-- IMPORTANT: After the first user signs up, get their auth user UUID from Authentication > Users,
-- then run: insert into public.members(user_id,role) values ('PASTE-UUID-HERE','admin');
-- To authorize each other member after signup, repeat with their UUID and role 'cashier'.
