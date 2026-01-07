-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- 1. Books Table
create table books (
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

-- 2. Announcements Table
create table announcements (
  id uuid default gen_random_uuid() primary key,
  message text not null,
  link_url text,
  is_active boolean default true,
  start_at timestamp with time zone default timezone('utc'::text, now()),
  end_at timestamp with time zone,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Admins Table
create table admins (
  id uuid references auth.users not null primary key,
  email text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS
alter table books enable row level security;
alter table announcements enable row level security;
alter table admins enable row level security;

-- Storage Buckets
insert into storage.buckets (id, name, public) values ('books', 'books', true);
insert into storage.buckets (id, name, public) values ('covers', 'covers', true);

-- RLS Policies

-- Books: Anyone can view, Admin can edit
create policy "Public books are viewable by everyone"
  on books for select
  using ( true );

create policy "Admins can insert books"
  on books for insert
  with check ( exists (select 1 from admins where id = auth.uid()) );

create policy "Admins can update books"
  on books for update
  using ( exists (select 1 from admins where id = auth.uid()) );

create policy "Admins can delete books"
  on books for delete
  using ( exists (select 1 from admins where id = auth.uid()) );

-- Announcements: Anyone can view, Admin can edit
create policy "Public announcements are viewable by everyone"
  on announcements for select
  using ( true );

create policy "Admins can manage announcements"
  on announcements for all
  using ( exists (select 1 from admins where id = auth.uid()) );

-- Admins: Only admins can view/edit admin list (Bootstrap problem: need manual insert first)
create policy "Admins can view admin list"
  on admins for select
  using ( exists (select 1 from admins where id = auth.uid()) );
