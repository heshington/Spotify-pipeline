with plays as (
    select * from {{ ref('stg_plays') }}
)

select
    play_date,
    play_month,
    day_of_week,
    day_of_week_num,

    count(*)                                        as total_plays,
    count(*) filter (where is_skip = false)         as completed_plays,
    count(*) filter (where is_skip = true)          as skipped_plays,
    round(count(*) filter (where is_skip = true)
        * 100.0 / count(*), 1)                      as skip_rate_pct,

    count(distinct artist_name)                     as unique_artists,
    count(distinct track_name)                      as unique_tracks,

    round(sum(minutes_played)::numeric, 1)          as total_minutes_listened,
    round(avg(minutes_played)::numeric, 2)          as avg_minutes_per_play

from plays
group by play_date, play_month, day_of_week, day_of_week_num
order by play_date desc
