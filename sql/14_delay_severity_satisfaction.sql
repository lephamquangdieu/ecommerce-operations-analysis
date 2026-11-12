
-- Project 3: E-Commerce Operations Analysis
-- Phase 3.4C: Delay Severity vs Satisfaction

WITH review_orders AS (
    SELECT
        order_id,
        delivery_timeliness,
        days_vs_estimate,
        avg_review_score,

        CASE
            WHEN delivery_timeliness = 'ON_TIME'
                THEN '0. On Time'

            WHEN days_vs_estimate BETWEEN 1 AND 3
                THEN '1. Minor (1-3 days)'

            WHEN days_vs_estimate BETWEEN 4 AND 7
                THEN '2. Moderate (4-7 days)'

            WHEN days_vs_estimate BETWEEN 8 AND 14
                THEN '3. Significant (8-14 days)'

            WHEN days_vs_estimate > 14
                THEN '4. Severe (>14 days)'
        END AS delay_severity

    FROM vw_ecommerce_analysis

    WHERE delivery_timeliness IN ('ON_TIME', 'LATE')
      AND avg_review_score IS NOT NULL
),

satisfaction_by_severity AS (
    SELECT
        delay_severity,

        COUNT(*) AS orders_with_reviews,

        ROUND(
            AVG(avg_review_score),
            2
        ) AS avg_review_score,

        COUNT(*) FILTER (
            WHERE avg_review_score <= 2
        ) AS negative_review_orders,

        ROUND(
            100.0 * COUNT(*) FILTER (
                WHERE avg_review_score <= 2
            ) / NULLIF(COUNT(*), 0),
            2
        ) AS negative_review_rate_pct

    FROM review_orders

    GROUP BY delay_severity
)

SELECT *
FROM satisfaction_by_severity
ORDER BY delay_severity;


-- Review Coverage by Delay Severity

WITH classified_orders AS (
    SELECT
        order_id,
        avg_review_score,

        CASE
            WHEN delivery_timeliness = 'ON_TIME'
                THEN '0. On Time'
            WHEN days_vs_estimate BETWEEN 1 AND 3
                THEN '1. Minor'
            WHEN days_vs_estimate BETWEEN 4 AND 7
                THEN '2. Moderate'
            WHEN days_vs_estimate BETWEEN 8 AND 14
                THEN '3. Significant'
            WHEN days_vs_estimate > 14
                THEN '4. Severe'
        END AS delay_severity

    FROM vw_ecommerce_analysis

    WHERE delivery_timeliness IN ('ON_TIME', 'LATE')
)

SELECT
    delay_severity,

    COUNT(*) AS eligible_orders,

    COUNT(*) FILTER (
        WHERE avg_review_score IS NOT NULL
    ) AS orders_with_reviews,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE avg_review_score IS NOT NULL
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS review_coverage_pct

FROM classified_orders

GROUP BY delay_severity

ORDER BY delay_severity;


-- Delay Severity Validation

WITH classified AS (
    SELECT
        order_id,
        avg_review_score,

        CASE
            WHEN delivery_timeliness = 'ON_TIME'
                THEN 'ON_TIME'
            WHEN delivery_timeliness = 'LATE'
             AND days_vs_estimate BETWEEN 1 AND 3
                THEN 'MINOR'
            WHEN delivery_timeliness = 'LATE'
             AND days_vs_estimate BETWEEN 4 AND 7
                THEN 'MODERATE'
            WHEN delivery_timeliness = 'LATE'
             AND days_vs_estimate BETWEEN 8 AND 14
                THEN 'SIGNIFICANT'
            WHEN delivery_timeliness = 'LATE'
             AND days_vs_estimate > 14
                THEN 'SEVERE'
            ELSE NULL
        END AS severity
    FROM vw_ecommerce_analysis
    WHERE delivery_timeliness IN ('ON_TIME', 'LATE')
      AND avg_review_score IS NOT NULL
)

SELECT
    COUNT(*) AS analyzed_orders,

    COUNT(DISTINCT order_id) AS unique_orders,

    COUNT(*) FILTER (
        WHERE severity IS NULL
    ) AS unclassified_orders,

    COUNT(*) FILTER (
        WHERE avg_review_score < 1
           OR avg_review_score > 5
    ) AS invalid_scores

FROM classified;
