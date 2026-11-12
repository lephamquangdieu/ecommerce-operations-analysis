
-- Project 3: E-Commerce Operations Analysis
-- Phase 3.5C: Regional Delivery & Value Analysis

SELECT
    customer_state,

    -- 1. Order Volume
    COUNT(*) AS total_orders,

    COUNT(*) FILTER (
        WHERE order_status = 'delivered'
    ) AS delivered_orders,

    -- 2. Commercial Value
    ROUND(SUM(items_value), 2)
        AS total_items_value,

    ROUND(SUM(freight_value), 2)
        AS total_freight_value,

    ROUND(SUM(total_payment_value), 2)
        AS total_payment_value,

    -- 3. Delivery Performance
    COUNT(*) FILTER (
        WHERE delivery_timeliness IN ('ON_TIME', 'LATE')
    ) AS eligible_orders,

    COUNT(*) FILTER (
        WHERE delivery_timeliness = 'LATE'
    ) AS late_orders,

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
    ) AS late_rate_pct,

    ROUND(
        AVG(delivery_days) FILTER (
            WHERE order_status = 'delivered'
              AND purchase_to_delivery_quality = 'VALID'
        ),
        2
    ) AS avg_delivery_days,

    -- 4. Customer Satisfaction
    ROUND(
        AVG(avg_review_score),
        2
    ) AS avg_review_score

FROM vw_ecommerce_analysis

WHERE customer_state IS NOT NULL

GROUP BY customer_state

ORDER BY total_items_value DESC NULLS LAST;


-- Regional Financial Reconciliation

WITH regional_totals AS (
    SELECT
        customer_state,
        SUM(items_value) AS items_value,
        SUM(freight_value) AS freight_value,
        SUM(total_payment_value) AS payment_value

    FROM vw_ecommerce_analysis

    WHERE customer_state IS NOT NULL

    GROUP BY customer_state
),

source_totals AS (
    SELECT
        SUM(items_value) AS items_value,
        SUM(freight_value) AS freight_value,
        SUM(total_payment_value) AS payment_value

    FROM vw_ecommerce_analysis

    WHERE customer_state IS NOT NULL
)

SELECT
    ROUND(SUM(r.items_value), 2)
        AS regional_items_value,

    ROUND(MAX(s.items_value), 2)
        AS source_items_value,

    ROUND(SUM(r.freight_value), 2)
        AS regional_freight_value,

    ROUND(MAX(s.freight_value), 2)
        AS source_freight_value,

    ROUND(SUM(r.payment_value), 2)
        AS regional_payment_value,

    ROUND(MAX(s.payment_value), 2)
        AS source_payment_value

FROM regional_totals r
CROSS JOIN source_totals s;


-- Overall Late Delivery Rate

SELECT
    COUNT(*) AS eligible_orders,

    COUNT(*) FILTER (
        WHERE delivery_timeliness = 'LATE'
    ) AS late_orders,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE delivery_timeliness = 'LATE'
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS overall_late_rate_pct

FROM vw_ecommerce_analysis

WHERE delivery_timeliness IN ('ON_TIME', 'LATE');


-- Regions with Above-Average Late Delivery Rate

WITH overall AS (
    SELECT
        100.0 * COUNT(*) FILTER (
            WHERE delivery_timeliness = 'LATE'
        ) / NULLIF(COUNT(*), 0)
            AS overall_late_rate

    FROM vw_ecommerce_analysis

    WHERE delivery_timeliness IN ('ON_TIME', 'LATE')
),

regional AS (
    SELECT
        customer_state,

        COUNT(*) AS eligible_orders,

        COUNT(*) FILTER (
            WHERE delivery_timeliness = 'LATE'
        ) AS late_orders,

        100.0 * COUNT(*) FILTER (
            WHERE delivery_timeliness = 'LATE'
        ) / NULLIF(COUNT(*), 0)
            AS regional_late_rate

    FROM vw_ecommerce_analysis

    WHERE delivery_timeliness IN ('ON_TIME', 'LATE')
      AND customer_state IS NOT NULL

    GROUP BY customer_state
)

SELECT
    r.customer_state,
    r.eligible_orders,
    r.late_orders,

    ROUND(r.regional_late_rate, 2)
        AS regional_late_rate_pct,

    ROUND(o.overall_late_rate, 2)
        AS overall_late_rate_pct,

    ROUND(
        r.regional_late_rate - o.overall_late_rate,
        2
    ) AS late_rate_gap_pp

FROM regional r

CROSS JOIN overall o

WHERE r.eligible_orders >= 100
  AND r.regional_late_rate > o.overall_late_rate

ORDER BY
    late_rate_gap_pp DESC,
    r.eligible_orders DESC;


-- Regional Share of Late Orders

SELECT
    customer_state,

    COUNT(*) FILTER (
        WHERE delivery_timeliness = 'LATE'
    ) AS late_orders,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE delivery_timeliness = 'LATE'
        )
        / NULLIF(
            SUM(
                COUNT(*) FILTER (
                    WHERE delivery_timeliness = 'LATE'
                )
            ) OVER (), 0
        ),
        2
    ) AS share_of_all_late_orders_pct

FROM vw_ecommerce_analysis

WHERE customer_state IS NOT NULL

GROUP BY customer_state

ORDER BY late_orders DESC;


-- Regional Order Reconciliation

SELECT
    COUNT(*) AS total_orders,

    COUNT(DISTINCT order_id) AS unique_orders,

    COUNT(*) FILTER (
        WHERE customer_state IS NULL
    ) AS missing_customer_state

FROM vw_ecommerce_analysis;
