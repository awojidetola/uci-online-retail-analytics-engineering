{{ config(materialized='table') }}

with products as (

    select distinct
        top_level_category,
        subcategory

    from {{ ref('int_sales_enriched') }}

)

select
    row_number() over (
        order by top_level_category, subcategory
    ) as product_key,

    top_level_category,
    subcategory

from products