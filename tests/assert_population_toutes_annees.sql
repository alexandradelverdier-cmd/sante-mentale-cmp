-- Chaque année de la SAE doit trouver une population de référence pour chaque département
select a.annee, count(distinct p.code_departement_sae) as nb_departements
from (select distinct annee from {{ ref('stg_sae__etablissements') }}) a
left join {{ ref('int_population_adulte__departements') }} p using (annee)
group by 1
having count(distinct p.code_departement_sae) < 101
