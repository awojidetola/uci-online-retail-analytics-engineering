{{ config(materialized='table') }}

select
    c.country,
    d.order_year,
    d.order_month,
    d.order_month_name,

    count(distinct case
        when not s.is_cancelled then s.invoice
    end) as completed_orders,

    round(sum(case
        when not s.is_cancelled then s.revenue
        else 0
    end), 2) as total_revenue,

    sum(case
        when not s.is_cancelled then s.quantity
        else 0
    end) as total_quantity,

    count(distinct case
        when not s.is_cancelled then s.customer_key
    end) as customers,

    countif(not s.is_cancelled) as sales_lines,

    countif(s.is_cancelled) as cancelled_sales_lines,

    round(
        safe_divide(
            countif(s.is_cancelled),
            count(*)
        ) * 100,
        2
    ) as cancellation_rate

from {{ ref('fct_sales') }} as s

left join {{ ref('dim_customer') }} as c
    on s.customer_key = c.customer_key

left join {{ ref('dim_date') }} as d
    on s.date_key = d.date_key

group by
    c.country,
    d.order_year,
    d.order_month,
    d.order_month_name