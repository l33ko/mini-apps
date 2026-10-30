// @ts-nocheck
// =============================================================
//  SynApps · Recettes — Edge Function « import-recette »
//  Supabase > Edge Functions > Deploy a new function > Via Editor
//  Nom : import-recette · coller tout ce fichier · Deploy.
//  (Laisser « Verify JWT » activé : seules les personnes connectées peuvent l'utiliser.)
//
//  Reçoit { url }, lit la page et renvoie la recette trouvée (format schema.org),
//  sans rien enregistrer : c'est l'app qui ajoute la fiche dans la famille.
// =============================================================

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};
const reply = (data: unknown) =>
  new Response(JSON.stringify(data), { headers: { ...CORS, 'Content-Type': 'application/json; charset=utf-8' } });

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });
  if (req.method !== 'POST') return reply({ error: 'Méthode non permise' });

  let url: URL;
  try {
    const raw = String((await req.json()).url || '').trim();
    url = new URL(raw.match(/https?:\/\/\S+/)?.[0] || raw);
    if (!/^https?:$/.test(url.protocol)) throw 0;
  } catch { return reply({ error: 'Ce n’est pas un lien valide.' }); }

  let html = '';
  try {
    const r = await fetch(url.href, {
      redirect: 'follow',
      signal: AbortSignal.timeout(12000),
      headers: {
        'user-agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1',
        'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'accept-language': 'fr-FR,fr;q=0.9,en;q=0.7',
      },
    });
    if (!r.ok) return reply({ error: `Le site a refusé la lecture de la page (erreur ${r.status}).`, partiel: { titre: '', source: url.href } });
    html = (await r.text()).slice(0, 4_000_000);
  } catch {
    return reply({ error: 'Impossible de lire cette page (site trop lent ou injoignable).', partiel: { titre: '', source: url.href } });
  }

  const { recette, partiel } = extractRecipe(html, url.href) as any;
  if (!recette || (!recette.ingredients && !recette.etapes))
    return reply({ error: 'Je n’ai pas trouvé de recette structurée sur cette page.',
      partiel: partiel || { titre: recette?.titre || '', source: url.href, photo: recette?.photo || null } });
  return reply({ recette });
});

// ---------- Extraction (identique à la version perso) ----------
// Extraction d'une recette depuis le HTML d'une page.
// La plupart des sites de cuisine publient la recette au format schema.org « Recipe »
// dans une balise <script type="application/ld+json"> (c'est ce que lit Google).

const CATS = [
  ['Dessert', ['dessert', 'gateau', 'patisserie', 'cake', 'biscuit', 'cookie', 'confiserie', 'entremets']],
  ['Apéro', ['apero', 'aperitif', 'amuse', 'tapas', 'cocktail dinatoire']],
  ['Petit-déj', ['petit-dej', 'petit dej', 'petit-dejeuner', 'petit dejeuner', 'breakfast', 'brunch', 'gouter']],
  ['Boisson', ['boisson', 'drink', 'smoothie', 'jus ', 'cocktail']],
  ['Sauce', ['sauce', 'condiment', 'vinaigrette', 'marinade']],
  ['Pain & pâte', ['pain', 'brioche', 'pate a', 'bread', 'viennoiserie']],
  ['Entrée', ['entree', 'starter', 'appetizer', 'salade']],
  ['Accompagnement', ['accompagnement', 'side dish', 'garniture']],
  ['Plat', ['plat', 'main', 'dinner', 'lunch', 'diner', 'dejeuner']],
];

const norm = s => String(s || '').toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '');

const NAMED = { nbsp: ' ', amp: '&', lt: '<', gt: '>', quot: '"', apos: "'", rsquo: '’', lsquo: '‘', ldquo: '“',
  rdquo: '”', laquo: '«', raquo: '»', hellip: '…', ndash: '–', mdash: '—', deg: '°', times: '×', middot: '·',
  euro: '€', frac12: '½', frac14: '¼', frac34: '¾', oelig: 'œ', OElig: 'Œ', aelig: 'æ', AElig: 'Æ', szlig: 'ß' };
const MARKS = { grave: '̀', acute: '́', circ: '̂', tilde: '̃', uml: '̈', cedil: '̧', ring: '̊' };

