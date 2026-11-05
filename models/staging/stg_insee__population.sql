-- Grain : un département x une classe d'âge
select
    p.code_insee,
    r.code_sae               as code_departement_sae,
    p.nom_departement,
    p.classe_age,
    p.annee,
    p.population
from {{ ref('insee_population_departement') }} p
left join {{ ref('ref_departements') }} r using (code_insee)
