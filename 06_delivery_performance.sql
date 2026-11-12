
-- Project 3: E-Commerce Operations Analysis
-- Phase 3.3A: Core Delivery KPIs

SELECT
    -- 1. Total Orders
    COUNT(*) AS total_orders,

    -- 2. Delivered Orders
    COUNT(*) FILTER (
        WHERE order_status = 'delivered'
    ) AS delivered_orders,

    -- 3. Delivery Rate (%)
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE order_status = 'delivered'
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS delivery_rate_pct,

    -- 4. Average Delivery Time (Days)
    ROUND(
        AVG(delivery_days) FILTER (
            WHERE order_status = 'delivered'
              AND purchase_to_delivery_quality = 'VALID'
        ),
        2
    ) AS avg_delivery_days,

    -- 5. On-Time Delivery Rate (%)
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE delivery_timeliness = 'ON_TIME'
        )
        / NULLIF(
            COUNT(*) FILTER (
                WHERE delivery_timeliness IN ('ON_TIME', 'LATE')
            ),
            0
        ),
        2
    ) AS on_time_rate_pct,

    -- 6. Late Delivery Rate (%)
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE delivery_timeliness = 'LATE'
        )
        / NULLIF(
            COUNT(*) FILTER (
                WHERE delivery_timeliness IN ('ON_TIME', 'LATE')
            ),
            0
        ),
        2
    ) AS late_rate_pct

FROM vw_ecommerce_analysis;


-- Validate eligible delivery orders

SELECT
    COUNT(*) FILTER (
        WHERE order_status = 'delivered'
          AND purchase_to_delivery_quality = 'VALID'
    ) AS valid_delivery_time_orders,

    COUNT(*) FILTER (
        WHERE delivery_timeliness = 'ON_TIME'
    ) AS on_time_orders,

    COUNT(*) FILTER (
        WHERE delivery_timeliness = 'LATE'
    ) AS late_orders,

    COUNT(*) FILTER (
        WHERE delivery_timeliness IN ('ON_TIME', 'LATE')
    ) AS on_time_eligible_orders

FROM vw_ecommerce_analysis;
