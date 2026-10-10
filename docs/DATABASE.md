# ডাটাবেজ পরিকল্পনা (Supabase / PostgreSQL)

## কেন Supabase
- ওপেনসোর্স, ভিতরে আসল PostgreSQL; হিসাব-নিকাশের জন্য ঠিক যা দরকার (সঠিক সংখ্যা `numeric`, সম্পর্কিত টেবিল, ট্রানজেকশন)।
- Auth (লগইন), Row Level Security (কে কী করতে পারবে), REST API ও `supabase-js` — আলাদা সার্ভার লাগে না। GitHub Pages-এর স্ট্যাটিক HTML থেকে সরাসরি ব্যবহার করা যায়।
- ফ্রি প্ল্যানের মূল সীমা (২০২৬ সালের নিবন্ধ অনুযায়ী; supabase.com/pricing-এ মিলিয়ে নিন): ২টি প্রজেক্ট, ৫০০ MB ডাটাবেজ, **৭ দিন কোনো কাজ না হলে প্রজেক্ট অটো-পজ হয়ে যায়** (ড্যাশবোর্ড থেকে রিস্টোর করতে হয়)। সমিতির হিসাবে ৫০০ MB কয়েক দশকেও শেষ হবে না; পজই আসল ঝামেলা।
  - সমাধান: মাসে অন্তত একবার নয়, **সপ্তাহে একবার** অ্যাপ খোলা বা একটি GitHub Actions cron দিয়ে সাপ্তাহিক একটি সহজ query চালানো। আর মাসে একবার ডাটা export (CSV/SQL dump) করে রাখুন।
- বিকল্প: **PocketBase** (একটি ফাইল, SQLite, নিজের সার্ভারে চালাতে হয়, পজ নেই কিন্তু সার্ভার আপনাকে দেখতে হবে), **Appwrite** (সেলফ-হোস্ট), Firebase (ওপেনসোর্স নয়, NoSQL বলে হিসাবের জন্য কম উপযোগী)।

## ফাংশন (অ্যাপ এগুলো ডাকে)
`add_txn`, `update_txn`, `delete_txn` (সফট ডিলিট), `add_transfer` (শুধু অ্যাডমিন), `next_doc_no`, `ping` (keep-alive)। প্রতিটিতে ভূমিকা যাচাই ও খাত-উপখাত মিল যাচাই আছে।

## সেটআপ ধাপ
পুরো ধাপে ধাপে টিউটোরিয়াল: `SUPABASE_SETUP.md`। নিচেরটি সংক্ষিপ্ত রূপ।

1. supabase.com → Sign up → **New project** (নাম: kmt-building, ডাটাবেজ পাসওয়ার্ড সংরক্ষণ করুন, Region: Singapore/নিকটতম)।
2. **SQL Editor → New query** → `supabase/schema.sql` পুরোটা পেস্ট করে Run। তারপর `supabase/seed.sql` Run।
3. **Authentication → Users → Add user**: প্রতিজন ব্যবহারকারীর ইমেইল ও পাসওয়ার্ড দিন। তারপর SQL Editor-এ তাদের `profiles`-এ বসান:
   `insert into profiles(id, full_name, role) select id, 'আপনার নাম', 'admin' from auth.users where email = 'you@example.com';`
4. **Project Settings → API**: `Project URL` ও `anon public key` কপি করুন (anon key ব্রাউজারে থাকা নিরাপদ, কারণ RLS সব সুরক্ষা দেয়; **service_role key কখনও HTML/GitHub-এ দেবেন না**)।
5. `index.html`-এ `<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>` যোগ করুন এবং `js/db.js` লিখুন যাতে `DB.list/add/update/remove` Supabase কল করে (আমি লিখে দিতে পারব)।

## টেবিল ও অ্যাট্রিবিউট

### profiles — ব্যবহারকারী ও ভূমিকা
| কলাম | ধরন | বিবরণ |
|---|---|---|
| id | uuid (PK, auth.users-এর FK) | লগইন ব্যবহারকারীর আইডি |
| full_name | text | নাম |
| role | enum: admin / accountant / viewer | admin = সব; accountant = আয়-ব্যয় এন্ট্রি ও সংশোধন; viewer = শুধু দেখা |
| is_active | boolean | নিষ্ক্রিয় করলে প্রবেশ বন্ধ |
| created_at | timestamptz | তৈরির সময় |

### accounts — হিসাব (নগদ, ন্যাশনাল ব্যাংক, পূবালী ব্যাংক)
id (PK), code (cash/nbl/pbl, unique), name, kind (cash/bank), bank_name, branch, **opening_balance** (numeric(14,2), শুধু admin বদলাতে পারবে), is_active।

### flats — ফ্ল্যাট ও মালিক (৪০টি)
id (PK), flat_no (unique, যেমন ২-এ), floor_no, owner_name, owner_phone (ঐচ্ছিক), is_active। মালিক বদলালে শুধু এখানে বদলান; পুরনো ইনভয়েসে আগের নাম থাকে (নিচের `owner_name` স্ন্যাপশট)।

