-- Shared `purchases` table for epc-buybet (seller='pedrito') and
-- magnata-buybet (seller='magnata') — both projects point at the same
-- Supabase project (rdhamuwukwyuzwltprot), differentiated only by `seller`.
--
-- Run this once in the Supabase SQL editor for that project.

create table if not exists public.purchases (
  id uuid primary key default gen_random_uuid(),
  seller text not null check (seller in ('pedrito', 'magnata')),
  telegram_user_id bigint not null,
  telegram_username text,
  telegram_name text not null,
  game text not null,
  bet text not null,
  odd text not null,
  analysis text,
  markets text,
  image_url text,
  price numeric,
  stripe_session_id text unique,
  paid boolean not null default false,
  created_at timestamptz not null default now(),
  paid_at timestamptz,
  customer_email text
);

create index if not exists purchases_seller_user_paid_idx
  on public.purchases (seller, telegram_user_id, paid);

-- RLS: this table holds Telegram identity + purchased content, so it must
-- only ever be reachable through the service_role key (supabaseAdmin in
-- api/_lib/supabaseAdmin.js), never through the public anon key used for
-- `picks`. Enabling RLS with no policies denies all anon/authenticated
-- access; service_role bypasses RLS entirely.
alter table public.purchases enable row level security;
