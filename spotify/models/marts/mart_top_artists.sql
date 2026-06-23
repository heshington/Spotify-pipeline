with plays as (
    select * from {{ ref('stg_plays') }}
)

select
    artist_name,

    count(*)                                        as total_plays,
    count(*) filter (where is_skip = false)         as completed_plays,
    count(*) filter (where is_skip = true)          as skipped_plays,
    round(count(*) filter (where is_skip = true)
        * 100.0 / count(*), 1)                      as skip_rate_pct,

    round(sum(minutes_played)::numeric, 1)          as total_minutes_listened,
    count(distinct track_name)                      as unique_tracks_played,
    count(distinct play_date)                       as days_listened,

    min(play_date)                                  as first_listened,
    max(play_date)                                  as last_listened

from plays
group by artist_name
order by total_minutes_listened desc
