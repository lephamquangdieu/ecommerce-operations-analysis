-- Phase 3.2D.1: Order Items Aggregation

CREATE OR REPLACE VIEW vw_order_items_aggregated AS

SELECT
    order_id,

    COUNT(*) AS item_count,

    COUNT(DISTINCT product_id)
        AS distinct_product_count,

    COUNT(DISTINCT seller_id)
        AS distinct_seller_count,

    SUM(price) AS items_value,

    SUM(freight_value) AS freight_value,

    SUM(price + freight_value)
        AS total_items_and_freight

FROM olist_order_items_dataset

GROUP BY order_id;


-- Phase 3.2D.2: Payment Aggregation

CREATE OR REPLACE VIEW vw_payments_aggregated AS

SELECT
    order_id,

    COUNT(*) AS payment_count,

    SUM(payment_value)
        AS total_payment_value,

    COUNT(DISTINCT payment_type)
        AS payment_method_count,

    MAX(payment_installments)
        AS max_payment_installments

FROM olist_order_payments_dataset

GROUP BY order_id;


-- Validate uniqueness

SELECT
    'order_items' AS source,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(*) - COUNT(DISTINCT order_id)
        AS duplicate_orders
FROM vw_order_items_aggregated

UNION ALL

SELECT
    'payments',
    COUNT(*),
    COUNT(DISTINCT order_id),
    COUNT(*) - COUNT(DISTINCT order_id)
FROM vw_payments_aggregated;


-- Reconcile item and payment totals

SELECT
    'items_value' AS metric,
    (SELECT SUM(price)
     FROM olist_order_items_dataset) AS source_total,
    (SELECT SUM(items_value)
     FROM vw_order_items_aggregated) AS aggregated_total

UNION ALL

SELECT
    'freight_value',
    (SELECT SUM(freight_value)
     FROM olist_order_items_dataset),
    (SELECT SUM(freight_value)
     FROM vw_order_items_aggregated)

UNION ALL

SELECT
    'payment_value',
    (SELECT SUM(payment_value)
     FROM olist_order_payments_dataset),
    (SELECT SUM(total_payment_value)
     FROM vw_payments_aggregated);

--    
SELECT
    i.order_id,
    i.item_count,
    i.items_value,
    i.freight_value,
    i.total_items_and_freight,
    p.payment_count,
    p.total_payment_value

FROM vw_order_items_aggregated i

LEFT JOIN vw_payments_aggregated p
    ON i.order_id = p.order_id

ORDER BY i.item_count DESC, i.order_id

LIMIT 10;



