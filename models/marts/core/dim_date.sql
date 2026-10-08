{{ config(materialized='table') }}

with dates as (

    select distinct
        invoice_date,
        order_year,
        order_quarter,
        order_month,
        order_month_name,
        order_week,
        order_day,
        order_day_name,
        order_hour

    from {{ ref('int_sales_enriched') }}

)

select
    row_number() over (
        order by invoice_date
    ) as date_key,

    invoice_date,
    order_year,
    order_quarter,
    order_month,
    order_month_name,
    order_week,
    order_day,
    order_day_name,
    order_hour

from dates