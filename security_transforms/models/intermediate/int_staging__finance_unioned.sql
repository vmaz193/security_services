with stg_finance as (
    select * from {{ ref('stg_public__finance') }}
)
-- Step 1: Isolate overhead costs from a corporate HQ business unit
, corporate_overhead as (
    select
        sum(monthly_revenue_usd) as total_corporate_costs,
        (select count(distinct district_id) from {{ ref('stg_public__workforce_operation') }}) as total_districts
    from stg_finance
    where business_unit_id = 'bu_01' -- Assuming 'bu_01' is the corporate unit
)
-- Step 2: Combine operational finance data with the overhead calculation
select
    f.*,
    co.total_corporate_costs,
    co.total_districts
from stg_finance f
cross join corporate_overhead co
where f.business_unit_id != 'bu_01'