SELECT
  DATE(session_start_ts) AS session_date,
  COUNT(DISTINCT session_key) AS sessions,
  SUM(step_7_purchase) AS orders,
  SUM(session_revenue) AS revenue
FROM `edtech-analytics-494713.ecommerce_project.funnel_sessions`
GROUP BY session_date
ORDER BY session_date;
