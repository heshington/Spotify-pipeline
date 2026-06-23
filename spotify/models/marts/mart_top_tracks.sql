with plays as (
    select * from {{ ref('stg_plays') }}
)

select
    track_name,
    artist_name,

    count(*)                                        as total_plays,
    count(*) filter (where is_skip = false)         as completed_plays,
    count(*) filter (where is_skip = true)          as skipped_plays,
    round(count(*) filter (where is_skip = true)
        * 100.0 / count(*), 1)                      as skip_rate_pct,

    round(sum(minutes_played)::numeric, 1)          as total_minutes_listened,
    count(distinct play_date)                       as days_played,

    min(play_date)                                  as first_played,
    max(play_date)                                  as last_played

from plays
group by track_name, artist_name
order by total_plays desc
