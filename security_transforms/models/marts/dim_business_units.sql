with stg_finance as (
    select * from {{ ref('stg_public__finance') }}
),
-- Use a window function to number the rows for each business unit.
-- This allows us to reliably select only the first occurrence of each ID.
ranked_business_units as (
    select
        business_unit_id,
        region,
        country,
        row_number() over(partition by business_unit_id order by region, country) as rn
    from stg_finance
)
select
    business_unit_id,
    region,
    country
from ranked_business_units
-- By selecting only the first ranked row, we guarantee a unique business_unit_id.
where rn = 1