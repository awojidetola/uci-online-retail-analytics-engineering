with sales as (

    select *
    from {{ ref('stg_online_retail') }}

),

sales_with_features as (

    select
        *,
        
        round(unit_price * quantity, 2) as revenue,

        extract(year from invoice_date) as order_year,
        extract(quarter from invoice_date) as order_quarter,
        extract(month from invoice_date) as order_month,
        format_date('%B', date(invoice_date)) as order_month_name,
        extract(week from invoice_date) as order_week,
        extract(day from invoice_date) as order_day,
        format_date('%A', date(invoice_date)) as order_day_name,
        extract(hour from invoice_date) as order_hour

    from sales

),

final as (

    select
        s.*,
        p.top_level_category,
        p.subcategory

    from sales_with_features as s

    left join {{ ref('stg_product_data') }} as p
        on regexp_replace(trim(upper(s.description)), r'\s+', ' ')
         = regexp_replace(trim(upper(p.description)), r'\s+', ' ')

)

select *
from final