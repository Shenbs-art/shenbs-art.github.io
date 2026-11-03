-- FRAME portfolio: run this entire script in Supabase SQL Editor.
-- Public visitors can read photos. Only intellevine@gmail.com can upload/delete.
create table if not exists public.photos (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  path text not null unique,
  created_at timestamptz not null default now()
);

alter table public.photos enable row level security;

drop policy if exists "Photos are public to read" on public.photos;
create policy "Photos are public to read"
on public.photos for select
to anon, authenticated
using (true);

drop policy if exists "Admin can insert photos" on public.photos;
create policy "Admin can insert photos"
on public.photos for insert
to authenticated
with check ((auth.jwt() ->> 'email') = 'intellevine@gmail.com');

drop policy if exists "Admin can delete photos" on public.photos;
create policy "Admin can delete photos"
on public.photos for delete
to authenticated
using ((auth.jwt() ->> 'email') = 'intellevine@gmail.com');

insert into storage.buckets (id, name, public)
values ('portfolio', 'portfolio', true)
on conflict (id) do update set public = true;

drop policy if exists "Portfolio images are public to read" on storage.objects;
create policy "Portfolio images are public to read"
on storage.objects for select
to anon, authenticated
using (bucket_id = 'portfolio');

drop policy if exists "Admin can upload portfolio images" on storage.objects;
create policy "Admin can upload portfolio images"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'portfolio'
  and (auth.jwt() ->> 'email') = 'intellevine@gmail.com'
);

drop policy if exists "Admin can delete portfolio images" on storage.objects;
create policy "Admin can delete portfolio images"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'portfolio'
  and (auth.jwt() ->> 'email') = 'intellevine@gmail.com'
);
