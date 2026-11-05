{# Les CSV bruts sont chargés en texte : on convertit proprement, les cases vides deviennent NULL #}
{% macro to_num(col) -%}
    cast(nullif(trim({{ col }}), '') as {{ dbt.type_float() }})
{%- endmacro %}

{% macro ratio(num, den) -%}
    ({{ num }}) / nullif({{ den }}, 0)
{%- endmacro %}
