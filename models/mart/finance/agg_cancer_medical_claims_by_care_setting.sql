-- pretend today's date is the latest claim date in the dataset
with today as
(
    select max(claim_start_date) as date
    from {{ ref('stg_medical_claim') }}
)

-- want to repeat the same code except for different conditions
-- in-network, out-of-network, total
{% set network_config = {
    'in_network': 'coalesce(claims.in_network_flag, 0) > 0',
    'out_of_network': 'coalesce(claims.in_network_flag, 0) = 0',
    'total': 'true'
} %}

-- rolling time periods: last 90 days, 180 days, 365 days, 730 days, alltime
{% set time_config = {
    'l90': "claims.claim_start_date >= today.date - interval '90 days'",
    'l180': "claims.claim_start_date >= today.date - interval '180 days'",
    'l365': "claims.claim_start_date >= today.date - interval '365 days'",
    'l730': "claims.claim_start_date >= today.date - interval '730 days'",
    'alltime': 'true'
} %}

-- combine above configs
{% set final_config = {} %}
{% for nc_key, nc_condition in network_config.items() %}
    {% for tc_key, tc_condition in time_config.items() %}
        {% set new_key = nc_key ~ '_' ~ tc_key %}
        {% set new_condition = nc_condition ~ ' and ' ~ tc_condition %}
        {% set _ = final_config.update({new_key: new_condition}) %}
    {% endfor %}
{% endfor %}

select
    {{ dbt_utils.generate_surrogate_key([
        'icd.icd_10_cm_code',
        'claims.place_of_service_code'
    ]) }} as diagnosis_code_place_of_service_key,
    icd.icd_10_cm_code,
    icd.cancer_anatomical_site,
    icd.cancer_severity,
    claims.place_of_service_code, -- TODO: convert to plaintext categories
    -- generate a set of filtered-or-not columns by in-network status and time of claim start date
    {% for key, condition in final_config.items() %}
        count(distinct claims.claim_id)
        filter (where {{ condition }}) as n_claims_{{ key }},
        sum(claims.total_cost_amount)
        filter (where {{ condition }}) as total_cost_amount_{{ key }}
        -- trailing comma except the final pass through the loop
        {% if not loop.last %} , {% endif %}
    {% endfor %}    

from
    {{ ref('int_icd_10_cm_codes') }} icd
-- inner join restricts the claims to just those involving at least 1 cancer diagnosis code
inner join
    {{ ref('stg_medical_claim') }} claims
on 
    (
        {%- for n in range(1, 25) %}
        icd.icd_10_cm_code = claims.diagnosis_code_{{ n }}{% if not loop.last %} or{% endif %}
        {%- endfor %}
    )
    -- filter to cancer codes only
    and icd.cancer_anatomical_site is not null
-- silly hack to pretend like "today" is the most recent claim date in the dataset
-- without this time anchoring, the windowing is not informative
left join today on true
group by all
