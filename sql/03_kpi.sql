SELECT
  COUNT(DISTINCT session_key) AS total_sessions,
  SUM(step_7_purchase) AS total_orders,
  SUM(session_revenue) AS total_revenue,
  SAFE_DIVIDE(SUM(step_7_purchase), COUNT(DISTINCT session_key)) AS conversion_rate,
  SAFE_DIVIDE(SUM(session_revenue), NULLIF(SUM(step_7_purchase), 0)) AS avg_order_value
FROM `edtech-analytics-494713.ecommerce_project.funnel_sessions`;
