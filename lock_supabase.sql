-- ============================================
-- Awesome Adventure Library - 公開用セキュリティロックSQL
-- 管理画面とデータベースをしっかり保護するための設定です
-- ============================================

-- --------------------------------------------------------
-- 1. まず、テスト用の「誰でも読み書きできるゆるい設定」を削除します
-- --------------------------------------------------------
drop policy if exists "Anyone can read books" on books;
drop policy if exists "Anyone can insert books" on books;
drop policy if exists "Anyone can update books" on books;
drop policy if exists "Anyone can delete books" on books;

drop policy if exists "Anyone can read announcements" on announcements;
drop policy if exists "Anyone can manage announcements" on announcements;

drop policy if exists "Anyone can view files" on storage.objects;
drop policy if exists "Anyone can upload files" on storage.objects;
drop policy if exists "Anyone can update files" on storage.objects;
drop policy if exists "Anyone can delete files" on storage.objects;

-- --------------------------------------------------------
-- 2. 次に、本番用の「管理者だけが書き込める安全な設定」を適用します
-- --------------------------------------------------------

-- Books（本）のセキュリティ
create policy "Public books are viewable by everyone" on books for select using ( true );
create policy "Admins can insert books" on books for insert with check ( exists (select 1 from admins where id = auth.uid()) );
create policy "Admins can update books" on books for update using ( exists (select 1 from admins where id = auth.uid()) );
create policy "Admins can delete books" on books for delete using ( exists (select 1 from admins where id = auth.uid()) );

-- Announcements（お知らせ）のセキュリティ
create policy "Public announcements are viewable by everyone" on announcements for select using ( true );
create policy "Admins can manage announcements" on announcements for all using ( exists (select 1 from admins where id = auth.uid()) );

-- Admins（管理者リスト）のセキュリティ
create policy "Admins can view admin list" on admins for select using ( exists (select 1 from admins where id = auth.uid()) );

-- Storage（ファイル置き場）のセキュリティ
create policy "Public Access Covers and Books"
on storage.objects for select
using ( bucket_id in ('covers', 'books') );

create policy "Admin Insert Covers and Books"
on storage.objects for insert
with check (
  bucket_id in ('covers', 'books') 
  and exists (select 1 from public.admins where id = auth.uid())
);

create policy "Admin Update Covers and Books"
on storage.objects for update
using (
  bucket_id in ('covers', 'books') 
  and exists (select 1 from public.admins where id = auth.uid())
);

create policy "Admin Delete Covers and Books"
on storage.objects for delete
using (
  bucket_id in ('covers', 'books') 
  and exists (select 1 from public.admins where id = auth.uid())
);

-- --------------------------------------------------------
-- 3. 管理者アカウントの登録
-- --------------------------------------------------------
-- ※SupabaseのAuthentication（ログイン画面）でユーザーを作成した後に、
-- 以下のSQLでそのユーザーを管理者に設定します。
-- 'YOUR_ADMIN_EMAIL' の部分を、登録したメールアドレスに書き換えて実行してください。
insert into admins (id, email)
select id, email from auth.users
where email = 'YOUR_ADMIN_EMAIL' -- ← ここをあなたのメールアドレス（ログイン用）に変更
on conflict (id) do nothing;
