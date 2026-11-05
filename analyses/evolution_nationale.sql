-- Évolution 2023-2025 de l'offre de psychiatrie de l'adulte, France métropolitaine
with nat as (
    select
        annee,
        sum(file_active_totale)                                                    as patients_suivis,
        sum(coalesce(actes_cmp, 0) + coalesce(actes_unites_consultation, 0))       as actes_consultation,
        sum(actes_domicile)                                                        as actes_domicile,
        sum(lits_temps_plein)                                                      as lits_temps_plein,
        sum(etp_infirmiers)                                                        as etp_infirmiers,
        sum(etp_psychiatres)                                                       as etp_psychiatres,
        sum(coalesce(places_placement_familial, 0) + coalesce(places_appartement_therapeutique, 0))
                                                                                   as places_lieux_de_vie,
        sum(journees_temps_plein) / sum(journees_lits_exploitables)                as taux_occupation
    from {{ ref('mart_psy_ambulatoire__departements') }}
    where length(code_insee) = 2
    group by 1
)

select
    n.*,
    round(100 * (n.patients_suivis / d.patients_suivis - 1), 1)           as evol_patients_pct,
    round(100 * (n.actes_consultation / d.actes_consultation - 1), 1)     as evol_consultations_pct,
    round(100 * (n.actes_domicile / d.actes_domicile - 1), 1)             as evol_domicile_pct,
    round(100 * (n.lits_temps_plein / d.lits_temps_plein - 1), 1)         as evol_lits_pct,
    round(100 * (n.etp_infirmiers / d.etp_infirmiers - 1), 1)             as evol_infirmiers_pct,
    round(100 * (n.places_lieux_de_vie / d.places_lieux_de_vie - 1), 1)   as evol_lieux_de_vie_pct
from nat n
cross join (select * from nat where annee = 2023) d
order by n.annee
