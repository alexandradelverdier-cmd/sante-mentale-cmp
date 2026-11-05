-- Grain : un département
-- Indicateurs d'accès à la psychiatrie ambulatoire et au suivi à domicile, psychiatrie de l'adulte, SAE 2025
with etab as (
    select * from {{ ref('int_psy_adulte__etablissements') }}
),

dep as (
    select
        code_departement_sae,
        count(*)                                    as nb_etablissements,
        sum(nb_cmp)                                 as nb_cmp,
        sum(nb_cattp)                               as nb_cattp,
        sum(actes_cmp)                              as actes_cmp,
        sum(actes_unites_consultation)              as actes_unites_consultation,
        sum(nb_unites_consultation)                 as nb_unites_consultation,
        sum(actes_cattp)                            as actes_cattp,
        sum(actes_domicile)                         as actes_domicile,
        sum(places_placement_familial)              as places_placement_familial,
        sum(places_appartement_therapeutique)       as places_appartement_therapeutique,
        sum(lits_temps_plein)                       as lits_temps_plein,
        sum(journees_lits_exploitables)             as journees_lits_exploitables,
        sum(journees_temps_plein)                   as journees_temps_plein,
        sum(sejours_temps_plein)                    as sejours_temps_plein,
        sum(file_active_totale)                     as file_active_totale,
        sum(file_active_ambulatoire_exclusive)      as file_active_ambulatoire_exclusive,
        sum(etp_psychiatres)                        as etp_psychiatres,
        sum(etp_psychologues)                       as etp_psychologues,
        sum(etp_infirmiers)                         as etp_infirmiers,
        sum(journees_sans_consentement)             as journees_sans_consentement,
        sum(journees_tous_modes)                    as journees_tous_modes,
        sum(case when a_equipe_mobile_personne_agee then 1 else 0 end)
                                                    as nb_equipes_mobiles_personne_agee
    from etab
    group by 1
),

pop as (
    select * from {{ ref('int_population_adulte__departements') }}
)

select
    dep.code_departement_sae,
    pop.code_insee,
    pop.nom_departement,
    pop.population_adulte,
    dep.*  {{- ' except (code_departement_sae)' if target.type == 'bigquery' else ' exclude (code_departement_sae)' }},

    -- offre ambulatoire et domicile, rapportée à la population adulte
    {{ ratio('dep.nb_cmp * 100000', 'pop.population_adulte') }}                 as cmp_pour_100k,
    {{ ratio('dep.actes_cmp * 1000', 'pop.population_adulte') }}                as actes_cmp_pour_1000,
    -- consultations = CMP + unités de consultation : certains hôpitaux (CHU surtout) déclarent leur activité dans ces unités plutôt qu'en CMP
    {{ ratio('(coalesce(dep.actes_cmp, 0) + coalesce(dep.actes_unites_consultation, 0)) * 1000', 'pop.population_adulte') }}
                                                                                as actes_consultation_pour_1000,
    {{ ratio('dep.actes_domicile * 1000', 'pop.population_adulte') }}           as actes_domicile_pour_1000,
    {{ ratio('dep.actes_domicile',
             'coalesce(dep.actes_domicile, 0) + coalesce(dep.actes_cmp, 0) + coalesce(dep.actes_unites_consultation, 0)') }}
                                                                                as part_actes_domicile,
    {{ ratio('(coalesce(dep.places_placement_familial, 0) + coalesce(dep.places_appartement_therapeutique, 0)) * 100000',
             'pop.population_adulte') }}                                        as places_alternatives_pour_100k,

    -- soignants (psychiatrie publique et privée de l'établissement, tous lieux d'exercice)
    {{ ratio('dep.etp_psychologues * 100000', 'pop.population_adulte') }}       as etp_psychologues_pour_100k,
    {{ ratio('(dep.etp_psychiatres + dep.etp_psychologues + dep.etp_infirmiers) * 100000',
             'pop.population_adulte') }}                                        as etp_soignants_pour_100k,
    {{ ratio('dep.file_active_ambulatoire_exclusive',
             'dep.etp_psychiatres + dep.etp_psychologues + dep.etp_infirmiers') }}
                                                                                as patients_ambulatoires_par_etp_soignant,

    -- tension hospitalière
    {{ ratio('dep.lits_temps_plein * 100000', 'pop.population_adulte') }}       as lits_pour_100k,
    {{ ratio('dep.journees_temps_plein', 'dep.journees_lits_exploitables') }}   as taux_occupation,
    {{ ratio('dep.journees_temps_plein', 'dep.sejours_temps_plein') }}          as duree_moyenne_sejour,
    {{ ratio('dep.journees_sans_consentement', 'dep.journees_tous_modes') }}    as part_journees_sans_consentement,
    {{ ratio('dep.journees_sans_consentement * 1000', 'pop.population_adulte') }}
                                                                                as journees_sans_consentement_pour_1000,
    {{ ratio('(dep.journees_tous_modes - dep.journees_sans_consentement) * 1000', 'pop.population_adulte') }}
                                                                                as journees_soins_libres_pour_1000

from dep
-- inner join : exclut Saint-Pierre-et-Miquelon, absent des estimations Insee
inner join pop using (code_departement_sae)
