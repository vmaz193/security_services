with source as (
    select * from {{ source('public', 'growth') }}
),

renamed as (
    select
        (split_part("quarter", '-', 1) || '-' ||
         case split_part("quarter", '-', 2)
             when 'Q1' then '01'
             when 'Q2' then '04'
             when 'Q3' then '07'
             when 'Q4' then '10'
         end || '-01')::date as quarter_date,
        service_line,
        -- Standardization
        case
            when region = 'North' then 'North America'
            when region = 'South' then 'Latin America'
            when region = 'East' then 'Europe'
            when region = 'West' then 'Asia-Pacific'
            else region
        end as region,
        market_share_percent_in_region,
        new_tech_adoption_by_clients_percent,
        new_business_pipeline_usd,
        proposal_win_rate_percent,
        yoy_carbon_footprint_reduction_percent
    from source
)

select * from renamed