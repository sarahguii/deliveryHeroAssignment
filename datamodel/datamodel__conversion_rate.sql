{{ config(
    alias='conversion_rate',
    materialized='view'
) }}

WITH participant_level AS (
SELECT 
    experiment_variant_id,
    u.country,
    u.device,
    COUNT(DISTINCT IF(fp.num_orders >= 1, fp.user_id, NULL)) AS total_users_who_ordered,
    COUNT(DISTINCT fp.user_id) AS total_users,
FROM 
    {{ ref('data__fact_participants') }} AS fp
LEFT JOIN
    {{ ref('data__dim_users') }} AS u ON fp.user_id = u.user_id
GROUP BY 1, 2, 3
)
    
SELECT
    experiment_variant_id,
    country,
    device,
    ROUND(SAFE_DIVIDE(total_users_who_ordered, total_users) * 100, 2) AS conversion_rate
FROM
    participant_level fp
