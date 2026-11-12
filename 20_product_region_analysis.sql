
-- Project 3: E-Commerce Operations Analysis
-- Phase 3.5D: Product × Region Performance

CREATE OR REPLACE VIEW vw_product_region_performance AS
WITH category_orders AS (
    SELECT
        i.order_id,

        COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'unknown'
        ) AS product_category,

        COUNT(*) AS item_count,

        SUM(i.price) AS items_value

    FROM olist_order_items_dataset i

    LEFT JOIN olist_products_dataset p
        ON i.product_id = p.product_id

    LEFT JOIN product_category_name_translation t
        ON p.product_category_name =
           t.product_category_name

    GROUP BY
        i.order_id,
        COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'unknown'
        )
),

product_region AS (
    SELECT
        e.customer_state,
        c.product_category,

        COUNT(*) AS orders_with_category,

        SUM(c.item_count) AS items_sold,

        SUM(c.items_value) AS items_value,

        COUNT(*) FILTER (
            WHERE e.delivery_timeliness IN ('ON_TIME', 'LATE')
        ) AS eligible_orders,

        COUNT(*) FILTER (
            WHERE e.delivery_timeliness = 'LATE'
        ) AS late_orders,

        COUNT(*) FILTER (
            WHERE e.avg_review_score IS NOT NULL
        ) AS orders_with_reviews,

        ROUND(
            AVG(e.avg_review_score),
            2
        ) AS avg_review_score

    FROM category_orders c

    JOIN vw_ecommerce_analysis e
        ON c.order_id = e.order_id

    WHERE e.customer_state IS NOT NULL

    GROUP BY
        e.customer_state,
        c.product_category
)

SELECT
    customer_state,
    product_category,
    orders_with_category,
    items_sold,
    items_value,
    eligible_orders,
    late_orders,

    ROUND(
        100.0 * late_orders
        / NULLIF(eligible_orders, 0),
        2
    ) AS late_rate_pct,

    orders_with_reviews,
    avg_review_score

FROM product_region

ORDER BY
    items_value DESC NULLS LAST;


-- Product × Region Priority Analysis

SELECT
    customer_state,
    product_category,
    eligible_orders,
    late_orders,
    late_rate_pct,
    items_value,
    avg_review_score

FROM vw_product_region_performance

WHERE eligible_orders >= 100

ORDER BY
    late_rate_pct DESC,
    late_orders DESC;


-- Product × Region Financial Reconciliation

SELECT
    (
        SELECT SUM(price)
        FROM olist_order_items_dataset
    ) AS source_items_value,

    (
        SELECT SUM(items_value)
        FROM vw_product_region_performance
    ) AS product_region_items_value;


-- Product × Region Uniqueness Check

SELECT
    COUNT(*) AS total_rows,

    COUNT(DISTINCT (
        customer_state,
        product_category
    )) AS unique_combinations,

    COUNT(*) - COUNT(DISTINCT (
        customer_state,
        product_category
    )) AS duplicate_combinations

FROM vw_product_region_performance;

-- Product × Region Sample Size

SELECT
    COUNT(*) AS total_combinations,

    COUNT(*) FILTER (
        WHERE eligible_orders < 20
    ) AS combinations_below_20,

    COUNT(*) FILTER (
        WHERE eligible_orders BETWEEN 20 AND 99
    ) AS combinations_20_to_99,

    COUNT(*) FILTER (
        WHERE eligible_orders >= 100
    ) AS combinations_100_plus,

    COUNT(*) FILTER (
        WHERE eligible_orders = 0
    ) AS combinations_without_eligible_orders

FROM vw_product_region_performance;

