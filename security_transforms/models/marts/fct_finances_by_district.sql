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
    sum(i.monthly_revenue_usd) as total_revenue,
    -- Business Logic: Allocate the corporate overhead cost evenly to each district
    sum(i.total_corporate_costs / i.total_districts) as allocated_corporate_overhead,
    (sum(i.monthly_revenue_usd) - sum(i.total_corporate_costs / i.total_districts)) as true_profit
from int_finance i
join risk r on i.business_unit_id = r.business_unit_id
group by 1, 2