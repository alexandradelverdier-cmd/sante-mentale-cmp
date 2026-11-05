"""Cartes de la psychiatrie hors les murs : consultations et suivi à domicile, par département."""
import json
import urllib.request
from pathlib import Path

import geopandas as gpd
import matplotlib.pyplot as plt
import pandas as pd
from matplotlib.patches import Patch

from data import load_mart, parser

GEOJSON_URL = "https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/departements-version-simplifiee.geojson"
ROOT = Path(__file__).resolve().parent
VISUELS = ROOT.parent / "visuels"
INK, MUTED, BG = "#1f1e1b", "#6b6a65", "#fbfaf7"
PETITE_COURONNE = {"75": "Paris", "92": "Hauts-\nde-Seine", "93": "Seine-\nSaint-Denis", "94": "Val-de-\nMarne"}

CARTES = {
    "consultations": dict(
        colonne="actes_consultation_pour_1000",
        fichier="carte_consultations.png",
        bins=[0, 150, 180, 220, 270, 10_000],
        labels=["moins de 150", "150 à 180", "180 à 220", "220 à 270", "plus de 270"],
        ramp=["#fde3d6", "#f6b08f", "#eb6834", "#b8461a", "#7a2c0e"],
        titre="Les consultations en psychiatrie",
        sous_titre=["Actes en CMP et en unités de consultation,", "pour 1 000 adultes, psychiatrie de l'adulte, 2025"],
        accroche="Jusqu'à 7 fois plus de consultations selon le département",
        texte=["De 68 à 467 actes pour 1 000 adultes. La consultation reste le mode de suivi",
               "principal : 88 % des soins psychiatriques hors hospitalisation."],
    ),
    "domicile": dict(
        colonne="actes_domicile_pour_1000",
        fichier="carte_soins_domicile.png",
        bins=[0, 15, 25, 40, 60, 10_000],
        labels=["moins de 15", "15 à 25", "25 à 40", "40 à 60", "plus de 60"],
        ramp=["#cde2fb", "#86b6ef", "#3987e5", "#1c5cab", "#0d366b"],
        titre="Le suivi psychiatrique à domicile",
        sous_titre=["Actes des équipes de psychiatrie au domicile ou en lieu de vie,",
                    "pour 1 000 adultes, psychiatrie de l'adulte, 2025"],
        accroche="De 1 à 109 selon le département",
        texte=["En France, seulement 12 % de l'activité ambulatoire se fait chez le patient."],
    ),
}


def fond_de_carte():
    cache = ROOT / ".cache" / "departements.geojson"
    if not cache.exists():
        cache.parent.mkdir(exist_ok=True)
        urllib.request.urlretrieve(GEOJSON_URL, cache)
    return gpd.read_file(cache)


def dessiner(geo, mart, cfg):
    g = geo.merge(mart[["code_insee", cfg["colonne"]]], left_on="code", right_on="code_insee", how="left").to_crs(2154)
    g["v"] = g[cfg["colonne"]]
    g["cls"] = pd.cut(g.v, cfg["bins"], labels=False, right=False)
    g["col"] = g.cls.map(lambda c: cfg["ramp"][int(c)] if pd.notna(c) else "#e4e2dd")

    fig = plt.figure(figsize=(8, 10), dpi=150, facecolor=BG)
    ax = fig.add_axes([0.16, 0.06, 0.84, 0.72]); ax.set_axis_off()
    g.plot(ax=ax, color=g.col, edgecolor=BG, linewidth=0.8)

    fig.text(0.06, 0.94, cfg["titre"], fontsize=22, weight="bold", color=INK)
    for k, ligne in enumerate(cfg["sous_titre"]):
        fig.text(0.06, 0.905 - 0.023 * k, ligne, fontsize=12.5, color=MUTED)
    fig.text(0.06, 0.835, cfg["accroche"], fontsize=15, weight="bold", color=INK)
    for k, ligne in enumerate(cfg["texte"]):
        fig.text(0.06, 0.805 - 0.022 * k, ligne, fontsize=11, color=INK)

    legende = [Patch(facecolor=c, edgecolor="none", label=l) for c, l in zip(cfg["ramp"], cfg["labels"])]
    ax.legend(handles=legende, loc="upper left", frameon=False, fontsize=10, labelcolor=INK,
              title="Actes pour\n1 000 adultes", title_fontsize=10, alignment="left",
              bbox_to_anchor=(0.06, 0.76), bbox_transform=fig.transFigure)

    # zoom Paris et petite couronne, trop petits à l'échelle nationale
    pc = g[g.code.isin(PETITE_COURONNE)]
    ax2 = fig.add_axes([0.02, 0.15, 0.27, 0.22]); ax2.set_axis_off()
    pc.plot(ax=ax2, color=pc.col, edgecolor=BG, linewidth=1.5)
    for _, r in pc.iterrows():
        p = r.geometry.representative_point()
        ax2.annotate(f"{PETITE_COURONNE[r.code]}\n{r.v:.0f}", (p.x, p.y), ha="center", va="center", fontsize=8,
                     color="white" if r.cls >= 3 else INK, weight="bold")
    fig.text(0.05, 0.385, "Zoom Paris et petite couronne", fontsize=9.5, color=MUTED, weight="bold")
    x0, y0, x1, y1 = pc.total_bounds
    ax.plot([x0, x1, x1, x0, x0], [y0, y0, y1, y1, y0], color=INK, lw=0.8)

    fig.text(0.06, 0.015, "Sources : DREES, SAE 2025 ; Insee, population 2023. France métropolitaine affichée. "
             "Analyse : Alexandra Delverdier", fontsize=8.5, color=MUTED)
    VISUELS.mkdir(exist_ok=True)
    fig.savefig(VISUELS / cfg["fichier"], facecolor=BG)
    plt.close(fig)
    print("écrit :", VISUELS / cfg["fichier"])


def main():
    args = parser(__doc__).parse_args()
    mart, geo = load_mart(args), fond_de_carte()
    for cfg in CARTES.values():
        dessiner(geo, mart, cfg)


if __name__ == "__main__":
    main()
