select
    string_field_0 as description,
    string_field_1 as top_level_category,
    string_field_2 as subcategory

from {{ source('online_retail', 'product_data') }}

where string_field_0 != 'Description'