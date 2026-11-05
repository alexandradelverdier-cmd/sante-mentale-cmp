-- Grain : un établissement (toutes disciplines confondues)
with source as (
    select * from {{ source('sae', 'sae_2025_psy2') }}
)

select
    trim(fi)                                as finess,
    {{ to_num('psy_c22') }}                 as journees_soins_libres,
    {{ to_num('psy_c23') }}                 as journees_sdre,
    {{ to_num('psy_c24') }}                 as journees_irresponsabilite_penale,
    {{ to_num('psy_c25') }}                 as journees_opp,
    {{ to_num('psy_c26') }}                 as journees_detenus,
    {{ to_num('psy_c27') }}                 as journees_sdt,
    {{ to_num('psy_c28') }}                 as journees_peril_imminent,
    trim(psy_a49) = '1'                     as a_equipe_mobile_personne_agee,
    {{ to_num('psy_b49') }}                 as interventions_equipe_mobile_personne_agee
from source
