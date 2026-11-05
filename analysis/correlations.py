"""Force et fiabilité des liens entre offre ambulatoire, lits et modes légaux de soins.

Corrélation de Spearman (rangs) : robuste aux valeurs extrêmes et aux relations non linéaires,
adaptée à 96 départements très hétérogènes.
"""
from pathlib import Path

import pandas as pd
from scipy.stats import spearmanr

from data import IDF, load_mart, metropole, parser

HYPOTHESES = [
    ("actes_domicile_pour_1000", "taux_occupation", "Domicile et occupation des lits"),
    ("actes_domicile_pour_1000", "part_journees_sans_consentement", "Domicile et part de soins sans consentement"),
    ("actes_consultation_pour_1000", "taux_occupation", "Consultations et occupation des lits"),
    ("lits_pour_100k", "part_journees_sans_consentement", "Lits et part de soins sans consentement"),
    ("lits_pour_100k", "journees_sans_consentement_pour_1000", "Lits et soins sans consentement (volume)"),
    ("lits_pour_100k", "journees_soins_libres_pour_1000", "Lits et soins libres (volume)"),
]


def tester(df, x, y):
    d = df[[x, y]].dropna()
    rho, p = spearmanr(d[x], d[y])
    return rho, p, len(d)


def main():
    args = parser(__doc__).parse_args()
    df = metropole(load_mart(args))
    rows = []
    for x, y, question in HYPOTHESES:
        rho, p, n = tester(df, x, y)
        rho_hors_idf, p_hors_idf, _ = tester(df[~df.code_insee.isin(IDF)], x, y)
        rows.append({
            "question": question, "x": x, "y": y, "n": n,
            "rho": round(rho, 2), "p_value": round(p, 4), "fiable_5pct": p < 0.05,
            "rho_hors_idf": round(rho_hors_idf, 2), "p_hors_idf": round(p_hors_idf, 4),
        })
    res = pd.DataFrame(rows)
    out = Path(__file__).parent / "resultats"
    out.mkdir(exist_ok=True)
    res.to_csv(out / "correlations.csv", index=False)
    print(res[["question", "n", "rho", "p_value", "fiable_5pct", "rho_hors_idf"]].to_string(index=False))


if __name__ == "__main__":
    main()
