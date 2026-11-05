"""Évolution 2023-2025 : tendances nationales et variations au sein de chaque département.

Les corrélations sur les variations (2025 moins 2023) comparent chaque département à lui-même :
les caractéristiques stables d'un territoire (géographie, profil social, organisation historique)
ne peuvent pas expliquer le lien, contrairement à une comparaison entre départements.
"""
from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd
from scipy.stats import spearmanr

from data import load_mart, metropole, parser

ROOT = Path(__file__).resolve().parent
INK, MUTED, BG, BLUE, RED, GRID = "#1f1e1b", "#6b6a65", "#fbfaf7", "#2a78d6", "#e34948", "#e8e6e1"

SERIES = [
    ("Patients suivis", "file_active_totale"),
    ("Actes à domicile", "actes_domicile"),
    ("Consultations (CMP et unités)", "actes_consultation"),
    ("Psychiatres (ETP)", "etp_psychiatres"),
    ("Infirmiers (ETP)", "etp_infirmiers"),
    ("Lits à temps plein", "lits_temps_plein"),
    ("Places en lieux de vie intermédiaires", "places_lieux_de_vie"),
]
VARIATIONS = [
    ("actes_domicile_pour_1000", "taux_occupation"),
    ("actes_domicile_pour_1000", "duree_moyenne_sejour"),
    ("actes_consultation_pour_1000", "taux_occupation"),
    ("lits_pour_100k", "taux_occupation"),
    ("lits_pour_100k", "journees_soins_libres_pour_1000"),
]


def tendances(df):
    df = df.assign(
        actes_consultation=df.actes_cmp.fillna(0) + df.actes_unites_consultation.fillna(0),
        places_lieux_de_vie=df.places_placement_familial.fillna(0) + df.places_appartement_therapeutique.fillna(0),
    )
    nat = df.groupby("annee")[[c for _, c in SERIES]].sum()
    evol = (100 * (nat.loc[2025] / nat.loc[2023] - 1)).round(1)
    return nat, evol


def variations(df):
    rows = []
    for x, y in VARIATIONS:
        w = df.pivot_table(index="code_insee", columns="annee", values=[x, y])
        d = pd.DataFrame({"dx": w[x][2025] - w[x][2023], "dy": w[y][2025] - w[y][2023]}).dropna()
        rho, p = spearmanr(d.dx, d.dy)
        rows.append({"variation_x": x, "variation_y": y, "n": len(d), "rho": round(rho, 2),
                     "p_value": round(p, 4), "fiable_5pct": p < 0.05})
    return pd.DataFrame(rows)


def graphique(evol, sortie):
    labels = [l for l, _ in SERIES][::-1]
    vals = [evol[c] for _, c in SERIES][::-1]
    fig = plt.figure(figsize=(8, 10), dpi=150, facecolor=BG)
    ax = fig.add_axes([0.40, 0.17, 0.48, 0.58]); ax.set_facecolor(BG)
    ax.barh(labels, vals, color=[BLUE if v >= 0 else RED for v in vals], height=0.55)
    ax.axvline(0, color=INK, lw=0.8)
    for k, v in enumerate(vals):
        ax.text(v + (0.4 if v >= 0 else -0.4), k, f"{v:+.1f} %".replace(".", ","), va="center",
                ha="left" if v >= 0 else "right", fontsize=11, weight="bold", color=INK)
    ax.set_xlim(min(vals) - 4, max(vals) + 4)
    ax.tick_params(axis="y", length=0, labelsize=11, colors=INK); ax.tick_params(axis="x", colors=MUTED, labelsize=9)
    ax.xaxis.grid(True, color=GRID); ax.set_axisbelow(True)
    ax.set_xlabel("Évolution entre 2023 et 2025, en %", fontsize=9.5, color=MUTED)
    for sp in ax.spines.values(): sp.set_visible(False)
    fig.text(0.06, 0.94, "Plus de patients,", fontsize=24, weight="bold", color=INK)
    fig.text(0.06, 0.895, "moins de lits et de lieux de vie", fontsize=24, weight="bold", color=RED)
    fig.text(0.06, 0.855, "Évolution 2023-2025 de la psychiatrie de l'adulte, France métropolitaine", fontsize=11.5, color=MUTED)
    fig.text(0.06, 0.81, "Le suivi hors hospitalisation progresse, un peu moins vite que le nombre de patients.",
             fontsize=11, color=INK)
    fig.text(0.06, 0.788, "Les lits, les infirmiers et surtout les lieux de vie intermédiaires reculent.", fontsize=11, color=INK)
    fig.text(0.06, 0.09, "Lieux de vie intermédiaires : placement familial thérapeutique et appartements thérapeutiques.",
             fontsize=9, color=MUTED)
    fig.text(0.06, 0.07, "Consultations : actes en CMP et en unités de consultation de psychiatrie.", fontsize=9, color=MUTED)
    fig.text(0.06, 0.02, "Sources : DREES, SAE 2023 à 2025. Analyse : Alexandra Delverdier", fontsize=8.5, color=MUTED)
    fig.savefig(sortie, facecolor=BG); plt.close(fig)
    print("écrit :", sortie)


def main():
    args = parser(__doc__).parse_args()
    df = metropole(load_mart(args, toutes_annees=True))
    nat, evol = tendances(df)
    var = variations(df)
    out = ROOT / "resultats"; out.mkdir(exist_ok=True)
    nat.to_csv(out / "evolution_nationale.csv")
    evol.rename("evolution_2023_2025_pct").to_csv(out / "evolution_2023_2025.csv")
    var.to_csv(out / "correlations_variations.csv", index=False)
    print(evol.to_string()); print(var.to_string(index=False))
    graphique(evol, ROOT.parent / "visuels" / "evolution_2023_2025.png")


if __name__ == "__main__":
    main()
