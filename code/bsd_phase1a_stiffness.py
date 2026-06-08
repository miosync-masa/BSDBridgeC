# ============================================================================
# BridgeC x BSD : Elliptic-Curve L-function  Phase 1a' + Stiffness-Source
# ----------------------------------------------------------------------------
#   - freezing lemma check  (Where-preserving perturbation, predicted vs measured)
#   - local stiffness  |Z_E'(gamma_k)|  distribution
#   - spacing-ratio <r>  (Poisson / GOE / GUE / USp discriminator)
#   - rank-dependence sweep  (rank 0,1,2,3 minimal-conductor curves)
#   - central-zero (t=0) analysis  <-- this is where BSD rank lives
#
#   Note: PARI lfun* is CPU-bound (no GPU kernel). H100 gives no speedup here.
#         Parallelism is over curves / zero-batches via multiprocessing.
#         What H100 *does* let you do comfortably: push HEIGHT very high.
# ============================================================================

import cypari2
import numpy as np
from scipy import stats
import csv, os, time

# ----------------------------------------------------------------------------
# CONFIG
# ----------------------------------------------------------------------------
PREC          = 38          # PARI realprecision (decimal digits)
HEIGHT        = 1000        # collect zeros with 0 < Im(rho) < HEIGHT  (raise on H100)
EPS           = 1e-6        # perturbation amplitude
DERIV_H       = 1e-7        # finite-difference step for Z_E'
ZEROS_DIR     = '/content' # where to save/load zero files  (Colab default)
MAX_LOCAL     = 1e-3        # reject |dt_pred| above this (nonlocal class)

# Minimal-conductor representative curve for each algebraic rank
#   (a1,a2,a3,a4,a6) Weierstrass coeffs ; rank = analytic rank (= ord_{s=1} L)
CURVES = {
    'rank0_N32'   : dict(coeffs=[0, 0, 0, -1, 0], rank=0),   # y^2 = x^3 - x
    'rank1_N37'   : dict(coeffs=[0, 0, 1, -1, 0], rank=1),   # 37.a1
    'rank2_N389'  : dict(coeffs=[0, 1, 1, -2, 0], rank=2),   # 389.a1
    'rank3_N5077' : dict(coeffs=[0, 0, 1, -7, 6], rank=3),   # 5077.a1
}

# ----------------------------------------------------------------------------
pari = cypari2.Pari()
pari.default("realprecision", PREC)

def make_curve(coeffs):
    E = pari.ellinit(coeffs)
    N = int(pari.ellglobalred(E)[0])
    return E, N

def Z_E(E, t):
    """Hardy Z-function for L(E, .) : real-valued on the critical line Re(s)=1."""
    return float(pari.lfunhardy(E, pari(t)))

def Z_E_deriv(E, t, h=DERIV_H):
    return (Z_E(E, t + h) - Z_E(E, t - h)) / (2.0 * h)

def Z_E_deriv2(E, t, h=DERIV_H):
    return (Z_E(E, t + h) - 2.0 * Z_E(E, t) + Z_E(E, t - h)) / (h * h)

# ----------------------------------------------------------------------------
# 1. ZERO GENERATION  (replaces zeros6.txt, which is the Riemann-zeta table)
# ----------------------------------------------------------------------------
def get_zeros(name, E, height, save=True):
    """
    Generate (or load) the positive-height zeros of L(E,s) on Re(s)=1.
    Saves one imaginary part per line, mirroring the zeros6.txt format.
    """
    path = os.path.join(ZEROS_DIR, f"ec_zeros_{name}_H{height}.txt")
    if os.path.exists(path):
        with open(path) as f:
            zeros = sorted(float(line) for line in f if line.strip())
        print(f"[{name}] loaded {len(zeros)} zeros from {path}")
        return zeros, path

    t0 = time.time()
    zeros = sorted(float(z) for z in pari.lfunzeros(E, height))
    dt = time.time() - t0
    if save:
        with open(path, 'w') as f:
            for z in zeros:
                f.write(f"{z:.{PREC}f}\n")
    print(f"[{name}] generated {len(zeros)} zeros up to H={height} in {dt:.1f}s -> {path}")
    return zeros, path

