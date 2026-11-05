-- Grain : un établissement (FINESS interrogé) x une année
with source as (
    select * from {{ source('sae', 'sae_id') }}
)

select
    cast(an as {{ dbt.type_int() }})                as annee,
    trim(fi)                                        as finess,
    trim(fi_ej)                                     as finess_ej,
    rs                                              as raison_sociale,
    stjr                                            as statut_juridique,
    cat                                             as categorie,
    -- DEP_DIFF localise l'activité réelle quand l'entité juridique répond pour plusieurs sites
    coalesce(nullif(trim(dep_diff), ''), trim(dep)) as code_departement_sae
from source
