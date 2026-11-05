-- Grain : un établissement ayant une activité de psychiatrie de l'adulte
-- On prend la discipline GEN et non TOT pour éviter les doubles comptes (cf. documentation SAE)
with activite as (
    select * from {{ ref('stg_sae__psy_activite') }}
    where discipline = 'GEN'
),

modes_legaux as (
    select * from {{ ref('stg_sae__psy_modes_legaux') }}
),

etablissements as (
    select * from {{ ref('stg_sae__etablissements') }}
)

select
    a.*,
    e.raison_sociale,
    e.statut_juridique,
    e.code_departement_sae,
    -- PSY2 n'est pas ventilé par discipline : ces journées couvrent aussi l'infanto-juvénile
    coalesce(m.journees_sdre, 0) + coalesce(m.journees_sdt, 0) + coalesce(m.journees_peril_imminent, 0)
                                                as journees_sans_consentement,
    coalesce(m.journees_soins_libres, 0) + coalesce(m.journees_sdre, 0)
      + coalesce(m.journees_irresponsabilite_penale, 0) + coalesce(m.journees_opp, 0)
      + coalesce(m.journees_detenus, 0) + coalesce(m.journees_sdt, 0)
      + coalesce(m.journees_peril_imminent, 0)  as journees_tous_modes,
    m.a_equipe_mobile_personne_agee,
    m.interventions_equipe_mobile_personne_agee
from activite a
left join etablissements e using (finess)
left join modes_legaux m using (finess)
