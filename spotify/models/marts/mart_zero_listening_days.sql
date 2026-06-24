select
    count(*) as zero_listening_days
from {{ ref('mart_daily_listens') }}
where total_minutes_listened = 0