# কাজী মোশাররফ টাওয়ার ভবন মালিক সমিতি — অ্যাকাউন্টিং ম্যানেজমেন্ট সিস্টেম

আয়-ব্যয়ের হিসাব, তিন হিসাব (নগদ / ন্যাশনাল ব্যাংক / পূবালী ব্যাংক), ইনভয়েস-ভাউচার, মাসিক রিপোর্ট ও সামারি শীট।
ডাটা থাকে Supabase (PostgreSQL)-এ; লগইন ও ভূমিকা (admin/accountant/viewer) অনুযায়ী অনুমতি।

## ফোল্ডার কাঠামো (GitHub: kmt-building)

```
kmt-building/
├── index.html            ← একমাত্র HTML পেজ (ড্যাশবোর্ড / আয়-ব্যয় এন্ট্রি / লেনদেন — তিনটি স্ক্রিন)
├── css/
│   └── style.css         ← সব ডিজাইন
├── js/
│   ├── config.js         ← সমিতির তথ্য, হিসাব, খাত-উপখাত, ফ্ল্যাট ও মালিকের নাম
│   ├── supabase-config.js ← আপনার Supabase URL ও Publishable key (শুধু এই ফাইলে বসান)
│   ├── db.js             ← Supabase ডাটা লেয়ার (লগইন, লেনদেন, জের, সেটআপ)
│   ├── documents.js      ← A4 ইনভয়েস/ভাউচার, সামারি শীট, PDF ডাউনলোড
│   ├── reports.js        ← রিপোর্ট বাছাই ও ৭টি রিপোর্ট, সার্ভিস চার্জ সেটআপ
│   └── app.js            ← স্ক্রিন, ফর্ম, ড্যাশবোর্ড, লেনদেন, অ্যাডমিন পাসওয়ার্ড
├── assets/
│   └── img/
│       ├── paid.png      ← PAID সিল (আপনার ছবি)
│       └── received.png  ← RECEIVED সিল (এখন অস্থায়ী; নিজের ছবি দিয়ে একই নামে বদলান)
├── supabase/
│   ├── schema.sql        ← টেবিল, নিরাপত্তা (RLS), ফাংশন, ট্রিগার
│   ├── seed.sql          ← খাত, উপ খাত ও ৪০টি ফ্ল্যাট
│   └── reset.sql         ← (শুধু প্রথমবারের ভুল শুধরাতে) সব মুছে নতুন করে শুরু
├── .github/workflows/
│   └── keepalive.yml     ← Supabase পজ ঠেকাতে সাপ্তাহিক পিং
├── docs/
│   ├── SUPABASE_SETUP.md ← সাইন আপ থেকে চালু পর্যন্ত ধাপে ধাপে টিউটোরিয়াল
│   └── DATABASE.md       ← টেবিল ও অ্যাট্রিবিউটের বিবরণ
└── README.md
```

ভবিষ্যতে PWA করতে root-এ যোগ হবে: `manifest.json`, `sw.js` (service worker) এবং `assets/icons/` (১৯২ ও ৫১২ পিক্সেলের আইকন)।

## GitHub-এ আপলোড
1. এই ফোল্ডারের ভিতরের সব ফাইল ও ফোল্ডার repo-র root-এ আপলোড করুন (ফোল্ডার-সহ drag & drop করা যায়)।
2. Settings → Pages → Branch: `main`, Folder: `/ (root)` → Save।
3. কয়েক মিনিট পরে `https://<username>.github.io/kmt-building/` লিংকে অ্যাপ চলবে (PDF ডাউনলোড ও সিলের ছবি এই https লিংকে ঠিকভাবে কাজ করে)।

## নিজের কম্পিউটারে চালানো
`index.html` সরাসরি খুললে বেশিরভাগ কাজ করে, কিন্তু সিলের ছবিসহ PDF ডাউনলোডের জন্য একটি লোকাল সার্ভার ভালো:
`python3 -m http.server 8000` চালিয়ে `http://localhost:8000` খুলুন।

## শুরু করার ক্রম
`docs/SUPABASE_SETUP.md` অনুসরণ করুন: Supabase প্রজেক্ট → `schema.sql`, `seed.sql` → ব্যবহারকারী ও ভূমিকা → `js/supabase-config.js` → GitHub Pages → keep-alive।

## সতর্কতা
- ফ্ল্যাট মালিকদের নাম `js/config.js`-এ আছে; repo/Pages পাবলিক হলে নামগুলো সবাই দেখতে পারবে। ডাটাবেজে নেওয়ার পর config থেকে সরিয়ে দিন।
