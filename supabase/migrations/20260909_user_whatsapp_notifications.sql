-- Tambahkan nomor WhatsApp user untuk notifikasi approval reimbursement

alter table public.reimbursement_users
  add column if not exists whatsapp_number text;
