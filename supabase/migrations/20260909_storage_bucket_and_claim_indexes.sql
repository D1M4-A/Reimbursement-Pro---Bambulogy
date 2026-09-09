-- Jalankan untuk menyiapkan storage lampiran dan index jangka panjang klaim

alter table public.reimbursement_claims
add column if not exists updated_at timestamptz not null default now();

create index if not exists idx_reimbursement_claims_status_unit_date
  on public.reimbursement_claims(status, unit, date desc);

create index if not exists idx_reimbursement_claims_owner_status_created
  on public.reimbursement_claims(owner_email, status, created_at desc);

create index if not exists idx_reimbursement_claims_status_created
  on public.reimbursement_claims(status, created_at desc);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_reimbursement_claims_updated_at on public.reimbursement_claims;
create trigger set_reimbursement_claims_updated_at
before update on public.reimbursement_claims
for each row
execute function public.set_updated_at();

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'reimbursement-attachments',
  'reimbursement-attachments',
  false,
  1572864,
  array['image/jpeg', 'image/png', 'image/webp', 'application/pdf']
)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists reimbursement_attachments_read on storage.objects;
create policy reimbursement_attachments_read
on storage.objects
for select
to anon, authenticated
using (bucket_id = 'reimbursement-attachments');

drop policy if exists reimbursement_attachments_write on storage.objects;
create policy reimbursement_attachments_write
on storage.objects
for insert
to anon, authenticated
with check (bucket_id = 'reimbursement-attachments');

drop policy if exists reimbursement_attachments_update on storage.objects;
create policy reimbursement_attachments_update
on storage.objects
for update
to anon, authenticated
using (bucket_id = 'reimbursement-attachments')
with check (bucket_id = 'reimbursement-attachments');
