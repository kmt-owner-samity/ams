-- =====================================================================
-- কাজী মোশাররফ টাওয়ার ভবন মালিক সমিতি — Supabase (PostgreSQL) স্কিমা
-- ব্যবহার: Supabase Dashboard → SQL Editor → New query → পুরোটা পেস্ট করে Run
-- =====================================================================

-- ১) ধরন (enum)
create type user_role   as enum ('admin','accountant','viewer');
create type txn_kind    as enum ('income','expense');
create type account_kind as enum ('cash','bank');

-- ২) ব্যবহারকারী (Supabase Auth-এর auth.users-এর সঙ্গে যুক্ত)
create table profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  full_name   text not null,
  role        user_role not null default 'viewer',
  is_active   boolean not null default true,
  created_at  timestamptz not null default now()
);

-- ৩) হিসাব: নগদ টাকা, ন্যাশনাল ব্যাংক, পূবালী ব্যাংক
create table accounts (
  id              smallint generated always as identity primary key,
  code            text not null unique,            -- cash | nbl | pbl
  name            text not null,                   -- নগদ টাকা / ন্যাশনাল ব্যাংক পিএলসি
  kind            account_kind not null,
  bank_name       text,
  branch          text,
  opening_balance numeric(14,2) not null default 0 check (opening_balance >= 0),
  is_active       boolean not null default true
);

-- ৪) ফ্ল্যাট ও মালিক
create table flats (
  id          smallint generated always as identity primary key,
  flat_no     text not null unique,                -- ২-এ, ১০-সি ...
  floor_no    smallint not null,
  owner_name  text not null,
  owner_phone text,
  is_active   boolean not null default true
);

-- ৫) খাত (প্রধান খাত + উপ খাত একই টেবিলে; parent_id থাকলে উপ খাত)
create table categories (
  id         integer generated always as identity primary key,
  kind       txn_kind not null,
  name       text not null,
  parent_id  integer references categories(id) on delete restrict,
  sort_order smallint not null default 0,
  is_service_charge boolean not null default false,  -- 'মাসিক সার্ভিস চার্জ' খাতের জন্য true
  is_active  boolean not null default true,
  unique (kind, parent_id, name)
);

-- ৫-ক) সার্ভিস চার্জের মাসিক অঙ্ক (অ্যাডমিন সেটআপ): কোন ফ্ল্যাটের কত, কোন মাস থেকে
create table service_charge_rates (
  id             integer generated always as identity primary key,
  flat_id        smallint references flats(id),          -- খালি = সব ফ্ল্যাটের ডিফল্ট
  monthly_amount numeric(14,2) not null check (monthly_amount >= 0),
  effective_from date not null check (extract(day from effective_from) = 1),
  created_by     uuid references profiles(id),
  created_at     timestamptz not null default now(),
  unique (flat_id, effective_from)
);

-- ৬) ইনভয়েস/ভাউচার নম্বরের কাউন্টার (আয়-২০২৬-০০০১)
create table doc_counters (
  kind       txn_kind not null,
  year       smallint not null,
  last_no    integer  not null default 0,
  primary key (kind, year)
);

-- ৭) আয়/ব্যয়ের লেনদেন
create table transactions (
  id            uuid primary key default gen_random_uuid(),
  doc_no        text not null unique,              -- আয়-২০২৬-০০০১ / ব্যয়-২০২৬-০০০১
  kind          txn_kind not null,
  txn_date      date not null,
  category_id   integer not null references categories(id),   -- প্রধান খাত
  sub_category_id integer not null references categories(id), -- উপ খাত
  account_id    smallint not null references accounts(id),    -- নগদ / কোন ব্যাংক
  amount        numeric(14,2) not null check (amount > 0),
  flat_id       smallint references flats(id),                -- শুধু সার্ভিস চার্জে
  owner_name    text,                                         -- লেনদেনের সময়ের মালিকের নাম (স্ন্যাপশট)
  note          text,
  created_by    uuid not null references profiles(id),
  created_at    timestamptz not null default now(),
  updated_by    uuid references profiles(id),
  updated_at    timestamptz,
  deleted_at    timestamptz,                                  -- সফট ডিলিট (হিসাবের নিয়মে মুছে ফেলা হয় না)
  deleted_by    uuid references profiles(id)
);
create index on transactions (txn_date) where deleted_at is null;
create index on transactions (account_id, txn_date);
create index on transactions (category_id);
create index on transactions (flat_id);

