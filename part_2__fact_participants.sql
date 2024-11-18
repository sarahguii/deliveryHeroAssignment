{{
    config(
        alias='fact_participants',
        materialized='table',
        unique_key='experiment_variant_user_id',
        partition_by={
        "field": "assignment_date",  
        "data_type": "date"
        },
        cluster_by = ["experiment_variant_id", "user_id"]
    )
}}
 
-- depends on: {{ ref('hiring_search_analytics__behavioural_customer_data') }}
-- depends on: {{ ref('hiring_search_analytics__backend_logging_data') }}

WITH session_data AS (
SELECT
    -- Experiment-related data
    be.response.experiments.key AS experiment_id,
    be.response.experiments.variation AS variant_id,
    -- User and session-level data
    st.customer_id AS user_id,
    st.session_id,
    st.transaction_id,
    -- Metadata for segmentation and tracking
    DATE(be.partition_date) AS assignment_date,
    -- Derived fields
    IF(be.response.experiments.variation = 'control', TRUE, FALSE) AS is_control_group,
    SUM(IF(event_name = 'add_to_cart', 1, 0)) AS add_to_cart,
    SUM(IF(event_name = 'pdp_impression', 1, 0)) AS pdp_viewed
FROM
    {{ ref('hiring_search_analytics__behavioural_customer_data') }} AS st
JOIN
    {{ ref('hiring_search_analytics__backend_logging_data') }} AS be
ON
    st.session_id = be.perseus_session_id
WHERE
    st.event_name = 'experiment.participated'
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
    COUNT(DISTINCT transaction_id) AS num_orders,
    SUM(add_to_cart) AS num_atc,
    SUM(pdp_viewed) AS num_pdp_viewed 
FROM session_data
GROUP BY 1, 2, 3, 4, 5, 6
