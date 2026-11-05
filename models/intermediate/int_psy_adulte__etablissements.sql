-- Grain : un établissement ayant une activité de psychiatrie de l'adulte x une année
-- On prend la discipline GEN et non TOT pour éviter les doubles comptes (cf. documentation SAE)
with activite as (
    select * from {{ ref('stg_sae__psy_activite') }}
    where discipline = 'GEN'
),

-- total établissement (toutes disciplines), même périmètre que PSY2
total as (
    select
        finess,
        annee,
        coalesce(journees_temps_plein, 0) + journees_autres_temps_complet as journees_temps_complet_psy
    from {{ ref('stg_sae__psy_activite') }}
    where discipline = 'TOT'
),

modes_legaux as (
    select
        *,
        coalesce(journees_soins_libres, 0) + coalesce(journees_sdre, 0)
          + coalesce(journees_irresponsabilite_penale, 0) + coalesce(journees_opp, 0)
          + coalesce(journees_detenus, 0) + coalesce(journees_sdt, 0)
          + coalesce(journees_peril_imminent, 0)        as journees_tous_modes_declarees,
        coalesce(journees_sdre, 0) + coalesce(journees_sdt, 0)
          + coalesce(journees_peril_imminent, 0)        as journees_sans_consentement_declarees
    from {{ ref('stg_sae__psy_modes_legaux') }}
),

etablissements as (
    select * from {{ ref('stg_sae__etablissements') }}
),

controle as (
    select
        m.*,
        t.journees_temps_complet_psy,
        -- PSY2 doit ventiler les mêmes journées que PSY : un écart de plus d'un facteur 2 signale une erreur de déclaration
        -- (ex. CHU de Grenoble en 2024 : 586 847 journées dans PSY2 contre environ 9 500 dans PSY)
        m.journees_tous_modes_declarees between 0.5 * t.journees_temps_complet_psy and 2 * t.journees_temps_complet_psy
            as modes_legaux_coherents
    from modes_legaux m
    left join total t using (finess, annee)
)

select
    a.*,
    e.raison_sociale,
    e.statut_juridique,
    e.code_departement_sae,
    coalesce(c.modes_legaux_coherents, false)                       as modes_legaux_coherents,
    -- PSY2 n'est pas ventilé par discipline : ces journées couvrent aussi l'infanto-juvénile
    case when c.modes_legaux_coherents then c.journees_sans_consentement_declarees end
                                                                    as journees_sans_consentement,
    case when c.modes_legaux_coherents then c.journees_tous_modes_declarees end
                                                                    as journees_tous_modes,
    c.a_equipe_mobile_personne_agee,
    c.interventions_equipe_mobile_personne_agee
from activite a
left join etablissements e using (finess, annee)
left join controle c using (finess, annee)
