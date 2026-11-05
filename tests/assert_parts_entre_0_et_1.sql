-- Les parts doivent rester des proportions
select code_departement_sae, part_actes_domicile, part_journees_sans_consentement
from {{ ref('mart_psy_ambulatoire__departements') }}
where part_actes_domicile not between 0 and 1
   or part_journees_sans_consentement not between 0 and 1
