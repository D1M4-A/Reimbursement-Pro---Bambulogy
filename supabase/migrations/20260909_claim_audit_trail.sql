-- Jalankan untuk mengaktifkan audit trail pengajuan reimbursement

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

alter table public.reimbursement_claims add column if not exists created_by_email text;
alter table public.reimbursement_claims add column if not exists updated_by_email text;
alter table public.reimbursement_claims add column if not exists approved_by_email text;
alter table public.reimbursement_claims add column if not exists verified_by_email text;
alter table public.reimbursement_claims add column if not exists paid_by_email text;
alter table public.reimbursement_claims add column if not exists deleted_at timestamptz;
alter table public.reimbursement_claims add column if not exists deleted_by_email text;

update public.reimbursement_claims
set created_by_email = coalesce(created_by_email, owner_email),
    updated_by_email = coalesce(updated_by_email, owner_email)
where created_by_email is null
   or updated_by_email is null;

create index if not exists idx_reimbursement_claims_deleted_at
  on public.reimbursement_claims(deleted_at);

create index if not exists idx_reimbursement_claim_audit_logs_claim_created
  on public.reimbursement_claim_audit_logs(claim_id, created_at desc);

create index if not exists idx_reimbursement_claim_audit_logs_actor_created
  on public.reimbursement_claim_audit_logs(actor_email, created_at desc);

alter table public.reimbursement_claim_audit_logs enable row level security;

drop policy if exists reimbursement_claim_audit_logs_full_access on public.reimbursement_claim_audit_logs;
create policy reimbursement_claim_audit_logs_full_access
on public.reimbursement_claim_audit_logs
for all
to anon, authenticated
using (true)
with check (true);
