
-- Project 3: E-Commerce Operations Analysis
-- Phase 3.2E: Final Analytical View

CREATE OR REPLACE VIEW vw_ecommerce_analysis AS

SELECT
    -- 1. Order & Customer
    d.order_id,
    d.customer_unique_id,
    d.customer_city,
    d.customer_state,
    d.order_status,

    -- 2. Delivery
    d.order_purchase_timestamp,
    d.order_delivered_carrier_date,
    d.order_delivered_customer_date,
    d.order_estimated_delivery_date,
    d.delivery_status,
    d.delivery_timeliness,
    d.delivery_days,
    d.days_vs_estimate,

    -- 3. Data Quality
    d.purchase_to_carrier_quality,
    d.carrier_to_delivery_quality,
    d.purchase_to_delivery_quality,

    -- 4. Customer Reviews
    r.review_count,
    r.avg_review_score,
    r.min_review_score,
    r.max_review_score,
    r.negative_review_count,
    r.positive_review_count,

    -- 5. Order Items
    i.item_count,
    i.distinct_product_count,
    i.distinct_seller_count,
    i.items_value,
    i.freight_value,
    i.total_items_and_freight,

    -- 6. Payments
    p.payment_count,
    p.total_payment_value,
    p.payment_method_count,
    p.max_payment_installments

FROM vw_delivery_analysis d

LEFT JOIN vw_reviews_aggregated r
    ON d.order_id = r.order_id

LEFT JOIN vw_order_items_aggregated i
    ON d.order_id = i.order_id

LEFT JOIN vw_payments_aggregated p
    ON d.order_id = p.order_id;


-- Final Analytical View: Uniqueness Validation

SELECT
    COUNT(*) AS total_rows,

    COUNT(DISTINCT order_id)
        AS unique_orders,

    COUNT(*) - COUNT(DISTINCT order_id)
        AS duplicate_orders

FROM vw_ecommerce_analysis;


-- Financial Reconciliation after JOIN

SELECT
    'items_value' AS metric,
    (SELECT SUM(items_value)
     FROM vw_order_items_aggregated)
        AS source_total,
    (SELECT SUM(items_value)
     FROM vw_ecommerce_analysis)
        AS final_view_total

UNION ALL

SELECT
    'freight_value',
    (SELECT SUM(freight_value)
     FROM vw_order_items_aggregated),
    (SELECT SUM(freight_value)
     FROM vw_ecommerce_analysis)

UNION ALL

SELECT
    'payment_value',
    (SELECT SUM(total_payment_value)
     FROM vw_payments_aggregated),
    (SELECT SUM(total_payment_value)
     FROM vw_ecommerce_analysis);


-- Review Reconciliation

SELECT
    (SELECT SUM(review_count)
     FROM vw_reviews_aggregated)
        AS source_review_count,

    (SELECT SUM(review_count)
     FROM vw_ecommerce_analysis)
        AS final_review_count,

    (SELECT COUNT(*)
     FROM vw_ecommerce_analysis
     WHERE avg_review_score IS NOT NULL)
        AS orders_with_reviews;

        
SELECT
    order_id,
    customer_state,
    delivery_timeliness,
    delivery_days,
    avg_review_score,
    item_count,
    items_value,
    total_payment_value

FROM vw_ecommerce_analysis

ORDER BY order_id

LIMIT 10;

