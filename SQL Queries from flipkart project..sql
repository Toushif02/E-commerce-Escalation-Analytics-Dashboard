Select * from agents_200
Select * from support_tickets_1000
Select * from ecommerce_orders_1000

--Re-escalation rate by type

SELECT escalation_type, COUNT(*) AS total_tickets, SUM(CASE WHEN re_escalated = 1 THEN 1 ELSE 0 END) AS re_escalated_count, 
ROUND(100.0 * SUM(CASE WHEN re_escalated = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS re_escalation_pct, ROUND(AVG(csat_score), 2) AS avg_csat 
FROM support_tickets_1000 GROUP BY escalation_type ORDER BY re_escalation_pct DESC;

--Average resolution time vs CSAT by level

SELECT 
    escalation_level, 
    escalation_type, 
    ROUND(AVG(CAST(DATEDIFF(day, created_date, resolved_date) AS FLOAT)), 1) AS avg_resolution_days, 
    ROUND(AVG(CAST(csat_score AS FLOAT)), 2) AS avg_csat, 
    COUNT(*) AS ticket_count 
FROM support_tickets_1000 
WHERE resolution_status = 'Resolved' 
GROUP BY escalation_level, escalation_type 
ORDER BY avg_resolution_days DESC;

--Monthly ticket trend with CSAT
SELECT 
    FORMAT(created_date, 'yyyy-MM') AS month, 
    COUNT(*) AS tickets, 
    ROUND(AVG(CAST(csat_score AS FLOAT)), 2) AS avg_csat, 
    ROUND(100.0 * SUM(CASE WHEN re_escalated = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS re_esc_rate_pct 
FROM support_tickets_1000 
GROUP BY FORMAT(created_date, 'yyyy-MM') 
ORDER BY month;

--which product category generates most escalations?

SELECT o.product_category, o.fulfillment_type, 
COUNT(e.ticket_id) AS escalation_count, ROUND(AVG(e.csat_score), 2) AS avg_csat, 
SUM(CASE WHEN e.re_escalated=1 THEN 1 ELSE 0 END) AS re_esc 
FROM support_tickets_1000 e JOIN ecommerce_orders_1000 o ON e.order_id = o.order_id 
GROUP BY o.product_category, o.fulfillment_type ORDER BY escalation_count DESC