### categories — প্রধান খাত ও উপ খাত
id (PK), kind (income/expense), name, **parent_id** (খালি = প্রধান খাত; থাকলে উপ খাত), sort_order, is_service_charge (মাসিক সার্ভিস চার্জ খাত চিহ্নিত করে), is_active। খাতের নাম বদলালে (যেমন "অফিস ও প্রশাসনিক" → "প্রশাসনিক") পুরনো লেনদেন আপনাআপনি নতুন নামে দেখাবে, কারণ লেনদেনে নাম নয় id সংরক্ষিত।

### transactions — আয়/ব্যয়ের লেনদেন (মূল টেবিল)
| কলাম | বিবরণ |
|---|---|
| id | uuid (PK) |
| doc_no | ইনভয়েস/ভাউচার নম্বর, unique (আয়-২০২৬-০০০১) |
| kind | income / expense |
| txn_date | লেনদেনের তারিখ |
| category_id, sub_category_id | প্রধান খাত ও উপ খাত (categories) |
| account_id | নগদ না কোন ব্যাংক (accounts) |
| amount | numeric(14,2), শূন্যের বেশি |
| flat_id | শুধু সার্ভিস চার্জে (flats) |
| owner_name | লেনদেনের সময়ের মালিকের নাম (স্ন্যাপশট, ইনভয়েসে বসে) |
| note | বিবরণ / ভাউচার নং |
| created_by / created_at | কে ও কখন এন্ট্রি করল |
| updated_by / updated_at | শেষ সংশোধন |
| deleted_at / deleted_by | **সফট ডিলিট** — হিসাবে আসল মুছে ফেলা হয় না, চিহ্ন দেওয়া হয়; রিপোর্টে বাদ যায়, অডিটে থাকে |

### service_charge_rates — সার্ভিস চার্জের মাসিক অঙ্ক (অ্যাডমিন সেটআপ)
id, flat_id, monthly_amount (খালি = ডিফল্ট অঙ্ক), effective_from (মাসের ১ তারিখ), created_by, created_at। ডিফল্ট অঙ্ক `settings` টেবিলে (`sc_default`)। অ্যাপ সবচেয়ে নতুন সারিটি ব্যবহার করে; অঙ্ক বদলালে নতুন তারিখসহ নতুন সারি যোগ হয় (পুরনো সারি অডিটে থাকে)।

### service_charge_months — কোন কোন মাসের সার্ভিস চার্জ
transaction_id (FK), month (মাসের ১ তারিখ, যেমন 2026-10-01), PK দুটি মিলে। একটি ইনভয়েসে একাধিক মাস থাকলে একাধিক সারি। এটি দিয়ে পরে "কোন ফ্ল্যাটের কোন মাস বাকি" বের করা যাবে।

### transfers — হিসাব থেকে হিসাবে ট্রান্সফার
id, transfer_date, from_account_id, to_account_id (দুটি এক হতে পারবে না), amount, note, created_by, created_at। শুধু admin যোগ করতে পারবে; কেউ বদলাতে/মুছতে পারবে না (ভুল হলে উল্টো ট্রান্সফার দিন)। আয়-ব্যয়ের মোটে ধরা হয় না।

### doc_counters — নম্বর গণনা
kind, year, last_no। `next_doc_no()` ফাংশন একই সঙ্গে দুজন এন্ট্রি দিলেও নম্বর দ্বিগুণ হতে দেয় না।

### audit_log — অডিট লগ
id, table_name, record_id, action (insert/update/delete), old_data, new_data (jsonb), user_id, at। ট্রিগার নিজে নিজে লেখে; শুধু admin দেখতে পারে।

### settings — সমিতির নাম ও ঠিকানা
key, value।

### v_account_balances (ভিউ)
প্রতিটি হিসাবের বর্তমান জের = প্রারম্ভিক জের + আয় − ব্যয় + আসা ট্রান্সফার − যাওয়া ট্রান্সফার।

## সম্পর্ক সংক্ষেপে
`transactions` → categories (২ বার), accounts, flats, profiles · `service_charge_months` → transactions · `transfers` → accounts (২ বার), profiles।

## বর্তমান localStorage ডাটা Supabase-এ আনা
অ্যাপে "ব্যাকআপ export (JSON)" বাটন যোগ করে সেই ফাইল একটি script দিয়ে `transactions`/`transfers`-এ import করা যাবে (পুরনো এন্ট্রির খাত নাম → categories id মিলিয়ে)। প্রয়োজনে আমি এই export/import স্ক্রিপ্ট লিখে দেব।

## নিরাপত্তা নোট
- localStorage-এর অ্যাডমিন পাসওয়ার্ড বাদ যাবে; Supabase-এ লগইন + role (admin/accountant/viewer) ও RLS নিয়ম থাকবে।
- `schema.sql`, `seed.sql` আসল PostgreSQL ও PostgREST-এ চালিয়ে পরীক্ষা করা হয়েছে (ভূমিকা, RLS, ফাংশন, লগইন-সহ পুরো অ্যাপ)। তবে আসল Supabase ড্যাশবোর্ডে আমি চালাইনি; কোনো ত্রুটি এলে লেখাটি পাঠান।
