select
    {{ dbt_utils.generate_surrogate_key(['client_id', 'district_id']) }} as client_health_id,
    client_id,
    district_id,
    service_line,
    client_status, -- Using the new complex status
    csat_score,
    monthly_client_complaints,
    monthly_security_incidents
from {{ ref('int_staging__clients_enriched') }}