SELECT
  'a) Oturum başlangıcı' AS step, SUM(step_1_session_start) AS sessions FROM `edtech-analytics-494713.ecommerce_project.funnel_sessions`
UNION ALL SELECT 'b) Ürün incelemesi', SUM(step_2_view_item) FROM `edtech-analytics-494713.ecommerce_project.funnel_sessions`
UNION ALL SELECT 'c) Sepete ekleme', SUM(step_3_add_to_cart) FROM `edtech-analytics-494713.ecommerce_project.funnel_sessions`
UNION ALL SELECT 'd) Sipariş başlatma', SUM(step_4_begin_checkout) FROM `edtech-analytics-494713.ecommerce_project.funnel_sessions`
UNION ALL SELECT 'e) Teslimat bilgisi', SUM(step_5_add_shipping_info) FROM `edtech-analytics-494713.ecommerce_project.funnel_sessions`
UNION ALL SELECT 'f) Ödeme bilgisi', SUM(step_6_add_payment_info) FROM `edtech-analytics-494713.ecommerce_project.funnel_sessions`
UNION ALL SELECT 'g) Satın alma', SUM(step_7_purchase) FROM `edtech-analytics-494713.ecommerce_project.funnel_sessions`
ORDER BY step;
