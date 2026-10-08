with source as (

    select *
    from {{ source('online_retail', 'Data-2009-2011') }}

),

cleaned as (

    select
        InvoiceNo as invoice,
        StockCode as stock_code,
        Description as description,
        Quantity as quantity,
        InvoiceDate as invoice_date,
        UnitPrice as unit_price,
        cast(cast(CustomerID as int64) as string) as customer_id,
        Country as country,

        InvoiceNo like 'C%' as is_cancelled

    from source

    where Description is not null
      and UnitPrice >= 0
      and not (InvoiceNo not like 'C%' and Quantity < 0)

),

deduplicated as (

    select *
    from cleaned

    qualify row_number() over (
        partition by
            invoice,
            stock_code,
            quantity,
            invoice_date,
            description,
            country
        order by invoice_date
    ) = 1

)

select *
from deduplicated