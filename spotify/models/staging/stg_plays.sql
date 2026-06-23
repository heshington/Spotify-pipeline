with source as (
    select * from raw.streams
),

converted as (
    select
        id,
        end_time AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific/Auckland' as end_time,
        artist_name,
        track_name,
        ms_played
    from source
),

cleaned as (
    select
        id,
        end_time,
        artist_name,
        track_name,
        ms_played,

        round(ms_played / 1000.0, 1)            as seconds_played,
        round(ms_played / 60000.0, 2)           as minutes_played,

        date(end_time)                          as play_date,
        date_trunc('week', end_time)::date      as play_week,
        date_trunc('month', end_time)::date     as play_month,
        extract(hour from end_time)::int        as hour_of_day,
        to_char(end_time, 'Day')                as day_of_week,
        extract(dow from end_time)::int         as day_of_week_num,

        case when ms_played < 30000 then true else false end as is_skip

    from converted
)

select * from cleaned