-- Grain : un établissement x une discipline de psychiatrie x une année
with source as (
    select * from {{ source('sae', 'sae_psy') }}
)

select
    cast(an as {{ dbt.type_int() }})        as annee,
    trim(fi)                                as finess,
    trim(dis)                               as discipline,

    -- structures ambulatoires
    {{ to_num('nb_cmp_seul') }}             as nb_cmp,
    {{ to_num('nb_consult_seul') }}         as nb_unites_consultation,
    {{ to_num('nb_cattp') }}                as nb_cattp,

    -- activité ambulatoire (actes, soins et interventions)
    {{ to_num('act_cmp_seul') }}            as actes_cmp,
    {{ to_num('act_consult_seul') }}        as actes_unites_consultation,
    {{ to_num('act_cattp') }}               as actes_cattp,
    {{ to_num('act_ad') }}                  as actes_domicile,
    {{ to_num('act_ems') }}                 as actes_medico_social,

    -- alternatives à l'hospitalisation
    {{ to_num('cap_pft') }}                 as places_placement_familial,
    {{ to_num('cap_aat') }}                 as places_appartement_therapeutique,
    {{ to_num('cap_hdj') }}                 as places_hopital_de_jour,

    -- hospitalisation à temps plein
    {{ to_num('cap_htp') }}                 as lits_temps_plein,
    {{ to_num('jli_htp') }}                 as journees_lits_exploitables,
    {{ to_num('jou_htp') }}                 as journees_temps_plein,
    {{ to_num('sej_htp') }}                 as sejours_temps_plein,
    -- journées des autres prises en charge à temps complet, pour le contrôle de cohérence avec PSY2
    coalesce({{ to_num('jou_pft') }}, 0) + coalesce({{ to_num('jou_aat') }}, 0)
      + coalesce({{ to_num('jou_acp') }}, 0) + coalesce({{ to_num('jou_ccu') }}, 0)
                                            as journees_autres_temps_complet,

    -- patients
    {{ to_num('fil_tot') }}                 as file_active_totale,
    {{ to_num('fil_amb') }}                 as file_active_ambulatoire_exclusive,

    -- personnel (toute la psychiatrie de l'établissement, pas seulement le CMP)
    {{ to_num('etpsal_pkt') }}              as etp_psychiatres,
    {{ to_num('etp_inf') }}                 as etp_infirmiers,
    {{ to_num('etp_psy') }}                 as etp_psychologues
from source
