with stg_clients as (
    select * from {{ ref('stg_public__client_service_delivery') }}
),
-- In a real scenario, we'd have a client creation date. We'll use a proxy.
client_first_appearance as (
    select client_id, min(current_date) as first_seen_date
    from stg_clients
    group by 1
)
select
    s.client_id,
    s.district_id,
    s.service_line,
    s.csat_score,
    s.monthly_client_complaints,
    s.monthly_security_incidents,
    s.was_client_retained,
    -- Business Logic: Determine client status based on multiple conditions
    case
        when f.first_seen_date > current_date - interval '3 months' then 'New'
        when s.csat_score < 2.5 and s.monthly_client_complaints > 5 then 'At Risk'
        when s.was_client_retained = 0 then 'Churned'
        else 'Active'
    end as client_status
from stg_clients s
join client_first_appearance f on s.client_id = f.client_id