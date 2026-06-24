with daily as (
    select
        play_date,
        total_minutes_listened,
        case when total_minutes_listened > 0 then 1 else 0 end as has_listening
    from {{ ref('mart_daily_listens') }}
),

-- assign a group number to each consecutive run of listening days
grouped as (
    select
        play_date,
        has_listening,
        row_number() over (order by play_date) -
        sum(has_listening) over (order by play_date rows unbounded preceding) as grp
    from daily
),

-- count streak lengths
streaks as (
    select
        grp,
        count(*) as streak_length
    from grouped
    where has_listening = 1
    group by grp
)

select
    max(streak_length) as longest_streak_days
from streaks