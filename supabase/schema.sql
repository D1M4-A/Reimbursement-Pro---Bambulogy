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
  approved_at timestamptz,
  verified_at timestamptz,
  paid_at date,
  payment_method text,
  receipt jsonb,
  payment_proof jsonb,
  odoo_bill_id bigint,
  odoo_bill_name text,
  odoo_synced_at timestamptz,
  odoo_sync_error text
);

alter table public.reimbursement_claims add column if not exists odoo_bill_id bigint;
alter table public.reimbursement_claims add column if not exists odoo_bill_name text;
alter table public.reimbursement_claims add column if not exists odoo_synced_at timestamptz;
alter table public.reimbursement_claims add column if not exists odoo_sync_error text;

create index if not exists idx_reimbursement_claims_status on public.reimbursement_claims(status);
create index if not exists idx_reimbursement_claims_unit on public.reimbursement_claims(unit);
create index if not exists idx_reimbursement_claims_date on public.reimbursement_claims(date);

alter table public.reimbursement_units enable row level security;
alter table public.reimbursement_users enable row level security;
alter table public.reimbursement_claims enable row level security;

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
