# ============================================================================
# BSD MACHINE OBSERVER  (ainvs auto-rank edition)
#   "Run the spec-less system, watch where it branches, write the spec (Lean)."
#
#   USAGE on H100 / Colab:
#     1. Go to  https://www.lmfdb.org/EllipticCurve/Q/?rank=2   (change rank=)
#     2. Download -> Pari/GP  (gives a list of ainvs [a1,a2,a3,a4,a6])
#     3. Paste the ainvs vectors into AINVS below. That's it.
#        rank is auto-detected per curve via ellanalyticrank.
#
#   For each curve we probe every stage of the BSD formula and RECORD FAILURES
#   (domain errors) as observations -- a domain error is information.
#
#   BSD leading-coefficient identity:
#       L^(r)(E,1)/r!  =  (Omega * Reg * prod c_p * |Sha|) / |E_tors|^2
#   analytic Sha:
#       |Sha|_an = (L^(r)/r!) * |E_tors|^2 / (Omega * Reg * prod c_p)
#   Sha is a square-order group => |Sha|_an should land near a perfect square.
#   Omega normalization:  Omega_BSD = |w1| * (2 / c_inf),  c_inf = 2 if disc>0 else 1.
# ============================================================================
import cypari2, math, csv, os, re
pari = cypari2.Pari()
pari.default("realprecision", 40)

OUT_DIR = '/content'   # Colab; change locally

# ============================================================================
# INPUT (priority: FILE > RAW > AINVS)
#   FILE_PATH : path to an LMFDB curvedata download (tab-separated). The parser
#               grabs the last 5-integer [a1,a2,a3,a4,a6] bracket on each line.
#   MAX_CURVES: cap how many curves to actually process (lfun is CPU-bound;
#               16e4 curves would take days). Use a sample first.
#   SAMPLE    : 'head' (first MAX_CURVES) or 'random' (uniform sample, seed 42).
#   rank is auto-detected per curve via ellanalyticrank.
# ============================================================================
FILE_PATH  = '/content/lmfdb_ec_curvedata_0604_0756.txt'   # set to '' to disable
MAX_CURVES = 500
SAMPLE     = 'random'      # 'head' or 'random'
PROGRESS_EVERY = 50

RAW = '''
'''

AINVS = [
    [0,-1,1,-10,-20],[1,-1,1,-1,-14],[0,1,1,-9,-15],[0,0,0,-1,0],
    [0,0,1,-1,0],[0,1,1,0,0],[1,-1,1,0,0],[0,1,1,-2,0],[0,0,1,-7,6],
]

def parse_ainvs_text(text):
    out = []
    for line in text.strip().splitlines():
        for b in reversed(re.findall(r'\[[^\]]*\]', line)):
            vals = b.strip('[]').replace(' ', '')
            if vals and len(vals.split(',')) == 5:
                out.append([int(x) for x in vals.split(',')])
                break
    return out

if FILE_PATH and os.path.exists(FILE_PATH):
    with open(FILE_PATH) as f:
        AINVS = parse_ainvs_text(f.read())
    print(f"[loader] {len(AINVS)} curves parsed from {FILE_PATH}")
    if len(AINVS) > MAX_CURVES:
        if SAMPLE == 'random':
            import random; random.seed(42)
            AINVS = random.sample(AINVS, MAX_CURVES)
            print(f"[loader] random sample of {MAX_CURVES} (seed 42)")
        else:
            AINVS = AINVS[:MAX_CURVES]
            print(f"[loader] head {MAX_CURVES}")
elif RAW.strip():
    AINVS = parse_ainvs_text(RAW)
    print(f"[parser] {len(AINVS)} curves from RAW paste")

def safe(fn, *a, **k):
    try:
        return fn(*a, **k), None
    except Exception as e:
        return None, str(e).split('\n')[0][:70]

