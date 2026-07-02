-- Cihaz kategorisine göre
SELECT device_category, COUNT(DISTINCT session_key) AS sessions,
       SUM(step_7_purchase) AS orders, SUM(session_revenue) AS revenue
FROM `edtech-analytics-494713.ecommerce_project.funnel_sessions`
GROUP BY device_category ORDER BY sessions DESC;

-- Trafik kaynağı / mecra / kampanyaya göre
SELECT traffic_source, traffic_medium, traffic_campaign,
       COUNT(DISTINCT session_key) AS sessions,
       SUM(step_7_purchase) AS orders, SUM(session_revenue) AS revenue
FROM `edtech-analytics-494713.ecommerce_project.funnel_sessions`
GROUP BY traffic_source, traffic_medium, traffic_campaign
ORDER BY sessions DESC;

-- Cihaz diline göre
SELECT device_language, COUNT(DISTINCT session_key) AS sessions,
       SUM(step_7_purchase) AS orders
FROM `edtech-analytics-494713.ecommerce_project.funnel_sessions`
GROUP BY device_language ORDER BY sessions DESC;

-- İşletim sistemine göre
SELECT device_os, COUNT(DISTINCT session_key) AS sessions,
       SUM(step_7_purchase) AS orders
FROM `edtech-analytics-494713.ecommerce_project.funnel_sessions`
GROUP BY device_os ORDER BY sessions DESC;

-- Landing page'e göre
SELECT landing_page, COUNT(DISTINCT session_key) AS sessions,
       SUM(step_7_purchase) AS orders
FROM `edtech-analytics-494713.ecommerce_project.funnel_sessions`
GROUP BY landing_page ORDER BY sessions DESC LIMIT 50;
