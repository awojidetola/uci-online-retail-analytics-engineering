SELECT
    COUNT(*) AS customers_with_multiple_countries
FROM (
    SELECT
        customer_id
    FROM {{ ref('stg_online_retail') }}
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
    HAVING COUNT(DISTINCT country) > 1
)