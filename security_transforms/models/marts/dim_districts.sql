with workforce as (
    select
        district_id,
        avg(employee_turnover_rate_annual_percent) as avg_employee_turnover_rate,
        avg(employee_engagement_score) as avg_employee_engagement_score
    from {{ ref('stg_public__workforce_operation') }}
    group by 1
),
risk as (
    select
        district_id,
        sum(total_liability_claims_value_usd) as total_liability_claims_value
    from {{ ref('stg_public__risk_compliance') }}
    group by 1
)
select
    w.district_id,
    w.avg_employee_turnover_rate,
    w.avg_employee_engagement_score,
    r.total_liability_claims_value
from workforce w
left join risk r on w.district_id = r.district_id