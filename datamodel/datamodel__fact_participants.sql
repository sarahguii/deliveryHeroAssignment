{{
    config(
        alias='fact_participants',
        materialized='table',
        unique_key='experiment_variant_user_id',
        tags=['data_model'],
        partition_by={
        "field": "assignment_date",  
        "data_type": "date"
        },
        cluster_by = ["experiment_variant_id", "user_id"]
    )
}}
 
-- depends on: {{ ref('hiring_search_analytics__behavioural_customer_data') }}
-- depends on: {{ ref('hiring_search_analytics__backend_logging_data') }}

WITH sessions_participated AS (
    SELECT DISTINCT 
      -- take only sessions where experiment participated
      session_id,
      -- Experiment-related data
      be.response.experiments.key AS experiment_id,
      be.response.experiments.variation AS variant_id,
    FROM {{ ref('hiring_search_analytics__behavioural_customer_data') }} st
    JOIN {{ ref('hiring_search_analytics__backend_logging_data') }} AS be ON st.session_id = be.perseus_session_id
    WHERE st.event_name = 'experiment.participated'
),
    
session_data AS (
  SELECT
    -- Experiment-related data
    experiment_id,
    variant_id,
    -- User and session-level data
    st.customer_id AS user_id,
    st.session_id,
    IF(st.event_name = 'transaction', st.transaction_id, NULL) AS order_id,
    -- Metadata for segmentation and tracking
    DATE(be.partition_date) AS assignment_date,
    -- Derived fields
    IF(be.response.experiments.variation = 'control', TRUE, FALSE) AS is_control_group,
    SUM(IF(st.event_name = 'add_cart.click', 1, 0)) AS add_to_cart,
    SUM(IF(st.event_name = 'pdp_impression', 1, 0)) AS pdp_viewed
  FROM
    {{ ref('hiring_search_analytics__behavioural_customer_data') }} AS st
  JOIN sessions_participated sp ON sp.session_id = st.session_id
  GROUP BY 1, 2, 3, 4, 5, 6, 7
)

SELECT 
    CONCAT(experiment_id, variant_id, user_id) AS experiment_variant_user_id,
    experiment_variant_id,
    experiment_id,
    user_id,
    assignment_date,
    is_control_group,
    COUNT(DISTINCT session_id) AS num_sessions,
    COUNT(DISTINCT o.order_id) AS num_orders,
    SUM(add_to_cart) AS num_atc,
    SUM(pdp_viewed) AS num_pdp_viewed 
FROM session_data s
LEFT JOIN {{ ref('hiring_search_analytics__customer_orders_data') }} o ON s.order_id = o.order_id
WHERE o.is_successful
GROUP BY 1, 2, 3, 4, 5, 6
