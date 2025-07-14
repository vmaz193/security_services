select
    service_line
from {{ ref('stg_public__growth') }}
group by 1