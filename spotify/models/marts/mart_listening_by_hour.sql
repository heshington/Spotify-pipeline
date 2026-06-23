with plays as (
    select * from {{ ref('stg_plays') }}
)

select
    hour_of_day,

    count(*)                                        as total_plays,
    count(*) filter (where is_skip = false)         as completed_plays,
    round(count(*) filter (where is_skip = true)
        * 100.0 / count(*), 1)                      as skip_rate_pct,

    round(sum(minutes_played)::numeric, 1)          as total_minutes_listened,
    count(distinct play_date)                       as days_with_plays,
    count(distinct artist_name)                     as unique_artists

from plays
group by hour_of_day
order by hour_of_day asc
