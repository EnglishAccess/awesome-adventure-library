-- ============================================
-- Awesome Adventure Library - 初期セットアップSQL
-- 新しいSupabaseプロジェクトで実行してください
-- ============================================

-- 1. テーブル作成
create extension if not exists "uuid-ossp";

-- 本のテーブル
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

-- お知らせテーブル
create table if not exists announcements (
  id uuid default gen_random_uuid() primary key,
  message text not null,
  link_url text,
  is_active boolean default true,
  start_at timestamp with time zone default timezone('utc'::text, now()),
  end_at timestamp with time zone,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. RLS (Row Level Security) を有効化
alter table books enable row level security;
alter table announcements enable row level security;

-- 3. RLSポリシー: テスト用（誰でも読み書き可能）
-- ※ 本番環境では管理者のみ書き込み可能にすること
create policy "Anyone can read books" on books for select using (true);
create policy "Anyone can insert books" on books for insert with check (true);
create policy "Anyone can update books" on books for update using (true);
create policy "Anyone can delete books" on books for delete using (true);

create policy "Anyone can read announcements" on announcements for select using (true);
create policy "Anyone can manage announcements" on announcements for insert with check (true);

-- 4. ストレージバケット作成
insert into storage.buckets (id, name, public) 
values ('books', 'books', true) 
on conflict (id) do nothing;

insert into storage.buckets (id, name, public) 
values ('covers', 'covers', true) 
on conflict (id) do nothing;

-- 5. ストレージのRLSポリシー: テスト用（誰でもアップロード可能）
create policy "Anyone can view files"
on storage.objects for select
using ( bucket_id in ('covers', 'books') );

create policy "Anyone can upload files"
on storage.objects for insert
with check ( bucket_id in ('covers', 'books') );

create policy "Anyone can update files"
on storage.objects for update
using ( bucket_id in ('covers', 'books') );

create policy "Anyone can delete files"
on storage.objects for delete
using ( bucket_id in ('covers', 'books') );
