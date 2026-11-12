-- Project 3: E-Commerce Operations Analysis
-- Phase 3.1: Order Overview

SELECT
    COUNT(*) AS total_orders
FROM olist_orders_dataset;

-- Phase 3.2A: Orders & Customers Analytical View

CREATE OR REPLACE VIEW vw_orders_customers AS

SELECT
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,

    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date

FROM olist_orders_dataset o

LEFT JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id;
    
-- Phase 3.2A: View Validation

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders,

    COUNT(*) FILTER (
        WHERE customer_unique_id IS NULL
    ) AS missing_customer_matches

FROM vw_orders_customers;


-- Phase 3.2B: Delivery Analysis View

CREATE OR REPLACE VIEW vw_delivery_analysis AS

SELECT
    o.order_id,
    o.customer_unique_id,
    o.customer_city,
    o.customer_state,
    o.order_status,

    o.order_purchase_timestamp,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    q.purchase_to_carrier_quality,
    q.carrier_to_delivery_quality,
    q.purchase_to_delivery_quality,

    -- 1. Delivery Status
    CASE
        WHEN o.order_status = 'delivered'
         AND o.order_delivered_customer_date IS NULL
            THEN 'DATA_ISSUE'

        WHEN o.order_status = 'delivered'
            THEN 'DELIVERED'

        ELSE 'NOT_DELIVERED'
    END AS delivery_status,

    -- 2. Delivery Time (days)
    CASE
        WHEN o.order_status = 'delivered'
         AND q.purchase_to_delivery_quality = 'VALID'
        THEN ROUND(
            EXTRACT(EPOCH FROM (
                o.order_delivered_customer_date
                - o.order_purchase_timestamp
            ))::numeric / 86400,
            2
        )
        ELSE NULL
    END AS delivery_days,

    -- 3. On-Time / Late Classification
    CASE
        WHEN o.order_status = 'delivered'
         AND q.purchase_to_delivery_quality = 'VALID'
         AND o.order_estimated_delivery_date IS NOT NULL

        THEN
            CASE
                WHEN o.order_delivered_customer_date::date
                     <= o.order_estimated_delivery_date::date
                    THEN 'ON_TIME'
                ELSE 'LATE'
            END

        ELSE 'NOT_APPLICABLE'
    END AS delivery_timeliness,

    -- 4. Actual vs. Estimated Delivery Date
    CASE
        WHEN o.order_status = 'delivered'
         AND q.purchase_to_delivery_quality = 'VALID'
         AND o.order_estimated_delivery_date IS NOT NULL

        THEN
            o.order_delivered_customer_date::date
            - o.order_estimated_delivery_date::date

        ELSE NULL
    END AS days_vs_estimate

FROM vw_orders_customers o

LEFT JOIN vw_order_timeline_quality q
    ON o.order_id = q.order_id;


-- Phase 3.2C: Review Multiplicity Check

SELECT
    order_id,
    COUNT(*) AS review_count

FROM olist_order_reviews_dataset

GROUP BY order_id

HAVING COUNT(*) > 1

ORDER BY review_count DESC, order_id;


-- Phase 3.2C: Aggregate Reviews by Order

CREATE OR REPLACE VIEW vw_reviews_aggregated AS

SELECT
    order_id,

    COUNT(*) AS review_count,

    ROUND(
        AVG(review_score)::numeric,
        2
    ) AS avg_review_score,

    MIN(review_score) AS min_review_score,

    MAX(review_score) AS max_review_score,

    COUNT(*) FILTER (
        WHERE review_score <= 2
    ) AS negative_review_count,

    COUNT(*) FILTER (
        WHERE review_score >= 4
    ) AS positive_review_count

FROM olist_order_reviews_dataset

WHERE review_score BETWEEN 1 AND 5

GROUP BY order_id;


SELECT
    COUNT(*) AS total_rows,

    COUNT(DISTINCT order_id) AS unique_orders,

    COUNT(*) - COUNT(DISTINCT order_id)
        AS duplicate_orders

FROM vw_reviews_aggregated;

--
SELECT
    MIN(avg_review_score) AS min_avg_score,
    MAX(avg_review_score) AS max_avg_score,

    SUM(review_count) AS total_valid_reviews

FROM vw_reviews_aggregated;

--
SELECT
    review_count,
    COUNT(*) AS number_of_orders

FROM vw_reviews_aggregated

GROUP BY review_count

ORDER BY review_count;

