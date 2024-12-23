{{ config(
    alias='order_value',
    materialized='view'
) }}

SELECT
    fe.experiment_variant_id,
    fe.session_id,
    u.region,
    u.device,
    SUM(o.order_value_eur + o.discount_value_eur + o.voucher_value_eur) AS order_value_wo_voucher_discount
FROM
    {{ ref('data__fact_experiments') }} AS fe
LEFT JOIN
    {{ ref('data__fact_orders') } AS o ON fe.order_id = o.order_id
LEFT JOIN 
    {{ ref('data__dim_users') } AS u ON fe.user_id = u.user_id
WHERE
    o.is_successful = TRUE
GROUP BY
    1, 2, 3, 4
