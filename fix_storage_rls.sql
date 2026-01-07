-- Storage (ファイル置き場) のセキュリティ設定を追加するSQL

-- 1. 誰でもファイル（表紙・本文）を見れるようにする
create policy "Public Access Covers and Books"
on storage.objects for select
using ( bucket_id in ('covers', 'books') );

-- 2. 管理者だけがファイルをアップロードできるようにする
create policy "Admin Insert Covers and Books"
on storage.objects for insert
with check (
  bucket_id in ('covers', 'books') 
  and exists (select 1 from public.admins where id = auth.uid())
);

-- 3. 管理者だけがファイルを更新できるようにする
create policy "Admin Update Covers and Books"
on storage.objects for update
using (
  bucket_id in ('covers', 'books') 
  and exists (select 1 from public.admins where id = auth.uid())
);

-- 4. 管理者だけがファイルを削除できるようにする
create policy "Admin Delete Covers and Books"
on storage.objects for delete
using (
  bucket_id in ('covers', 'books') 
  and exists (select 1 from public.admins where id = auth.uid())
);