-- ৮) সার্ভিস চার্জ কোন কোন মাসের (একাধিক মাস → একটি ইনভয়েস)
create table service_charge_months (
  transaction_id uuid not null references transactions(id) on delete cascade,
  month          date not null check (extract(day from month) = 1),  -- মাসের ১ তারিখ, যেমন 2026-10-01
  primary key (transaction_id, month)
);
create index on service_charge_months (month);

-- ৯) এক হিসাব থেকে আরেক হিসাবে ট্রান্সফার (আয়/ব্যয় নয়)
create table transfers (
  id               uuid primary key default gen_random_uuid(),
  transfer_date    date not null,
  from_account_id  smallint not null references accounts(id),
  to_account_id    smallint not null references accounts(id),
  amount           numeric(14,2) not null check (amount > 0),
  note             text,
  created_by       uuid not null references profiles(id),
  created_at       timestamptz not null default now(),
  check (from_account_id <> to_account_id)
);

-- ১০) অডিট লগ (কে কখন কী বদলালো)
create table audit_log (
  id         bigint generated always as identity primary key,
  table_name text not null,
  record_id  text not null,
  action     text not null,                         -- insert | update | delete
  old_data   jsonb,
  new_data   jsonb,
  user_id    uuid,
  at         timestamptz not null default now()
);

-- ১১) সেটিংস (সমিতির নাম, ঠিকানা ইত্যাদি)
create table settings (
  key   text primary key,
  value text not null
);

-- ---------------------------------------------------------------------
-- নম্বর তৈরির ফাংশন: select next_doc_no('income','2026-10-08')  →  আয়-২০২৬-০০০১
-- ---------------------------------------------------------------------
create or replace function next_doc_no(p_kind txn_kind, p_date date) returns text
language plpgsql security definer as $$
declare y smallint := extract(year from p_date); n integer;
begin
  insert into doc_counters(kind, year, last_no) values (p_kind, y, 1)
  on conflict (kind, year) do update set last_no = doc_counters.last_no + 1
  returning last_no into n;
  return (case p_kind when 'income' then 'আয়' else 'ব্যয়' end) || '-' || y || '-' || lpad(n::text, 4, '0');
end $$;

-- ---------------------------------------------------------------------
-- অডিট ট্রিগার
-- ---------------------------------------------------------------------
create or replace function log_change() returns trigger
language plpgsql security definer as $$
begin
  insert into audit_log(table_name, record_id, action, old_data, new_data, user_id)
  values (tg_table_name, case when tg_op = 'DELETE' then old.id::text else new.id::text end, lower(tg_op),
          case when tg_op <> 'INSERT' then to_jsonb(old) end,
          case when tg_op <> 'DELETE' then to_jsonb(new) end, auth.uid());
  return coalesce(new, old);
end $$;
create trigger trg_audit_tx  after insert or update or delete on transactions for each row execute function log_change();
create trigger trg_audit_trf after insert or update or delete on transfers    for each row execute function log_change();
create trigger trg_audit_acc after update on accounts                         for each row execute function log_change();

-- ---------------------------------------------------------------------
-- বর্তমান জের (প্রতিটি হিসাবের): প্রারম্ভিক জের + আয় − ব্যয় ± ট্রান্সফার
-- ---------------------------------------------------------------------
create or replace view v_account_balances as
select a.id, a.code, a.name,
       a.opening_balance
       + coalesce((select sum(amount) from transactions t where t.account_id=a.id and t.kind='income'  and t.deleted_at is null),0)
       - coalesce((select sum(amount) from transactions t where t.account_id=a.id and t.kind='expense' and t.deleted_at is null),0)
       + coalesce((select sum(amount) from transfers x where x.to_account_id=a.id),0)
       - coalesce((select sum(amount) from transfers x where x.from_account_id=a.id),0) as balance
