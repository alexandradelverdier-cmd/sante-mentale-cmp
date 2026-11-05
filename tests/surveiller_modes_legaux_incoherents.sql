-- Surveillance qualité : établissements dont les modes légaux sont écartés (PSY2 incohérent avec PSY ou absent).
-- Une vingtaine de cas par an est attendue ; au-delà de 30, la qualité de déclaration s'est dégradée.
{{ config(severity='warn') }}
select annee, count(*) as nb_etablissements_exclus
from {{ ref('int_psy_adulte__etablissements') }}
where not modes_legaux_coherents
group by 1
having count(*) > 30
