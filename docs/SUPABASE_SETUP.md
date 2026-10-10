# Supabase সেটআপ — সাইন আপ থেকে চালু পর্যন্ত (ধাপে ধাপে)

আনুমানিক সময়: ৩০–৪০ মিনিট। কোনো কোড লেখা লাগবে না; শুধু কপি-পেস্ট।
> Supabase-এর ড্যাশবোর্ডের বোতাম/মেনুর নাম মাঝে মাঝে বদলায়। কিছু না মিললে কাছাকাছি নামের মেনু দেখুন বা supabase.com/docs দেখুন।

## ধাপ ১: অ্যাকাউন্ট খোলা
1. **supabase.com**-এ যান → **Start your project** (বা Sign in) → "Continue with GitHub" অথবা ইমেইল দিয়ে সাইন আপ করুন।
2. ইমেইল দিয়ে খুললে ইনবক্সে আসা লিংকে ক্লিক করে ইমেইল নিশ্চিত করুন।
3. প্রথমবার ঢুকলে একটি **Organization** তৈরি করতে বলবে: নাম দিন (যেমন "KMT"), Type: Personal, Plan: **Free** → Create organization।

## ধাপ ২: প্রজেক্ট তৈরি
1. **New project** চাপুন।
2. Name: `kmt-building`
3. **Database Password**: Generate password চাপুন এবং পাসওয়ার্ডটি কোথাও সংরক্ষণ করুন (পাসওয়ার্ড ম্যানেজার বা কাগজে)। পরে ভুলে গেলে Settings → Database থেকে রিসেট করা যায়।
4. Region: **Southeast Asia (Singapore)** (বাংলাদেশ থেকে সবচেয়ে কাছে)।
5. **Create new project** → ১–২ মিনিট অপেক্ষা করুন, যতক্ষণ না ড্যাশবোর্ড খোলে।

## ধাপ ৩: টেবিল বানানো (SQL চালানো)
1. বাঁ পাশের মেনু থেকে **SQL Editor** খুলুন।
2. **New query** (বা "+") চাপুন।
3. আপনার কম্পিউটারে `supabase/schema.sql` ফাইলটি Notepad-এ খুলে `Ctrl+A`, `Ctrl+C` করে পুরোটা কপি করুন এবং SQL Editor-এ পেস্ট করুন।
4. নিচের ডানে **Run** (বা `Ctrl+Enter`) চাপুন। নিচে "**Success. No rows returned**" লেখা এলে সফল।
5. আবার **New query** → `supabase/seed.sql` কপি-পেস্ট → Run। এতে খাত-উপখাত ও ৪০টি ফ্ল্যাট বসবে।
6. যাচাই: **Table Editor**-এ গেলে `accounts` (৩ সারি), `categories` (৪০+ সারি), `flats` (৪০ সারি) দেখা যাবে।

**ভুল হলে:** "already exists" ত্রুটি এলে আগে `supabase/reset.sql` Run করুন (সব মুছে যায়!), তারপর `schema.sql` ও `seed.sql` আবার Run করুন। কোনো লাল ত্রুটি এলে লেখাটি পাঠান, ঠিক করে দেব।

## ধাপ ৪: লগইন-সংক্রান্ত সেটিংস
1. **Authentication** → **Sign In / Providers** → **Email**: চালু (Enabled) থাকবে।
2. একই পেজে **"Allow new users to sign up"** (নতুন ব্যবহারকারীর সাইন আপ) সুইচটি **বন্ধ (OFF)** করুন, যাতে বাইরের কেউ নিজে অ্যাকাউন্ট খুলতে না পারে। (ব্যবহারকারী আপনি ড্যাশবোর্ড থেকে বানাবেন।)
3. **Authentication → URL Configuration → Site URL**: আপনার GitHub Pages লিংক দিন, যেমন `https://ailearningalk-cell.github.io/kmt-building/`।

## ধাপ ৫: ব্যবহারকারী তৈরি
1. **Authentication → Users → Add user → Create new user**।
2. Email ও Password (কমপক্ষে ৬ অক্ষর) দিন এবং **"Auto Confirm User"** টিক দিন → Create user।
3. এভাবে প্রয়োজন অনুযায়ী ব্যবহারকারী বানান: আপনি (অ্যাডমিন), কোষাধ্যক্ষ/হিসাবরক্ষক, সভাপতি/সম্পাদক (দর্শক)।

## ধাপ ৬: প্রতিজনকে ভূমিকা (role) দেওয়া
SQL Editor-এ নতুন query খুলে ইমেইল ও নাম বদলে Run করুন:
```sql
insert into profiles(id, full_name, role)
select id, 'আপনার নাম', 'admin' from auth.users where email = 'you@example.com';
```
অন্যদের জন্য `'admin'`-এর জায়গায় `'accountant'` বা `'viewer'` দিন।

