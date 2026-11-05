-- Les départements qui suivent davantage leurs patients à domicile ont-ils des lits moins saturés
-- et moins de soins sans consentement ?
with q as (
    select
        *,
        ntile(4) over (order by actes_domicile_pour_1000) as quartile_domicile
    from {{ ref('mart_psy_ambulatoire__departements') }}
    where actes_domicile_pour_1000 is not null
      and annee = 2025
)

select
    quartile_domicile,
    count(*)                                                      as nb_departements,
    round(100 * sum(journees_temps_plein) / sum(journees_lits_exploitables), 1)  as taux_occupation_pct,
    round(100 * sum(journees_sans_consentement) / sum(journees_tous_modes), 1)   as part_sans_consentement_pct
from q
group by 1
order by 1
