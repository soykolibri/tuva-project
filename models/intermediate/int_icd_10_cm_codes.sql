{{ config(alias='icd_10_cm_codes') }}

-- scrape all diagnosis codes from medical claims
with unioned as (
    {%- set diagnosis_cols = range(1, 25) -%}
    {%- for n in diagnosis_cols %}
        select diagnosis_code_{{ n }} as icd_10_cm_code
        from {{ ref('stg_medical_claim') }}
        where
            coalesce(diagnosis_code_type, '') = 'icd-10-cm'
            and diagnosis_code_{{ n }} is not null
        {%- if not loop.last %} union all {% endif -%}
    {%- endfor %}
)
-- dedupe codes and classify which are cancer-related
select 
    distinct icd_10_cm_code,
    {{ enrich_cancer_code(icd_10_cm_code, 'anatomical_site') }} as cancer_anatomical_site,
    {{ enrich_cancer_code(icd_10_cm_code, 'severity') }} as cancer_severity
from unioned
