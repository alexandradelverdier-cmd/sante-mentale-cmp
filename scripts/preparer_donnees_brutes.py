"""Prépare les fichiers bruts du projet à partir des archives publiées par la DREES et l'Insee.

Pour chaque archive SAE (« Bases statistiques - formats SAS-CSV »), extrait les tables ID, PSY et PSY2,
harmonise les noms de colonnes (majuscules) et l'encodage (UTF-8), puis empile les années.
Aucun calcul n'est fait ici : toutes les transformations métier sont dans dbt.

Usage :
    python scripts/preparer_donnees_brutes.py \\
        --sae "SAE_2023_Bases_statistiques_-_formats_SAS-CSV.7z" "SAE_2024_...7z" "SAE_2025_...7z" \\
        --insee estim-pop-dep-sexe-gca-1975-2023.xls
"""
import argparse
import io
import re
import tempfile
from pathlib import Path

import pandas as pd
import py7zr

ROOT = Path(__file__).resolve().parents[1]
TABLES = {
    "id": ["AN", "FI", "RS", "FI_EJ", "STJR", "CAT", "CATR", "REG", "DEP", "REG_DIFF", "DEP_DIFF", "COMINSEE"],
    "psy": None,   # toutes les colonnes
    "psy2": None,
}
CLASSES_AGE = ["0_19", "20_39", "40_59", "60_74", "75_plus"]
DOM = {"971": "9A", "972": "9B", "973": "9C", "974": "9D", "976": "9F"}


def lire_csv(octets):
    """Les millésimes sont encodés en Latin-1 jusqu'en 2024, en UTF-8 ensuite."""
    for enc in ("utf-8", "latin-1"):
        try:
            texte = octets.decode(enc)
            break
        except UnicodeDecodeError:
            continue
    df = pd.read_csv(io.StringIO(texte), sep=";", dtype=str)
    df.columns = [c.upper() for c in df.columns]
    return df


def extraire_archive(chemin):
    with tempfile.TemporaryDirectory() as tmp, py7zr.SevenZipFile(chemin) as z:
        cibles = {}
        for table in TABLES:
            motif = re.compile(rf"Bases CSV/{table}_(20\d\d)r?\.csv$", re.I)
            for n in z.getnames():
                if motif.search(n):
                    cibles[table] = n
        z.extract(path=tmp, targets=list(cibles.values()))
        return {t: lire_csv((Path(tmp) / n).read_bytes()) for t, n in cibles.items()}


def preparer_sae(archives, sortie):
    par_table = {t: [] for t in TABLES}
    for a in archives:
        for table, df in extraire_archive(a).items():
            par_table[table].append(df)
            print(f"{Path(a).name} : {table} {df.AN.iloc[0]} ({len(df)} lignes)")
    for table, dfs in par_table.items():
        df = pd.concat(dfs, ignore_index=True)
        if TABLES[table]:
            df = df[[c for c in TABLES[table] if c in df.columns]]
        df = df.drop(columns=[c for c in ("RS",) if table != "id" and c in df.columns])
        df.to_csv(sortie / f"sae_{table}.csv", index=False)
        print(f"écrit : sae_{table}.csv, années {sorted(df.AN.unique())}")


def preparer_insee(fichier, seeds):
    feuilles = pd.read_excel(fichier, sheet_name=None, header=None, dtype={0: str})
    lignes = []
    for nom, f in feuilles.items():
        if not re.fullmatch(r"\d{4}", nom):
            continue
        f = f.iloc[5:]
        f = f[f[0].astype(str).str.fullmatch(r"\d{2,3}|2A|2B", na=False)]
        t = f[[0, 1, 2, 3, 4, 5, 6]].copy()
        t.columns = ["code_insee", "nom_departement"] + CLASSES_AGE
        t = t.melt(["code_insee", "nom_departement"], var_name="classe_age", value_name="population")
        t["annee"] = int(nom)
        lignes.append(t)
    pop = pd.concat(lignes)
    pop = pop[pop.annee >= 2020]
    pop["nom_departement"] = pop.nom_departement.str.strip()
    pop["population"] = pop.population.astype(int)
    pop.sort_values(["annee", "code_insee", "classe_age"]).to_csv(seeds / "insee_population_departement.csv", index=False)
    ref = pop[pop.annee == pop.annee.max()][["code_insee", "nom_departement"]].drop_duplicates()
    ref["code_sae"] = ref.code_insee.map(lambda c: DOM.get(c, c))
    ref[["code_sae", "code_insee", "nom_departement"]].to_csv(seeds / "ref_departements.csv", index=False)
    print(f"écrit : seeds Insee, années {sorted(pop.annee.unique())}")


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--sae", nargs="+", required=True, help="archives .7z de la SAE")
    p.add_argument("--insee", required=True, help="fichier Insee estim-pop-dep-sexe-gca")
    args = p.parse_args()
    raw = ROOT / "data" / "raw"
    raw.mkdir(parents=True, exist_ok=True)
    preparer_sae(args.sae, raw)
    preparer_insee(args.insee, ROOT / "seeds")


if __name__ == "__main__":
    main()
