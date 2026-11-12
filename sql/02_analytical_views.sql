
SELECT
    delivery_timeliness,
    COUNT(*) AS total_orders
FROM vw_delivery_analysis
GROUP BY delivery_timeliness
ORDER BY total_orders DESC;
