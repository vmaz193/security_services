select
    client_id,
    district_id,    -- Foreign key to join with dim_districts
    service_line,   -- Foreign key to join with dim_service_lines
    client_status   -- The complex status we calculated
from {{ ref('int_staging__clients_enriched') }}