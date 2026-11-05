"""Lecture du mart dbt, depuis BigQuery (par défaut) ou depuis une base DuckDB locale."""
import argparse

MART = "mart_psy_ambulatoire__departements"
IDF = ["75", "77", "78", "91", "92", "93", "94", "95"]


def parser(description):
    p = argparse.ArgumentParser(description=description)
    p.add_argument("--project", default="delverdier-alexandra-wagon")
    p.add_argument("--dataset", default="dbt_sante_mentale_cmp")
    p.add_argument("--duckdb", help="chemin d'une base DuckDB locale, à la place de BigQuery")
    p.add_argument("--annee", type=int, default=2025, help="année de la SAE analysée (une seule à la fois)")
    return p


def load_mart(args, toutes_annees=False):
    """Une seule année par défaut : empiler les années compterait chaque département plusieurs fois
    et gonflerait artificiellement la significativité des corrélations."""
    filtre = "" if toutes_annees else f" where annee = {int(args.annee)}"
    if args.duckdb:
        import duckdb
        return duckdb.connect(args.duckdb, read_only=True).execute(f"select * from main.{MART}{filtre}").df()
    from google.cloud import bigquery
    client = bigquery.Client(project=args.project)
    return client.query(f"select * from `{args.project}.{args.dataset}.{MART}`{filtre}").to_dataframe()


def metropole(df):
    """96 départements de métropole (codes Insee à 2 caractères)."""
    return df[df["code_insee"].str.len() == 2].copy()
