/* db.js — ডাটা লেয়ার। এখন localStorage; পরে Supabase-এর কলে বদলাতে হবে শুধু এই ফাইলে */
/* ===== ডাটা লেয়ার: পরে এই অবজেক্টটি API/ডাটাবেজ কলে বদলালেই হবে ===== */
const DB={
 _g(k,d){try{return JSON.parse(localStorage.getItem(k))??d}catch{return d}},
 async list(){return this._g('kmt_tx',[])},
 async add(t){const l=await this.list();t.id=Date.now()+''+Math.random().toString(36).slice(2,6);t.no=nextNo(l,t);l.push(t);localStorage.setItem('kmt_tx',JSON.stringify(l))},
 async remove(id){const l=await this.list(),n=l.filter(x=>String(x.id)!==String(id));localStorage.setItem('kmt_tx',JSON.stringify(n));return l.length-n.length},
 async update(t){const l=await this.list(),i=l.findIndex(x=>String(x.id)===String(t.id));if(i<0)return false;const o=l[i];
  t.no=(o.type===t.type&&o.date.slice(0,4)===t.date.slice(0,4)&&o.no)?o.no:nextNo(l.filter((_,j)=>j!==i),t);l[i]=t;localStorage.setItem('kmt_tx',JSON.stringify(l));return true},
 async saveAll(l){localStorage.setItem('kmt_tx',JSON.stringify(l))},
 async opening(){let o=this._g('kmt_open3',null);if(!o)o={cash:+this._g('kmt_open',0)||0,nbl:0,pbl:0};return o},
 async sc(){return this._g('kmt_sc',{def:0,per:{}})},
 async setSc(o){localStorage.setItem('kmt_sc',JSON.stringify(o))},
 async adminHash(){return this._g('kmt_adm','')},
 async setAdminHash(h){localStorage.setItem('kmt_adm',JSON.stringify(h))},
 async setOpening(o){localStorage.setItem('kmt_open3',JSON.stringify({cash:+o.cash||0,nbl:+o.nbl||0,pbl:+o.pbl||0}))}
};
