
-- Project 3: E-Commerce Operations Analysis
-- Phase 3.4B: Delivery vs Customer Satisfaction

SELECT
    delivery_timeliness,

    -- Orders with reviews
    COUNT(*) AS orders_with_reviews,

    -- Average Review Score
    ROUND(
        AVG(avg_review_score),
        2
    ) AS avg_review_score,

    -- Negative Reviews (Order-Level)
    COUNT(*) FILTER (
        WHERE avg_review_score <= 2
    ) AS negative_review_orders,

    -- Negative Review Rate
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE avg_review_score <= 2
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS negative_review_rate_pct,

    -- Positive Review Rate
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE avg_review_score >= 4
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS positive_review_rate_pct

FROM vw_ecommerce_analysis

WHERE delivery_timeliness IN ('ON_TIME', 'LATE')
  AND avg_review_score IS NOT NULL

GROUP BY delivery_timeliness

ORDER BY delivery_timeliness;


-- Difference in Average Review Score

WITH satisfaction_by_delivery AS (
    SELECT
        delivery_timeliness,

        AVG(avg_review_score)
            AS avg_score

    FROM vw_ecommerce_analysis

    WHERE delivery_timeliness IN ('ON_TIME', 'LATE')
      AND avg_review_score IS NOT NULL

    GROUP BY delivery_timeliness
)

SELECT
    ROUND(
        MAX(avg_score) FILTER (
            WHERE delivery_timeliness = 'ON_TIME'
        ),
        2
    ) AS on_time_avg_score,

    ROUND(
        MAX(avg_score) FILTER (
            WHERE delivery_timeliness = 'LATE'
        ),
        2
    ) AS late_avg_score,

    ROUND(
        (
            MAX(avg_score) FILTER (
                WHERE delivery_timeliness = 'ON_TIME'
            )
            -
            MAX(avg_score) FILTER (
                WHERE delivery_timeliness = 'LATE'
            )
        ),
        2
    ) AS review_score_gap

FROM satisfaction_by_delivery;


-- Review Coverage by Delivery Timeliness

SELECT
    delivery_timeliness,

    COUNT(*) AS eligible_orders,

    COUNT(*) FILTER (
        WHERE avg_review_score IS NOT NULL
    ) AS orders_with_reviews,

    COUNT(*) FILTER (
        WHERE avg_review_score IS NULL
    ) AS orders_without_reviews,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE avg_review_score IS NOT NULL
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS review_coverage_pct

FROM vw_ecommerce_analysis

WHERE delivery_timeliness IN ('ON_TIME', 'LATE')

GROUP BY delivery_timeliness

ORDER BY delivery_timeliness;


-- Customer Satisfaction Comparison QA

SELECT
    COUNT(*) AS analyzed_orders,

    COUNT(DISTINCT order_id)
        AS unique_orders,

    COUNT(*) FILTER (
        WHERE avg_review_score < 1
           OR avg_review_score > 5
    ) AS invalid_review_scores,

    COUNT(*) FILTER (
        WHERE delivery_timeliness
              NOT IN ('ON_TIME', 'LATE')
    ) AS invalid_delivery_groups

FROM vw_ecommerce_analysis

WHERE delivery_timeliness IN ('ON_TIME', 'LATE')
  AND avg_review_score IS NOT NULL;

