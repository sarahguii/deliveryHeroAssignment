{{ config(
    alias='conversion_rate',
    materialized='view'
) }}
  
SELECT
    fp.experiment_variant_id,
    u.country,
    u.device,
    -- SUM(fp.num_orders) AS total_orders,
    -- COUNT(DISTINCT fp.user_id) AS total_participants,
    ROUND(
        (SUM(fp.num_orders) / NULLIF(COUNT(DISTINCT fp.user_id), 0)) * 100,
        2
    ) AS conversion_rate
FROM
    {{ ref('data__fact_participants') }} AS fp
LEFT JOIN
    {{ ref('data__dim_users') }} AS u ON fp.user_id = u.user_id
GROUP BY 1, 2, 3
