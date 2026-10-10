-- ⚠️ সতর্কতা: এটি সব টেবিল, ফাংশন ও ডাটা মুছে ফেলে। শুধু প্রথমবারের ভুল শুধরাতে চালান।
drop view if exists v_account_balances;
drop table if exists audit_log, service_charge_months, transfers, transactions, doc_counters,
  service_charge_rates, categories, flats, accounts, settings, profiles cascade;
drop function if exists add_txn(txn_kind,date,integer,integer,smallint,numeric,smallint,text,text,date[],text);
drop function if exists update_txn(uuid,date,integer,integer,smallint,numeric,smallint,text,text,date[]);
drop function if exists delete_txn(uuid), add_transfer(date,smallint,smallint,numeric,text), next_doc_no(txn_kind,date),
  ping(), my_role(), can_write(), log_change() cascade;
drop type if exists user_role, txn_kind, account_kind cascade;
