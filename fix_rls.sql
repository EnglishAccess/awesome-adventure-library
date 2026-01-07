-- RLSの循環参照（無限ループ）を修正するパッチ

-- 1. 問題のある「管理者リスト閲覧」ポリシーを削除
drop policy if exists "Admins can view admin list" on admins;

-- 2. 新しいポリシーを作成
-- 「auth.uid()（ログイン中のID）が、テーブルのidと一致する場合のみ許可」
-- これにより、他の行を参照せずにチェックが完了するため、ループしません。
create policy "Admins can check themselves"
  on admins for select
  using ( auth.uid() = id );

-- 3. 念のため管理者ユーザーが消えていないか確認して登録
insert into admins (id, email)
select id, email from auth.users
where email = 'satoru@english-access.jp'
on conflict (id) do nothing;
