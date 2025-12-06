{% macro enrich_cancer_code(icd_10_cm_code, return_field) %}

{% set cancer_codes = [
    {'code_bound_lower': 'C00', 'code_bound_upper': 'C14', 'anatomical_site': 'Lip, oral cavity, pharynx', 'severity': 'Malignant'},
    {'code_bound_lower': 'C15', 'code_bound_upper': 'C26', 'anatomical_site': 'Digestive organs', 'severity': 'Malignant'},
    {'code_bound_lower': 'C30', 'code_bound_upper': 'C39', 'anatomical_site': 'Respiratory & intrathoracic organs', 'severity': 'Malignant'},
    {'code_bound_lower': 'C40', 'code_bound_upper': 'C41', 'anatomical_site': 'Bone & articular cartilage', 'severity': 'Malignant'},
    {'code_bound_lower': 'C43', 'code_bound_upper': 'C44', 'anatomical_site': 'Melanoma & other skin cancers', 'severity': 'Malignant'},
    {'code_bound_lower': 'C45', 'code_bound_upper': 'C49', 'anatomical_site': 'Mesothelial & soft tissue', 'severity': 'Malignant'},
    {'code_bound_lower': 'C50', 'code_bound_upper': 'C50', 'anatomical_site': 'Breast', 'severity': 'Malignant'},
    {'code_bound_lower': 'C51', 'code_bound_upper': 'C58', 'anatomical_site': 'Female genital organs', 'severity': 'Malignant'},
    {'code_bound_lower': 'C60', 'code_bound_upper': 'C63', 'anatomical_site': 'Male genital organs', 'severity': 'Malignant'},
    {'code_bound_lower': 'C64', 'code_bound_upper': 'C68', 'anatomical_site': 'Urinary tract', 'severity': 'Malignant'},
    {'code_bound_lower': 'C69', 'code_bound_upper': 'C72', 'anatomical_site': 'Eye, brain, CNS', 'severity': 'Malignant'},
    {'code_bound_lower': 'C73', 'code_bound_upper': 'C75', 'anatomical_site': 'Endocrine glands', 'severity': 'Malignant'},
    {'code_bound_lower': 'C76', 'code_bound_upper': 'C80', 'anatomical_site': 'Ill-defined, secondary, and unspecified sites', 'severity': 'Malignant'},
    {'code_bound_lower': 'C81', 'code_bound_upper': 'C96', 'anatomical_site': 'Lymphoid, hematopoietic, & related tissues', 'severity': 'Malignant'},
    {'code_bound_lower': 'D00', 'code_bound_upper': 'D09', 'anatomical_site': 'Various', 'severity': 'In situ'}
] %}

-- extract the letter prefix and number suffix from the input code
{% set letter_prefix -%}
    -- remove all the digits // leave the characters
    regexp_replace(icd_10_cm_code, '[0-9]', '', 'g')
{%- endset %}
{% set number_suffix -%}
    -- remove all the non-digit characters // leave integers
    try_cast(regexp_replace(icd_10_cm_code, '[^0-9]', '', 'g') as int)
{%- endset %}
-- all cancer codes begin with one letter and are followed by two digits
-- we can use this to match the input code to the cancer codes
-- if the code is found, we return the anatomical site and severity
-- if the code is not found, or does not adhere to the expected format, we return null

    case
        {% for code_range in cancer_codes %}
            -- parse out the comparison letter prefix corresponding to this code range
            {% set comparison_letter_prefix -%}
                regexp_replace('{{ code_range.code_bound_lower }}', '[0-9]', '', 'g')
            {%- endset %}
            -- parse out the upper and lower numerical bounds corresponding to this code range
            {% set comparison_lower_bound -%}
                try_cast(regexp_replace('{{ code_range.code_bound_lower }}', '[^0-9]', '', 'g') as int)
            {%- endset %}
            {% set comparison_upper_bound -%}
                try_cast(regexp_replace('{{ code_range.code_bound_upper }}', '[^0-9]', '', 'g') as int)
            {%- endset %}

            -- figure out if input code matches this code range
            when {{ letter_prefix }} = {{ comparison_letter_prefix }} 
                and {{ number_suffix }} between {{ comparison_lower_bound }} and {{ comparison_upper_bound }}
            then '{{ code_range[return_field] }}'
        {% endfor %}
        else null
    end
{% endmacro %}
