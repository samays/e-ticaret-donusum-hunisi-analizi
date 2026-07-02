CREATE TEMP FUNCTION get_string_param(params ARRAY<STRUCT<key STRING, value STRUCT<string_value STRING, int_value INT64, float_value FLOAT64, double_value FLOAT64>>>, target_key STRING)
RETURNS STRING AS (
  (SELECT value.string_value FROM UNNEST(params) WHERE key = target_key LIMIT 1)
);

CREATE TEMP FUNCTION get_int_param(params ARRAY<STRUCT<key STRING, value STRUCT<string_value STRING, int_value INT64, float_value FLOAT64, double_value FLOAT64>>>, target_key STRING)
RETURNS INT64 AS (
  (SELECT value.int_value FROM UNNEST(params) WHERE key = target_key LIMIT 1)
);

WITH raw_events AS (
  SELECT
    user_pseudo_id,
    event_name,
    TIMESTAMP_MICROS(event_timestamp) AS event_ts,
    -- ÖNEMLİ: ga_session_id GA4'te int_value olarak saklanır, string_value DEĞİL
    CAST(get_int_param(event_params, 'ga_session_id') AS STRING) AS session_id_str,
    get_string_param(event_params, 'page_location') AS page_location,
    device.category AS device_category,
    device.language AS device_language,
    device.operating_system AS device_os,
    traffic_source.source AS traffic_source,
    traffic_source.medium AS traffic_medium,
    traffic_source.name AS traffic_campaign,
    ecommerce.purchase_revenue AS purchase_revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
    AND event_name IN (
      'session_start', 'view_item', 'add_to_cart',
      'begin_checkout', 'add_shipping_info', 'add_payment_info', 'purchase'
    )
),

sessioned AS (
  SELECT
    *,
    CONCAT(user_pseudo_id, '-', session_id_str) AS session_key
  FROM raw_events
  WHERE session_id_str IS NOT NULL
),

session_landing AS (
  SELECT
    session_key,
    ARRAY_AGG(page_location ORDER BY event_ts LIMIT 1)[OFFSET(0)] AS landing_page,
    MIN(event_ts) AS session_start_ts,
    ARRAY_AGG(device_category ORDER BY event_ts LIMIT 1)[OFFSET(0)] AS device_category,
    ARRAY_AGG(device_language ORDER BY
