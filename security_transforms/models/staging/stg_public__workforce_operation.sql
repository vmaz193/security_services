with source as (
    select * from {{ source('public', 'workforce_operation') }}
),

renamed as (
    select
        -- Standardization: Assuming format 'DIST-XX-YY', extracting the number
        'dist_' || lpad(split_part(district_id, '-', 3), 2, '0') as district_id,
        employee_turnover_rate_annual_percent,
        employee_engagement_score_1_to_10 as employee_engagement_score,
        guard_tour_completion_rate_percent,
        required_training_completion_rate_percent,
        officer_absenteeism_rate_percent,
        weekly_overtime_hours_per_officer,
        lost_time_injury_rate_ltir
    from source
)

select * from renamed