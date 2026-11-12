
-- Project 3: E-Commerce Operations Analysis
-- Phase 3.5A: Product Category Performance

WITH category_orders AS (
    SELECT
        i.order_id,

        COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'unknown'
        ) AS product_category,

        SUM(i.price) AS category_items_value,

        COUNT(*) AS category_item_count

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

category_performance AS (
    SELECT
        c.product_category,

        COUNT(*) AS orders_with_category,

        SUM(c.category_item_count) AS items_sold,

        SUM(c.category_items_value) AS items_value,

        COUNT(*) FILTER (
            WHERE e.delivery_timeliness IN ('ON_TIME', 'LATE')
        ) AS eligible_orders,

        COUNT(*) FILTER (
            WHERE e.delivery_timeliness = 'LATE'
        ) AS late_orders,

        ROUND(
            AVG(e.avg_review_score),
            2
        ) AS avg_review_score

    FROM category_orders c

    JOIN vw_ecommerce_analysis e
        ON c.order_id = e.order_id

    GROUP BY c.product_category
)

SELECT
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

    avg_review_score

FROM category_performance

ORDER BY items_value DESC;


-- Category Items Value Reconciliation

WITH category_totals AS (
    SELECT
        COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'unknown'
        ) AS product_category,

        SUM(i.price) AS items_value

    FROM olist_order_items_dataset i

    LEFT JOIN olist_products_dataset p
        ON i.product_id = p.product_id

    LEFT JOIN product_category_name_translation t
        ON p.product_category_name =
           t.product_category_name

    GROUP BY 1
)

SELECT
    (
        SELECT SUM(price)
        FROM olist_order_items_dataset
    ) AS source_items_value,

    (
        SELECT SUM(items_value)
        FROM category_totals
    ) AS category_items_value;


-- Orders with Multiple Product Categories

WITH order_categories AS (
    SELECT
        i.order_id,

        COUNT(
            DISTINCT COALESCE(
                t.product_category_name_english,
                p.product_category_name,
                'unknown'
            )
        ) AS category_count

    FROM olist_order_items_dataset i

    LEFT JOIN olist_products_dataset p
        ON i.product_id = p.product_id

    LEFT JOIN product_category_name_translation t
        ON p.product_category_name =
           t.product_category_name

    GROUP BY i.order_id
)

SELECT
    COUNT(*) AS orders_with_items,

    COUNT(*) FILTER (
        WHERE category_count > 1
    ) AS multi_category_orders

FROM order_categories;


-- Product Category Sample Size Check

WITH category_orders AS (
    SELECT DISTINCT
        i.order_id,
        COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'unknown'
        ) AS product_category

    FROM olist_order_items_dataset i

    LEFT JOIN olist_products_dataset p
        ON i.product_id = p.product_id

    LEFT JOIN product_category_name_translation t
        ON p.product_category_name =
           t.product_category_name
)

SELECT
    c.product_category,

    COUNT(*) AS eligible_orders

FROM category_orders c

JOIN vw_ecommerce_analysis e
    ON c.order_id = e.order_id

WHERE e.delivery_timeliness IN ('ON_TIME', 'LATE')

GROUP BY c.product_category

HAVING COUNT(*) < 100

ORDER BY eligible_orders;
