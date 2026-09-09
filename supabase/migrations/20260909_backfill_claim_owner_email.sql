-- Jalankan setelah kolom owner_email tersedia di public.reimbursement_claims
-- Mengisi owner_email untuk data lama berdasarkan kecocokan nama employee dengan nama user

alter table public.reimbursement_claims
add column if not exists owner_email text;

update public.reimbursement_claims as claims
set owner_email = users.email
from public.reimbursement_users as users
where coalesce(claims.owner_email, '') = ''
  and lower(regexp_replace(trim(claims.employee), '\s+', ' ', 'g'))
      = lower(regexp_replace(trim(users.name), '\s+', ' ', 'g'));

create index if not exists idx_reimbursement_claims_owner_email
  on public.reimbursement_claims(owner_email);
