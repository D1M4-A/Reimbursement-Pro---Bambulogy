-- Jalankan di Supabase SQL Editor
-- Tabel unit bisnis
create table if not exists public.reimbursement_units (
  id bigint generated always as identity primary key,
  name text not null unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Tabel user aplikasi (sesuai form login saat ini)
create table if not exists public.reimbursement_users (
  id bigint generated always as identity primary key,
  name text not null,
  email text not null unique,
  password text not null,
  role text not null check (role in ('Admin','Finance','Manager','Karyawan')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Tabel pengajuan reimbursement
create table if not exists public.reimbursement_claims (
  id text primary key,
  employee text not null,
  owner_email text,
  unit text not null,
  category text not null,
  date date not null,
  amount bigint not null check (amount >= 0),
  vendor text not null default '',
  description text not null default '',
  travel_detail jsonb,
  travel_expense_items jsonb not null default '[]'::jsonb,
  bank text not null default '',
  account_number text not null default '',
  account_name text not null default '',
  status text not null check (status in ('Draft','Menunggu Approval','Diproses Finance','Siap Dibayar','Sudah Dibayar','Ditolak')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  approved_at timestamptz,
  verified_at timestamptz,
  paid_at date,
  payment_method text,
  created_by_email text,
  updated_by_email text,
  approved_by_email text,
  verified_by_email text,
  paid_by_email text,
  deleted_at timestamptz,
  deleted_by_email text,
  receipt jsonb,
  payment_proof jsonb,
  odoo_bill_id bigint,
  odoo_bill_name text,
  odoo_synced_at timestamptz,
  odoo_sync_error text
);

create table if not exists public.reimbursement_claim_audit_logs (
  id text primary key,
  claim_id text not null references public.reimbursement_claims(id),
  action text not null,
  actor_email text,
  actor_name text,
  actor_role text,
  source text not null default 'web-app',
  before_data jsonb,
  after_data jsonb,
  metadata jsonb,
  created_at timestamptz not null default now()
);

alter table public.reimbursement_claims add column if not exists owner_email text;
alter table public.reimbursement_claims add column if not exists updated_at timestamptz not null default now();
alter table public.reimbursement_claims add column if not exists odoo_bill_id bigint;
alter table public.reimbursement_claims add column if not exists odoo_bill_name text;
alter table public.reimbursement_claims add column if not exists odoo_synced_at timestamptz;
alter table public.reimbursement_claims add column if not exists odoo_sync_error text;
alter table public.reimbursement_claims add column if not exists created_by_email text;
alter table public.reimbursement_claims add column if not exists updated_by_email text;
alter table public.reimbursement_claims add column if not exists approved_by_email text;
alter table public.reimbursement_claims add column if not exists verified_by_email text;
alter table public.reimbursement_claims add column if not exists paid_by_email text;
alter table public.reimbursement_claims add column if not exists deleted_at timestamptz;
alter table public.reimbursement_claims add column if not exists deleted_by_email text;

create index if not exists idx_reimbursement_claims_owner_email on public.reimbursement_claims(owner_email);
create index if not exists idx_reimbursement_claims_status on public.reimbursement_claims(status);
create index if not exists idx_reimbursement_claims_unit on public.reimbursement_claims(unit);
create index if not exists idx_reimbursement_claims_date on public.reimbursement_claims(date);
create index if not exists idx_reimbursement_claims_status_unit_date on public.reimbursement_claims(status, unit, date desc);
create index if not exists idx_reimbursement_claims_owner_status_created on public.reimbursement_claims(owner_email, status, created_at desc);
create index if not exists idx_reimbursement_claims_status_created on public.reimbursement_claims(status, created_at desc);
create index if not exists idx_reimbursement_claims_deleted_at on public.reimbursement_claims(deleted_at);
create index if not exists idx_reimbursement_claim_audit_logs_claim_created on public.reimbursement_claim_audit_logs(claim_id, created_at desc);
create index if not exists idx_reimbursement_claim_audit_logs_actor_created on public.reimbursement_claim_audit_logs(actor_email, created_at desc);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_reimbursement_units_updated_at on public.reimbursement_units;
create trigger set_reimbursement_units_updated_at
before update on public.reimbursement_units
for each row
execute function public.set_updated_at();

drop trigger if exists set_reimbursement_users_updated_at on public.reimbursement_users;
create trigger set_reimbursement_users_updated_at
before update on public.reimbursement_users
for each row
execute function public.set_updated_at();

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

alter table public.reimbursement_units enable row level security;
alter table public.reimbursement_users enable row level security;
alter table public.reimbursement_claims enable row level security;
alter table public.reimbursement_claim_audit_logs enable row level security;

drop policy if exists reimbursement_units_full_access on public.reimbursement_units;
create policy reimbursement_units_full_access
on public.reimbursement_units
for all
to anon, authenticated
using (true)
with check (true);

drop policy if exists reimbursement_users_full_access on public.reimbursement_users;
create policy reimbursement_users_full_access
on public.reimbursement_users
for all
to anon, authenticated
using (true)
with check (true);

drop policy if exists reimbursement_claims_full_access on public.reimbursement_claims;
create policy reimbursement_claims_full_access
on public.reimbursement_claims
for all
to anon, authenticated
using (true)
with check (true);

drop policy if exists reimbursement_claim_audit_logs_full_access on public.reimbursement_claim_audit_logs;
create policy reimbursement_claim_audit_logs_full_access
on public.reimbursement_claim_audit_logs
for all
to anon, authenticated
using (true)
with check (true);

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