# ----------------------------------------------------------------------------
# 2. PHASE 1a' : Where-preserving freezing check
# ----------------------------------------------------------------------------
def phase1a(name, E, zeros, eps=EPS, h_func=lambda t: 1.0):
    pred, meas, stiff = [], [], []
    nonlocal_count = 0
    for gamma in zeros:
        Zp = Z_E_deriv(E, gamma)
        if abs(Zp) < 1e-20:
            continue
        dt_pred = -eps * h_func(gamma) / Zp
        if abs(dt_pred) > MAX_LOCAL:
            nonlocal_count += 1
            continue
        # Newton root-track of  f(t) = Z_E(t) + eps*h(t)
        t = gamma + dt_pred
        for _ in range(50):
            f  = Z_E(E, t) + eps * h_func(t)
            fp = Z_E_deriv(E, t)
            if abs(fp) < 1e-30:
                break
            step = f / fp
            t -= step
            if abs(step) < 1e-22:
                break
        dt_meas = t - gamma
        pred.append(dt_pred); meas.append(dt_meas); stiff.append(abs(Zp))

    pred = np.array(pred); meas = np.array(meas); stiff = np.array(stiff)
    r, _ = stats.pearsonr(pred, meas) if len(pred) > 2 else (float('nan'), 1.0)
    rel = np.median(np.abs((meas - pred) / np.where(np.abs(pred) > 1e-30, pred, 1)))
    return dict(name=name, n=len(pred), nonloc=nonlocal_count,
                pearson_r=r, median_rel_err=rel,
                stiff_mean=float(np.mean(stiff)), stiff_med=float(np.median(stiff)),
                stiff_min=float(np.min(stiff)), stiff_max=float(np.max(stiff)),
                inv_stiff_skew=float(stats.skew(1.0/stiff)),
                inv_stiff_kurt=float(stats.kurtosis(1.0/stiff, fisher=True)),
                pred=pred, meas=meas, stiff=stiff)

