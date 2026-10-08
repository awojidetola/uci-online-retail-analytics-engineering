{{ config(materialized='table') }}

with customer_metrics as (

    select
        c.customer_id,

        count(distinct s.invoice) as customer_orders,

        round(sum(s.revenue), 2) as customer_revenue,

        round(
            safe_divide(
                sum(s.revenue),
                count(distinct s.invoice)
            ),
            2
        ) as customer_aov,

        count(distinct s.invoice) > 1 as repeat_customer

    from {{ ref('fct_sales') }} as s

    inner join {{ ref('dim_customer') }} as c
        on s.customer_key = c.customer_key

    where not s.is_cancelled

    group by c.customer_id

),

customer_segments as (

    select
        customer_id,
        customer_orders,
        customer_revenue,
        customer_aov,
        repeat_customer,

        ntile(5) over (
            order by customer_revenue desc
        ) as revenue_quintile

    from customer_metrics

)

select
    customer_id,
    customer_orders,
    customer_revenue,
    customer_aov,
    repeat_customer,
    revenue_quintile,

    case
        when revenue_quintile = 1 then 'Top 20%'
        else 'Bottom 80%'
    end as customer_group

from customer_segments