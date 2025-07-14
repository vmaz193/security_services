with int_finance as (
    select * from {{ ref('int_staging__finance_unioned') }}
),
risk as (
    select district_id, business_unit_id from {{ ref('stg_public__risk_compliance') }}
)
select
    -- Foreign Keys
    r.district_id,
    i.business_unit_id,
    -- Measures
    round(sum(i.monthly_revenue_usd)::numeric,2) as total_revenue,
    -- Business Logic: Allocate the corporate overhead cost evenly to each district
    round(sum(i.total_corporate_costs / i.total_districts)::numeric,2) as allocated_corporate_overhead,
    round((sum(i.monthly_revenue_usd) - sum(i.total_corporate_costs / i.total_districts))::numeric,2) as true_profit
from int_finance i
join risk r on i.business_unit_id = r.business_unit_id
group by 1, 2