function decodeEntities(s) {
  return String(s ?? '')
    .replace(/&#(\d+);/g, (_, n) => String.fromCodePoint(+n))
    .replace(/&#x([0-9a-f]+);/gi, (_, n) => String.fromCodePoint(parseInt(n, 16)))
    .replace(/&([a-zA-Z])(grave|acute|circ|tilde|uml|cedil|ring);/g, (_, l, m) => (l + MARKS[m]).normalize('NFC'))
    .replace(/&([a-zA-Z]+[0-9]*);/g, (m, e) => NAMED[e] ?? m);
}
const clean = s => decodeEntities(String(s ?? '').replace(/<[^>]*>/g, ' ')).replace(/\s+/g, ' ').trim();

// "PT1H30M" → 90 ; "P0DT0H20M" → 20
function isoMinutes(d) {
  if (!d) return null;
  if (typeof d === 'number') return Math.round(d);
  const m = String(d).match(/P(?:(\d+)D)?(?:T(?:(\d+(?:\.\d+)?)H)?(?:(\d+(?:\.\d+)?)M)?(?:\d+(?:\.\d+)?S)?)?/i);
  if (!m || !m[0] || m[0] === 'P') return /^\d+$/.test(d) ? +d : null;
  const t = (+(m[1] || 0)) * 1440 + (+(m[2] || 0)) * 60 + (+(m[3] || 0));
  return t > 0 ? Math.round(t) : null;
}

const arr = v => v == null ? [] : Array.isArray(v) ? v : [v];
const isRecipe = o => o && typeof o === 'object' && arr(o['@type']).some(t => /recipe$/i.test(String(t)));

function findRecipe(node, depth = 0) {
  if (!node || typeof node !== 'object' || depth > 8) return null;
  if (isRecipe(node)) return node;
  for (const v of Array.isArray(node) ? node : [node['@graph'], node.mainEntity, node.mainEntityOfPage, node.itemListElement]) {
    for (const x of arr(v)) { const r = findRecipe(x, depth + 1); if (r) return r; }
  }
  return null;
}

function steps(ins) {
  const out = [];
  const walk = x => {
    if (!x) return;
    if (typeof x === 'string') {
      // Certains sites mettent toutes les étapes dans un seul texte
      x.split(/\n+|<br\s*\/?>|<\/p>|<\/li>/i).map(clean).filter(Boolean).forEach(s => out.push(s));
    } else if (Array.isArray(x)) x.forEach(walk);
    else if (x.itemListElement) {
      if (x.name && arr(x.itemListElement).length) out.push(`— ${clean(x.name)} —`);
      walk(x.itemListElement);
    } else walk(x.text || x.name || x.description);
  };
  walk(ins);
  return out.map(s => s.replace(/^(étape|etape|step)\s*\d+\s*[:.)-]?\s*/i, '').replace(/^\d+[.)]\s+/, '')).filter(Boolean);
}

function image(img) {
  for (const x of arr(img)) {
    const u = typeof x === 'string' ? x : x?.url || x?.contentUrl || x?.['@id'];
    if (u && /^https?:\/\//.test(u)) return u;
  }
  return null;
}

function portions(y) {
  for (const x of arr(y)) { const m = String(x).match(/\d+/); if (m && +m[0] > 0 && +m[0] < 100) return +m[0]; }
  return null;
}

// On regarde d'abord la catégorie donnée par le site, puis le nom de la recette.
function guessCategory(...hints) {
  for (const hint of hints) {
    const h = norm(arr(hint).filter(Boolean).join(' | '));
    if (!h) continue;
    for (const [cat, words] of CATS) if (words.some(w => h.includes(norm(w)))) return cat;
  }
  return 'Autre';
}

function meta(html, prop) {
  const re = new RegExp(`<meta[^>]+(?:property|name)=["']${prop}["'][^>]*>`, 'i');
  const tag = html.match(re)?.[0];
  return tag ? decodeEntities(tag.match(/content=["']([^"']*)["']/i)?.[1] || '') : '';
}

// Renvoie { recette } ou { partiel } si aucune recette structurée n'est trouvée.
function extractRecipe(html, url) {
  let r = null;
  for (const m of html.matchAll(/<script[^>]*type=["']application\/ld\+json["'][^>]*>([\s\S]*?)<\/script>/gi)) {
    let txt = m[1].trim().replace(/^<!\[CDATA\[|\]\]>$/g, '');
    let data;
    try { data = JSON.parse(txt); }
    catch { try { data = JSON.parse(txt.replace(/[\u0000-\u001f]+/g, ' ')); } catch { continue; } }
    r = findRecipe(data);
    if (r) break;
  }

  const ogTitle = meta(html, 'og:title') || clean(html.match(/<title[^>]*>([\s\S]*?)<\/title>/i)?.[1]);
  const ogImage = meta(html, 'og:image');
  if (!r) return { partiel: { titre: ogTitle || '', source: url, photo: /^https?:/.test(ogImage) ? ogImage : null } };

  const prep = isoMinutes(r.prepTime);
  let cook = isoMinutes(r.cookTime);
  const total = isoMinutes(r.totalTime);
  if (!prep && !cook && total) cook = total;

  const keywords = arr(r.keywords).flatMap(k => String(k).split(','))
    .map(clean).filter(k => k && k.length <= 25).slice(0, 6);

  return {
    recette: {
      titre: clean(r.name) || ogTitle || 'Recette sans nom',
      categorie: guessCategory(arr(r.recipeCategory).map(String), r.name),
      portions: portions(r.recipeYield) || 4,
      temps_prep: prep,
      temps_cuisson: cook,
      ingredients: arr(r.recipeIngredient || r.ingredients).map(clean).filter(Boolean).join('\n'),
      etapes: steps(r.recipeInstructions).join('\n'),
      notes: '',
      tags: keywords,
      source: url,
      photo: image(r.image) || (/^https?:/.test(ogImage) ? ogImage : null),
      favori: false,
    },
  };
}
