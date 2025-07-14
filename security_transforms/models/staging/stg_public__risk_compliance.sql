with source as (
    select * from {{ source('public', 'risk_compliance') }}
),

renamed as (
    select
        to_date("date", 'YYYY-MM-DD') as risk_date,
        -- Standardization
        'bu_' || lpad(split_part(business_unit_id, '-', 2), 2, '0') as business_unit_id,
        'dist_' || lpad(split_part(district_id, '-', 2), 2, '0') as district_id,
        compliance_audit_pass_rate_percent,
        monthly_legal_complaints,
        monthly_hr_complaints,
        liability_claims_this_month,
        total_liability_claims_value_usd,
        days_since_last_major_safety_incident
    from source
)

select * from renamed