-- Grain de stg_sae__psy_activite : un établissement x une discipline
select finess, discipline, count(*) as nb
from {{ ref('stg_sae__psy_activite') }}
group by 1, 2
having count(*) > 1
