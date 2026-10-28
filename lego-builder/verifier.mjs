import fs from 'fs';
const html = fs.readFileSync(process.argv[2]||new URL('./index.html', import.meta.url),'utf8');
const a = html.indexOf('const COLORS'), b = html.indexOf('/* =========================================================\n   Géométries');
const code = html.slice(a,b).replace(/^import.*$/mg,'');
const M = new Function(code + '\nreturn {MODELS, partName, topStuds};')();
const verbose = process.argv.includes('-v');
function cells(p){ const s=[]; for(let i=0;i<p.w;i++)for(let j=0;j<p.d;j++) s.push((p.x+i)+','+(p.z+j)); return s; }
function topStuds_(p){
  if(p.t==='tile'||p.t==='cone'||p.t==='wheel') return [];
  if(p.t==='slope'){ // rangée haute = côté opposé à la descente
    const r=[]; for(let i=0;i<p.w;i++)for(let j=0;j<p.d;j++){
      const ok = p.dir==='+x'? i===0 : p.dir==='-x'? i===p.w-1 : p.dir==='+z'? j===0 : j===p.d-1;
      if(ok) r.push((p.x+i)+','+(p.z+j)); } return r; }
  return cells(p);
}
let total=0;
for(const m of M.MODELS){
  const placed=[]; const issues=[];
  m.steps.forEach((st,si)=>{
    st.parts.forEach(p=>placed.push({...p, step:si}));
    const n=placed.length, adj=[...Array(n)].map(()=>[]);
    for(let i=0;i<n;i++)for(let k=0;k<n;k++){ if(i===k) continue;
      const A=placed[i], B=placed[k];
      if(A.t==='wheel'||B.t==='wheel') continue;
      if(A.y+A.h===B.y){ const t=new Set(M.topStuds(A)); if(cells(B).some(c=>t.has(c))){ adj[i].push(k); adj[k].push(i);} }
    }
    // roues : attachées au châssis (pièce 0)
    placed.forEach((p,i)=>{ if(p.t==='wheel'){ adj[i].push(0); adj[0].push(i);} });
    const seen=new Set(), q=[];
    placed.forEach((p,i)=>{ if(i===0 || p.y===0 || p.t==='wheel'){ seen.add(i); q.push(i);} });
    while(q.length){ const i=q.pop(); for(const k of adj[i]) if(!seen.has(k)){seen.add(k);q.push(k);} }
    placed.forEach((p,i)=>{ if(!seen.has(i) && !p.flag){ p.flag=1; issues.push(`étape ${si+1} « ${st.title} » : ${M.partName(p)} ${p.c} (x${p.x},y${p.y},z${p.z}) ne tient à rien`);} });
    // chevauchements des nouvelles pièces
    if(si===m.steps.length-1){
      for(let i=0;i<n;i++)for(let k=i+1;k<n;k++){ const A=placed[i],B=placed[k]; if(A.t==='wheel'||B.t==='wheel') continue;
        if(A.y<B.y+B.h && B.y<A.y+A.h){ const c=new Set(cells(A)); if(cells(B).some(x=>c.has(x))) issues.push(`CHEVAUCHEMENT ${M.partName(A)} ${A.c} et ${M.partName(B)} ${B.c} (x${B.x},y${B.y},z${B.z})`); } }
    }
  });
  // ne garder que la 1re apparition de chaque pièce flottante
  const uniq=[...(m.errors||[]).map(e=>'DÉCOUPE IMPOSSIBLE '+e), ...issues];
  total+=uniq.length;
  console.log(`\n== ${m.name} : ${uniq.length} problème(s)`); (verbose?uniq:uniq.slice(0,40)).forEach(s=>console.log('  '+s));
}
console.log('\nTOTAL', total);
