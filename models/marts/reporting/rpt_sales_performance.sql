{{ config(materialized='table') }}

select
    s.invoice,
    d.invoice_date,
    c.customer_id,
    c.country,
    p.top_level_category,
    p.subcategory,
    s.quantity,
    s.unit_price,
    s.revenue,
    s.is_cancelled,

    d.order_year,
    d.order_quarter,
    d.order_month,
    d.order_month_name,
    d.order_week,
    d.order_day,
    d.order_day_name,
    d.order_hour,

    ca.customer_orders,
    ca.customer_revenue,
    ca.customer_aov,
    ca.repeat_customer,
    ca.customer_group

from {{ ref('fct_sales') }} as s

left join {{ ref('dim_customer') }} as c
    on s.customer_key = c.customer_key

left join {{ ref('dim_date') }} as d
    on s.date_key = d.date_key

left join {{ ref('dim_product') }} as p
    on s.product_key = p.product_key

left join {{ ref('rpt_customer_analytics') }} as ca
    on c.customer_id = ca.customer_id