from accounts a;

-- ---------------------------------------------------------------------
-- নিরাপত্তা (Row Level Security): লগইন ছাড়া কিছুই দেখা/বদলানো যাবে না
-- ---------------------------------------------------------------------
create or replace function my_role() returns user_role
language sql stable security definer as $$ select role from profiles where id = auth.uid() and is_active $$;

alter table profiles enable row level security;  alter table accounts enable row level security;
alter table flats enable row level security;     alter table categories enable row level security;
alter table transactions enable row level security; alter table service_charge_months enable row level security;
alter table transfers enable row level security;  alter table audit_log enable row level security;
alter table settings enable row level security;   alter table doc_counters enable row level security;
alter table service_charge_rates enable row level security;

-- পড়া: যেকোনো সক্রিয় ব্যবহারকারী
create policy read_all on accounts             for select using (my_role() is not null);
create policy read_all on flats                for select using (my_role() is not null);
create policy read_all on categories           for select using (my_role() is not null);
create policy read_all on transactions         for select using (my_role() is not null);
create policy read_all on service_charge_months for select using (my_role() is not null);
create policy read_all on transfers            for select using (my_role() is not null);
create policy read_all on settings             for select using (my_role() is not null);
create policy read_all on service_charge_rates for select using (my_role() is not null);
create policy admin_rate on service_charge_rates for all using (my_role() = 'admin') with check (my_role() = 'admin');
create policy read_self on profiles            for select using (id = auth.uid() or my_role() = 'admin');

-- লেখা: আয়/ব্যয় এন্ট্রি ও সংশোধন — admin ও accountant
create policy write_tx  on transactions          for insert with check (my_role() in ('admin','accountant'));
create policy edit_tx   on transactions          for update using (my_role() in ('admin','accountant'));
create policy write_scm on service_charge_months for all using (my_role() in ('admin','accountant')) with check (my_role() in ('admin','accountant'));
-- ট্রান্সফার, প্রারম্ভিক জের, ফ্ল্যাট/খাত/সেটিংস — শুধু admin
create policy admin_trf  on transfers  for insert with check (my_role() = 'admin');
create policy admin_acc  on accounts   for update using (my_role() = 'admin');
create policy admin_flat on flats      for all using (my_role() = 'admin') with check (my_role() = 'admin');
create policy admin_cat  on categories for all using (my_role() = 'admin') with check (my_role() = 'admin');
create policy admin_set  on settings   for all using (my_role() = 'admin') with check (my_role() = 'admin');
create policy admin_log  on audit_log  for select using (my_role() = 'admin');
-- transfers-এ update/delete এবং transactions-এ delete-এর কোনো policy নেই = কেউ পারবে না

-- ---------------------------------------------------------------------
-- প্রাথমিক ডাটা
-- ---------------------------------------------------------------------
insert into accounts(code,name,kind,bank_name,branch) values
 ('cash','নগদ টাকা','cash',null,null),
 ('nbl','ন্যাশনাল ব্যাংক পিএলসি','bank','ন্যাশনাল ব্যাংক পিএলসি','আসাদ গেট শাখা'),
 ('pbl','পূবালী ব্যাংক পিএলসি','bank','পূবালী ব্যাংক পিএলসি','মোহাম্মদপুর শাখা');

insert into settings(key,value) values
 ('org_name','কাজী মোশাররফ টাওয়ার ভবন মালিক সমিতি'),
 ('org_address','বাসা নং ৩/৪, ব্লক-এ, আসাদ এভিনিউ, ঢাকা-১২০৭');

-- খাত ও উপ খাত এবং ৪০টি ফ্ল্যাট আলাদা seed ফাইলে (seed.sql) যোগ করুন — docs/DATABASE.md দেখুন
