{{ config(materialized='table') }}

select
    c.customer_key,
    d.date_key,
    p.product_key,

    s.invoice,
    s.quantity,
    s.unit_price,
    s.revenue,
    s.is_cancelled

from {{ ref('int_sales_enriched') }} as s

left join {{ ref('dim_customer') }} as c
    on s.customer_id = c.customer_id

left join {{ ref('dim_date') }} as d
    on s.invoice_date = d.invoice_date

left join {{ ref('dim_product') }} as p
    on s.top_level_category = p.top_level_category
    and s.subcategory = p.subcategory