| ভূমিকা | কী পারবে |
|---|---|
| admin (অ্যাডমিন) | সব কিছু: আয়-ব্যয় এন্ট্রি/সংশোধন/মোছা, প্রারম্ভিক জের, ট্রান্সফার, সার্ভিস চার্জ সেটআপ, রিপোর্ট |
| accountant (হিসাবরক্ষক) | আয়-ব্যয় এন্ট্রি, সংশোধন, মোছা, সব রিপোর্ট; জের/ট্রান্সফার/সেটআপ নয় |
| viewer (দর্শক) | শুধু দেখা ও রিপোর্ট; কোনো বদল নয় |

যাচাই: `select * from profiles;` Run করলে সারিগুলো দেখা যাবে।

## ধাপ ৭: অ্যাপে যুক্ত করার তথ্য কপি করা
1. ড্যাশবোর্ডের উপরের **Connect** বোতামে (বা **Project Settings** (গিয়ার আইকন) → **Data API / API Settings**) গিয়ে **Project URL** কপি করুন (দেখতে `https://abcdxyz.supabase.co`)।
2. **Project Settings → API Keys**-এ গিয়ে **Publishable key** (`sb_publishable_...` দিয়ে শুরু) কপি করুন। না থাকলে **Create new API Keys** চাপুন। (পুরনো নামে এটিকে `anon` key বলা হতো; সেটিও চলবে।)
3. ⚠️ **secret key / service_role key কখনও কপি করবেন না, কোথাও দেবেন না।** Publishable key পাবলিক হলেও সমস্যা নেই, কারণ নিরাপত্তা দেয় ডাটাবেজের RLS নিয়ম (লগইন ছাড়া কেউ কিছু দেখতে বা বদলাতে পারে না)।

## ধাপ ৮: অ্যাপে বসানো
`js/supabase-config.js` ফাইলটি খুলে শুধু এই দুই লাইন বদলান:
```js
const SUPABASE_URL = 'https://abcdxyz.supabase.co';
const SUPABASE_KEY = 'sb_publishable_xxxxxxxx';
```
তারপর GitHub-এ সব ফাইল (বদলানো ফাইলসহ) আপলোড/commit করুন। Settings → Pages চালু করা না থাকলে: Branch `main`, Folder `/ (root)` → Save।

## ধাপ ৯: প্রথমবার ব্যবহার
1. আপনার GitHub Pages লিংক খুলুন → লগইন পর্দায় অ্যাডমিন ইমেইল-পাসওয়ার্ড দিন।
2. ড্যাশবোর্ডের নিচে **অ্যাডমিনের জন্য** কার্ড থেকে:
   - **জের সম্পাদনা** → (লগইন-পাসওয়ার্ড দিয়ে নিশ্চিত করুন) → নগদ, ন্যাশনাল ব্যাংক, পূবালী ব্যাংকের প্রারম্ভিক জের বসান।
   - **সার্ভিস চার্জ সেটআপ** → মাসিক অঙ্ক বসান।
3. একটি পরীক্ষামূলক আয় এন্ট্রি দিন। "Supabase-এ সংরক্ষিত হয়েছে ✓" দেখালে Supabase → **Table Editor → transactions**-এ সারিটি দেখতে পাবেন।
4. আগে এই ব্রাউজারে (localStorage) ডাটা রেখে থাকলে, একই ব্রাউজারে অ্যাডমিন হিসেবে ঢুকলে **পুরনো ডাটা আনুন** বাটন দেখাবে; সেটি চেপে সব Supabase-এ আনতে পারবেন (ইনভয়েস নম্বর অক্ষুণ্ণ থাকে)। শুধু একবার চালাবেন।

## ধাপ ১০: পজ ঠেকানো (Keep-alive)
ফ্রি প্রজেক্ট ৭ দিন নিষ্ক্রিয় থাকলে পজ হয়। সমাধান: GitHub Actions সপ্তাহে দুইবার প্রজেক্টকে পিং করবে (ফাইল: `.github/workflows/keepalive.yml`, ইতিমধ্যে প্রজেক্টে আছে)।
1. GitHub repo → **Settings → Secrets and variables → Actions → New repository secret**।
2. দুটি secret বানান: `SUPABASE_URL` (Project URL) ও `SUPABASE_KEY` (Publishable key)।
3. repo-র **Actions** ট্যাবে গিয়ে (প্রয়োজনে "I understand my workflows, go ahead and enable them" চাপুন) → বাঁ পাশে **Supabase keep-alive** → **Run workflow**।
4. সবুজ টিক এলে ঠিক আছে। লাল হলে লগ খুলে দেখুন (সাধারণত secret ভুল বা প্রজেক্ট পজ)।
5. মনে রাখুন: GitHub অনেক দিন (প্রায় ৬০ দিন) repo-তে কোনো কাজ না হলে শিডিউল workflow বন্ধ করে দিতে পারে। তাই মাঝে মাঝে Actions ট্যাব দেখুন, বন্ধ হলে আবার Enable করুন। অ্যাপ নিজে সপ্তাহে ব্যবহার করলেও প্রজেক্ট সচল থাকে।

