-- Quand les lits manquent, est-ce la contrainte qui augmente, ou les soins libres qui reculent ?
with q as (
    select
        *,
        ntile(4) over (order by lits_pour_100k) as quartile_lits
    from {{ ref('mart_psy_ambulatoire__departements') }}
    where length(code_insee) = 2  -- France métropolitaine
      and annee = 2025
)

select
    quartile_lits,
    count(*)                                                                         as nb_departements,
    round(100000 * sum(lits_temps_plein) / sum(population_adulte), 1)                as lits_pour_100k,
    round(1000 * sum(journees_sans_consentement) / sum(population_adulte), 1)        as journees_sans_consentement_pour_1000,
    round(1000 * sum(journees_tous_modes - journees_sans_consentement) / sum(population_adulte), 1)
                                                                                     as journees_soins_libres_pour_1000,
    round(100 * sum(journees_sans_consentement) / sum(journees_tous_modes), 1)       as part_sans_consentement_pct
from q
group by 1
order by 1
