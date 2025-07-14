with source as (
    select * from {{ source('public', 'finance') }}
),

renamed as (
    select
        -- Standardization
        case
            when region = 'North' then 'North America'
            when region = 'South' then 'Latin America'
            when region = 'East' then 'Europe'
            when region = 'West' then 'Asia-Pacific'
            else region
        end as region,
        country,
        -- Standardization
        'bu_' || lpad(business_unit_id::text, 2, '0') as business_unit_id,
        monthly_revenue_usd,
        gross_profit_margin_percent,
        overtime_costs_as_percent_of_payroll,
        client_acquisition_cost_usd,
        client_lifetime_value_usd
    from source
)

select * from renamed