## পজ হয়ে গেলে কী হবে
- অ্যাপে সংরক্ষণ করতে গেলে লাল বার্তা আসবে: "Supabase-এর সঙ্গে যোগাযোগ করা যায়নি… প্রজেক্ট পজ হতে পারে… Restore project করুন"। ডাটা সংরক্ষিত হয়নি, কিছু হারায়নি।
- supabase.com/dashboard → প্রজেক্টে "Paused" লেখা থাকবে → **Restore project** চাপুন → কয়েক মিনিট পর আবার চেষ্টা করুন। পজের সময় ডাটা মুছে যায় না।

## অতিরিক্ত দরকারি জিনিস
**১) ব্যাকআপ (মাসে একবার):** Table Editor → `transactions`, `transfers`, `accounts`, `service_charge_months` টেবিল খুলে ("…" মেনু) **Export → CSV**। ফাইলগুলো Google Drive বা পেনড্রাইভে রাখুন।

**২) ভুল করে মোছা এন্ট্রি ফিরিয়ে আনা:** মোছা এন্ট্রি আসলে থেকে যায় (সফট ডিলিট)। SQL Editor-এ:
```sql
select doc_no, txn_date, amount, deleted_at from transactions where deleted_at is not null order by deleted_at desc;
update transactions set deleted_at = null, deleted_by = null where doc_no = 'আয়-2026-0005';
```

**৩) কে কখন কী বদলেছে (অডিট):**
```sql
select at, table_name, action, user_id, new_data->>'doc_no' as doc_no from audit_log order by at desc limit 50;
```

**৪) নতুন কর্মী যোগ / কাউকে বাদ দেওয়া:** Authentication → Users → Add user, তারপর ধাপ ৬-এর SQL। বাদ দিতে: `update profiles set is_active = false where id = '...';`

**৫) ফ্ল্যাট মালিক বদল:** `update flats set owner_name = 'নতুন নাম' where flat_no = '৫-বি';` (পুরনো ইনভয়েসে আগের নাম থাকে। অ্যাপের `js/config.js`-এর তালিকাও বদলান, কারণ ফর্ম এখনও ওখান থেকে নাম নেয়।)

## ত্রুটি-বার্তা ও সমাধান
| বার্তা | কারণ ও সমাধান |
|---|---|
| ইমেইল বা পাসওয়ার্ড ভুল। | ইমেইল-পাসওয়ার্ড মেলেনি, বা ব্যবহারকারী Auto Confirm ছাড়া বানানো হয়েছে |
| এই অ্যাকাউন্টে এখনও কোনো ভূমিকা (role) দেওয়া হয়নি | ধাপ ৬-এর `profiles` insert বাকি |
| Supabase এখনও যুক্ত করা হয়নি | `js/supabase-config.js`-এ URL/key বসানো হয়নি |
| Supabase-এর সঙ্গে যোগাযোগ করা যায়নি… | ইন্টারনেট নেই, URL ভুল, বা প্রজেক্ট পজ |
| খাত "…" ডাটাবেজে পাওয়া যায়নি | `seed.sql` চালানো হয়নি বা খাতের নাম বদলানো হয়েছে |
| এই কাজের অনুমতি নেই | আপনার ভূমিকা এই কাজের জন্য যথেষ্ট নয় |
| লগইনের মেয়াদ শেষ… | আবার লগইন করুন |

## নিরাপত্তা-সারকথা
- GitHub-এ শুধু Project URL ও Publishable key থাকে; secret key কখনও নয়।
- ডাটাবেজের RLS নিয়মে লগইন ছাড়া কেউ কিছু দেখতে বা বদলাতে পারে না; ভূমিকা অনুযায়ী অনুমতি আলাদা।
- অ্যাডমিনের কাজের আগে লগইন-পাসওয়ার্ড আবার চাওয়া হয়। পাসওয়ার্ড বদলাতে অ্যাপের "পাসওয়ার্ড পরিবর্তন" ব্যবহার করুন।
- ফ্ল্যাট মালিকদের নাম `js/config.js`-এ থাকায় GitHub Pages পাবলিক হলে সেই ফাইলে নামগুলো কেউ দেখতে পারে। ভবিষ্যতে নামগুলো শুধু ডাটাবেজ থেকে নেওয়ার ব্যবস্থা করা ভালো।
