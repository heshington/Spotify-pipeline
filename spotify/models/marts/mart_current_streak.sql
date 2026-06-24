with daily as (
    select
        play_date,
        case when total_minutes_listened > 0 then 1 else 0 end as has_listening
    from {{ ref('mart_daily_listens') }}
    where play_date <= (select max(play_date) from {{ ref('mart_daily_listens') }} where total_minutes_listened > 0)
    order by play_date desc
),

streak as (
    select
        play_date,
        has_listening,
        sum(case when has_listening = 0 then 1 else 0 end)
            over (order by play_date desc rows unbounded preceding) as zero_count
    from daily
)

select
    count(*) as current_streak_days
from streak
where zero_count = 0
and has_listening = 1