# ----------------------------------------------------------------------------
# 3. SPACING / RMT discriminator
# ----------------------------------------------------------------------------
def spacing_stats(zeros, window=50):
    z = np.array(sorted(set(zeros)))          # dedup + sort (kills 0-spacings)
    sp = np.diff(z)
    sp = sp[sp > 1e-12]                        # drop degenerate spacings
    if len(sp) < 3:
        return dict(mean_spacing=float('nan'), mean_r=float('nan'), n_spacings=len(sp))
    w = min(window, len(sp))
    s = np.empty_like(sp)
    for i in range(len(sp)):
        lo = max(0, i - w // 2); hi = max(lo + 1, min(len(sp), i + w // 2))
        loc = np.mean(sp[lo:hi])
        s[i] = sp[i] / loc if loc > 0 else 1.0
    denom = np.maximum(s[:-1], s[1:])
    good = denom > 0
    r = np.minimum(s[:-1], s[1:])[good] / denom[good]
    return dict(mean_spacing=float(np.mean(sp)),
                mean_r=float(np.mean(r)) if len(r) else float('nan'),
                n_spacings=len(sp))

# Reference <r> values
RMT_REF = dict(Poisson=0.38629, GOE=0.53590, GUE=0.60266, USp_GSE=0.67617)

# ----------------------------------------------------------------------------
# 4. CENTRAL-ZERO ANALYSIS  (t=0, where ord_{s=1} L = rank lives -- BSD socket)
# ----------------------------------------------------------------------------
def central_analysis(name, E, rank):
    """
    Look at Z_E and its derivatives at the center t=0.
    rank r  =>  Z_E(0)=Z_E'(0)=...=Z_E^{(r-1)}(0)=0,  Z_E^{(r)}(0)!=0.
    This is the numerical fingerprint of the BSD order-of-vanishing.
    """
    derivs = []
    # crude high-order finite differences at 0
    h = 1e-3
    pts = {k: Z_E(E, k * h) for k in range(-6, 7)}
    # central finite-difference stencils (order up to 4)
    d0 = pts[0]
    d1 = (pts[1] - pts[-1]) / (2*h)
    d2 = (pts[1] - 2*pts[0] + pts[-1]) / h**2
    d3 = (pts[2] - 2*pts[1] + 2*pts[-1] - pts[-2]) / (2*h**3)
    d4 = (pts[2] - 4*pts[1] + 6*pts[0] - 4*pts[-1] + pts[-2]) / h**4
    derivs = [d0, d1, d2, d3, d4]
    # detect order of vanishing numerically
    tol = 1e-4
    order = 0
    for d in derivs:
        if abs(d) < tol:
            order += 1
        else:
            break
    return dict(name=name, declared_rank=rank, numeric_order=order,
                Z0=d0, Z1=d1, Z2=d2, Z3=d3, Z4=d4)

# ----------------------------------------------------------------------------
# MAIN
# ----------------------------------------------------------------------------
def main():
    summary_rows = []
    central_rows = []
    for name, info in CURVES.items():
        print("="*70)
        E, N = make_curve(info['coeffs'])
        print(f"{name}: conductor={N}, declared rank={info['rank']}")

        # central zero first (cheap, and the BSD-relevant part)
        cen = central_analysis(name, E, info['rank'])
        central_rows.append(cen)
        print(f"  central: numeric order-of-vanishing = {cen['numeric_order']} "
              f"(declared rank {info['rank']});  "
              f"Z0={cen['Z0']:.3e} Z1={cen['Z1']:.3e} Z2={cen['Z2']:.3e} "
              f"Z3={cen['Z3']:.3e} Z4={cen['Z4']:.3e}")

        # positive-height zeros
        zeros, _ = get_zeros(name, E, HEIGHT)
        if len(zeros) < 5:
            print(f"  (too few zeros at H={HEIGHT}, skipping Phase 1a')")
            continue

        # Phase 1a'
        res = phase1a(name, E, zeros)
        sp  = spacing_stats(zeros)
        print(f"  Phase 1a': n={res['n']}, Pearson r={res['pearson_r']:.10f}, "
              f"median rel err={res['median_rel_err']:.3e}")
        print(f"  stiffness |Z'|: mean={res['stiff_mean']:.3f}, "
              f"inv-stiff kurtosis={res['inv_stiff_kurt']:.2f}")
        print(f"  spacing <r>={sp['mean_r']:.5f}  "
              f"[Poisson {RMT_REF['Poisson']}, GUE {RMT_REF['GUE']}, "
              f"USp/GSE~{RMT_REF['USp_GSE']}]")

        summary_rows.append(dict(
            name=name, conductor=N, rank=info['rank'],
            n_zeros=len(zeros), n_used=res['n'],
            pearson_r=res['pearson_r'], median_rel_err=res['median_rel_err'],
            stiff_mean=res['stiff_mean'], stiff_med=res['stiff_med'],
            stiff_min=res['stiff_min'], stiff_max=res['stiff_max'],
            inv_stiff_kurt=res['inv_stiff_kurt'],
            mean_spacing=sp['mean_spacing'], mean_r=sp['mean_r'],
        ))

    # write summary CSV
    out = os.path.join(ZEROS_DIR, 'bsd_phase1a_summary.csv')
    if summary_rows:
        with open(out, 'w', newline='') as f:
            w = csv.DictWriter(f, fieldnames=list(summary_rows[0].keys()))
            w.writeheader(); w.writerows(summary_rows)
        print("="*70)
        print(f"summary written -> {out}")
    cout = os.path.join(ZEROS_DIR, 'bsd_central_zero.csv')
    with open(cout, 'w', newline='') as f:
        w = csv.DictWriter(f, fieldnames=list(central_rows[0].keys()))
        w.writeheader(); w.writerows(central_rows)
    print(f"central-zero analysis -> {cout}")

if __name__ == '__main__':
    main()
