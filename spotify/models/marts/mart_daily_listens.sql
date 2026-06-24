with plays as (
    select * from {{ ref('stg_plays') }}
),

daily_stats as (
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
),

date_spine as (
    select * from {{ ref('dim_date') }}
)

select
    d.date                                              as play_date,
    to_char(d.date, 'YYYY-MM')                         as play_month,
    d.day_of_week_name                                  as day_of_week,
    d.day_of_week_num,
    d.is_weekend,

    coalesce(s.total_plays, 0)                         as total_plays,
    coalesce(s.completed_plays, 0)                     as completed_plays,
    coalesce(s.skipped_plays, 0)                       as skipped_plays,
    coalesce(s.skip_rate_pct, 0)                       as skip_rate_pct,
    coalesce(s.unique_artists, 0)                      as unique_artists,
    coalesce(s.unique_tracks, 0)                       as unique_tracks,
    coalesce(s.total_minutes_listened, 0)              as total_minutes_listened,
    coalesce(s.avg_minutes_per_play, 0)                as avg_minutes_per_play

from date_spine d
left join daily_stats s
    on s.play_date = d.date
order by d.date desc