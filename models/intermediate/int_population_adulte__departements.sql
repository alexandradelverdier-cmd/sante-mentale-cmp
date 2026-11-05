-- Grain : un département x une année de la SAE
-- Population de 20 ans et plus, proxy du champ de la psychiatrie de l'adulte.
-- Chaque année de la SAE prend la dernière estimation Insee disponible à cette date.
with population as (
    select
        code_departement_sae,
        code_insee,
        nom_departement,
        annee as annee_population,
        sum(population) as population_adulte
    from {{ ref('stg_insee__population') }}
    where classe_age != '0_19'
    group by 1, 2, 3, 4
),

annees_sae as (
    select distinct annee from {{ ref('stg_sae__etablissements') }}
),

correspondance as (
    select
        a.annee,
        max(p.annee_population) as annee_population
    from annees_sae a
    inner join (select distinct annee_population from population) p
        on p.annee_population <= a.annee
    group by 1
)

select
    p.code_departement_sae,
    p.code_insee,
    p.nom_departement,
    c.annee,
    c.annee_population,
    p.population_adulte
from correspondance c
inner join population p using (annee_population)
