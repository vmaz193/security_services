with source as (
    select * from {{ source('public', 'client_service_delivery') }}
),

renamed as (
    select
        client_id,
        -- Standardization
        'dist_' || lpad(regexp_replace(district_id, '\D', '', 'g'), 2, '0') as district_id,
        -- Standardization
        case
            when service_line = 'Line1' then 'On-Site Guarding'
            when service_line = 'Line2' then 'Electronic Security'
            when service_line = 'Line3' then 'Mobile Patrol'
            when service_line = 'Line4' then 'Corporate Risk Management'
            else service_line
        end as service_line,
        client_industry,
        csat_score_1_to_5 as csat_score,
        client_retention_last_12_months as was_client_retained,
        monthly_client_complaints,
        incident_response_time_minutes,
        incident_resolution_time_hours,
        monthly_security_incidents,
        false_alarm_rate_percent,
        sla_compliance_percent
    from source
)

select * from renamed