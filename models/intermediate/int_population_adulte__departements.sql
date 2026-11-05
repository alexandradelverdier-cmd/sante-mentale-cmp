-- Grain : un département. Population de 20 ans et plus, proxy du champ de la psychiatrie de l'adulte
select
    code_departement_sae,
    code_insee,
    nom_departement,
    annee,
    sum(population) as population_adulte
from {{ ref('stg_insee__population') }}
where classe_age != '0_19'
group by 1, 2, 3, 4
