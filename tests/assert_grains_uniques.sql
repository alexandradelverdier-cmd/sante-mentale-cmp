-- Chaque modèle doit respecter son grain : aucune ligne en double sur ses clés
{% set grains = [
    ('stg_sae__etablissements', ['finess', 'annee']),
    ('stg_sae__psy_activite', ['finess', 'discipline', 'annee']),
    ('stg_sae__psy_modes_legaux', ['finess', 'annee']),
    ('int_psy_adulte__etablissements', ['finess', 'annee']),
    ('int_population_adulte__departements', ['code_departement_sae', 'annee']),
    ('mart_psy_ambulatoire__departements', ['code_departement_sae', 'annee']),
] %}
{% for modele, cles in grains %}
select '{{ modele }}' as modele, count(*) as nb
from {{ ref(modele) }}
group by {{ cles | join(', ') }}
having count(*) > 1
{% if not loop.last %}union all{% endif %}
{% endfor %}
