-- 1. Create Tables
create extension if not exists "uuid-ossp";

create table if not exists books (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  author text not null,
  description text,
  cover_url text,
  file_url text,
  file_type text check (file_type in ('pdf', 'text')),
  view_count int default 0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table if not exists announcements (
  id uuid default gen_random_uuid() primary key,
  message text not null,
  link_url text,
  is_active boolean default true,
  start_at timestamp with time zone default timezone('utc'::text, now()),
  end_at timestamp with time zone,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table if not exists admins (
  id uuid references auth.users not null primary key,
  email text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Enable RLS
alter table books enable row level security;
alter table announcements enable row level security;
alter table admins enable row level security;

-- 3. Storage
insert into storage.buckets (id, name, public) 
values ('books', 'books', true) 
on conflict (id) do nothing;

insert into storage.buckets (id, name, public) 
values ('covers', 'covers', true) 
on conflict (id) do nothing;

-- 4. Policies (Re-create safely)
drop policy if exists "Public books are viewable by everyone" on books;
drop policy if exists "Admins can insert books" on books;
drop policy if exists "Admins can update books" on books;
drop policy if exists "Admins can delete books" on books;

create policy "Public books are viewable by everyone" on books for select using ( true );
create policy "Admins can insert books" on books for insert with check ( exists (select 1 from admins where id = auth.uid()) );
create policy "Admins can update books" on books for update using ( exists (select 1 from admins where id = auth.uid()) );
create policy "Admins can delete books" on books for delete using ( exists (select 1 from admins where id = auth.uid()) );

drop policy if exists "Public announcements are viewable by everyone" on announcements;
drop policy if exists "Admins can manage announcements" on announcements;

create policy "Public announcements are viewable by everyone" on announcements for select using ( true );
create policy "Admins can manage announcements" on announcements for all using ( exists (select 1 from admins where id = auth.uid()) );

drop policy if exists "Admins can view admin list" on admins;
create policy "Admins can view admin list" on admins for select using ( exists (select 1 from admins where id = auth.uid()) );

-- 5. Link Admin User
insert into admins (id, email)
select id, email from auth.users
where email = 'satoru@english-access.jp'
on conflict (id) do nothing;
