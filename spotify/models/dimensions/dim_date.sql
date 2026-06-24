with date_spine as (
    select generate_series(
        '2025-06-21'::date,
        current_date,
        '1 day'::interval
    )::date as date
)

select
    date,
    extract(dow from date)::int        as day_of_week_num,    -- 0 = Sunday, 6 = Saturday
    to_char(date, 'Day')               as day_of_week_name,
    extract(day from date)::int        as day_of_month,
    extract(month from date)::int      as month_num,
    to_char(date, 'Month')             as month_name,
    extract(quarter from date)::int    as quarter,
    extract(year from date)::int       as year,
    extract(isodow from date)::int     as iso_day_of_week,    -- 1 = Monday, 7 = Sunday
    case
        when extract(isodow from date) in (6, 7) then true
        else false
    end                                as is_weekend
from date_spine