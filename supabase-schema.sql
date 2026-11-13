-- VESPERA database schema for Supabase
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  display_name text default 'PLAYER',
  role text not null default 'player' check (role in ('player','admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  rank text not null default 'E' check (rank in ('E','D','C','B','A','S')),
  xp integer not null default 10 check (xp between 0 and 1000),
  task_date date not null default current_date,
  done boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.tasks enable row level security;

create or replace function public.is_vespera_admin()
returns boolean language sql stable security definer
set search_path = public
as $$
  select exists(select 1 from public.profiles where id = auth.uid() and role = 'admin');
$$;

create or replace function public.handle_new_vespera_user()
returns trigger language plpgsql security definer
set search_path = public
as $$
begin
  insert into public.profiles(id,email,display_name,role)
  values(new.id,new.email,coalesce(new.raw_user_meta_data->>'display_name','PLAYER'),'player')
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_vespera_auth_user_created on auth.users;
create trigger on_vespera_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_vespera_user();

drop policy if exists "profile read self or admin" on public.profiles;
create policy "profile read self or admin" on public.profiles
for select to authenticated using (id = auth.uid() or public.is_vespera_admin());

-- لا نسمح بتحديث role من واجهة المتصفح؛ تغيير صلاحيات الإدارة يتم من SQL Editor فقط.

drop policy if exists "task read owner or admin" on public.tasks;
create policy "task read owner or admin" on public.tasks
for select to authenticated using (user_id = auth.uid() or public.is_vespera_admin());

drop policy if exists "task insert owner" on public.tasks;
create policy "task insert owner" on public.tasks
for insert to authenticated with check (user_id = auth.uid());

drop policy if exists "task update owner or admin" on public.tasks;
create policy "task update owner or admin" on public.tasks
for update to authenticated using (user_id = auth.uid() or public.is_vespera_admin())
with check (user_id = auth.uid() or public.is_vespera_admin());

drop policy if exists "task delete owner or admin" on public.tasks;
create policy "task delete owner or admin" on public.tasks
for delete to authenticated using (user_id = auth.uid() or public.is_vespera_admin());

-- بعد إنشاء حسابك من صفحة الموقع، نفّذ هذا السطر مرة واحدة في SQL Editor
-- مع استبدال البريد ببريد حسابك:
-- update public.profiles set role = 'admin' where email = 'YOUR-EMAIL@example.com';