def observe(idx, coeffs):
    E = pari.ellinit(coeffs)
    cond = int(pari.ellglobalred(E)[0])
    rec = dict(idx=idx, conductor=cond, ainvs=str(coeffs))

    ar, err = safe(pari.ellanalyticrank, E)
    if ar is not None:
        rec['an_rank']   = int(ar[0])
        rec['L_leading'] = float(ar[1])           # L^(r)(1)/r!
    else:
        rec['an_rank'] = None; rec['L_leading'] = None; rec['an_err'] = err

    tors, _ = safe(pari.elltors, E)
    rec['tors'] = int(tors[0]) if tors is not None else None

    tam, _ = safe(pari.elltamagawa, E)
    rec['tamagawa'] = int(tam) if tam is not None else None

    per, _ = safe(pari.ellperiods, E, 1)
    try:
        disc = float(pari(E).disc())
    except Exception:
        disc = None
    rec['c_inf'] = (2 if (disc is not None and disc > 0) else 1)
    if per is not None:
        raw = abs(float(per[0][0].real()))
        rec['omega'] = raw * (2.0 / rec['c_inf'])
    else:
        rec['omega'] = None

    # HEEGNER POINT = the parity / rank bridge.  domain error is the observation.
    hp, hp_err = safe(pari.ellheegner, E)
    if hp is not None:
        rec['heegner'] = 'point'
        h, _ = safe(pari.ellheight, E, hp)
        rec['heegner_height'] = float(h) if h is not None else None
    else:
        rec['heegner'] = 'DOMAIN_ERROR'
        rec['heegner_err'] = hp_err
        rec['heegner_height'] = None

    if rec['an_rank'] == 0:
        rec['reg'] = 1.0
    elif rec['an_rank'] == 1 and rec['heegner_height']:
        rec['reg'] = rec['heegner_height']        # provisional (Heegner index assumed 1)
    else:
        rec['reg'] = None

    if all(rec.get(k) for k in ('L_leading','omega','tamagawa','tors')) and rec.get('reg'):
        sha = rec['L_leading'] * rec['tors']**2 / (rec['omega'] * rec['reg'] * rec['tamagawa'])
        rec['sha_analytic'] = sha
        rec['sha_nearest_sq'] = round(math.sqrt(sha))**2 if sha > 0 else None
    else:
        rec['sha_analytic'] = None; rec['sha_nearest_sq'] = None
    return rec

rows = []
for i, c in enumerate(AINVS):
    rows.append(observe(i, c))
    if PROGRESS_EVERY and (i+1) % PROGRESS_EVERY == 0:
        print(f"  ...processed {i+1}/{len(AINVS)}")

def fmt(v, p=5):
    return f"{v:.{p}f}" if isinstance(v, float) else ('-' if v is None else str(v))

print("="*108)
print("BSD MACHINE OBSERVER  --  system behaviour map   (auto-rank)")
print("="*108)
hdr = (f"{'cond':>7} {'an_r':>4} {'L^(r)/r!':>11} {'tors':>4} {'c_p':>4} {'c_inf':>5} "
       f"{'Omega':>9} {'Heegner':>13} {'h(Heeg)':>9} {'Sha_an':>8}")
print(hdr); print("-"*108)
for r in sorted(rows, key=lambda r: (r['an_rank'] if r['an_rank'] is not None else 99, r['conductor'])):
    print(f"{r['conductor']:>7} {fmt(r['an_rank']):>4} {fmt(r['L_leading']):>11} "
          f"{fmt(r['tors']):>4} {fmt(r['tamagawa']):>4} {fmt(r['c_inf']):>5} "
          f"{fmt(r['omega'],4):>9} {r['heegner']:>13} "
          f"{fmt(r['heegner_height']):>9} {fmt(r['sha_analytic'],4):>8}")

# ---- DETERMINISM: do all curves of the SAME rank share the branch pattern? ----
print("\n--- DETERMINISM CHECK (per rank) ---")
from collections import defaultdict
by_rank = defaultdict(list)
for r in rows:
    if r['an_rank'] is not None:
        by_rank[r['an_rank']].append(r)
for rk in sorted(by_rank):
    grp = by_rank[rk]
    heeg = set(r['heegner'] for r in grp)
    heeg_errs = set(r.get('heegner_err','') for r in grp if r['heegner']=='DOMAIN_ERROR')
    shas = [r['sha_analytic'] for r in grp if r['sha_analytic'] is not None]
    sha_ok = all(abs(s-round(s))<1e-3 for s in shas) if shas else None
    print(f"  rank {rk}: n={len(grp)}  heegner={heeg}  "
          + (f"err={heeg_errs}  " if heeg_errs else "")
          + (f"Sha all~int: {sha_ok}" if shas else "Sha: n/a"))

print("\n--- BRANCH CONDITIONS (ellheegner domain errors) ---")
seen = set()
for r in rows:
    if r['heegner']=='DOMAIN_ERROR':
        key = (r['an_rank'], r.get('heegner_err'))
        if key not in seen:
            seen.add(key)
            print(f"  rank {r['an_rank']}: {r.get('heegner_err')}")

os.makedirs(OUT_DIR, exist_ok=True)
keys = sorted({k for r in rows for k in r.keys()})
with open(os.path.join(OUT_DIR,'bsd_observer.csv'),'w',newline='') as f:
    w = csv.DictWriter(f, fieldnames=keys); w.writeheader()
    for r in rows: w.writerow(r)
print(f"\nsaved -> {os.path.join(OUT_DIR,'bsd_observer.csv')}  ({len(rows)} curves)")
