{{ config(materialized='table') }}

with customers as (

    select
        customer_id,
        country,
        invoice_date,

        row_number() over (
            partition by customer_id
            order by invoice_date desc
        ) as rn

    from {{ ref('stg_online_retail') }}

    where customer_id is not null

)

select
    row_number() over (
        order by customer_id
    ) as customer_key,

    customer_id,
    country

from customers

where rn = 1