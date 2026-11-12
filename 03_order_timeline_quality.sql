 -- Project 3: E-Commerce Operations Analysis
-- Order Timeline Data Quality View

CREATE OR REPLACE VIEW public.vw_order_timeline_quality AS
 SELECT order_id, 
    order_status,
    order_purchase_timestamp,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
        CASE
            WHEN order_delivered_carrier_date IS NULL OR order_purchase_timestamp IS NULL THEN 'MISSING'::text
            WHEN order_delivered_carrier_date < order_purchase_timestamp THEN 'INVALID'::text
            ELSE 'VALID'::text
        END AS purchase_to_carrier_quality,
        CASE
            WHEN order_delivered_carrier_date IS NULL OR order_delivered_customer_date IS NULL THEN 'MISSING'::text
            WHEN order_delivered_customer_date < order_delivered_carrier_date THEN 'INVALID'::text
            ELSE 'VALID'::text
        END AS carrier_to_delivery_quality,
        CASE
            WHEN order_purchase_timestamp IS NULL OR order_delivered_customer_date IS NULL THEN 'MISSING'::text
            WHEN order_delivered_customer_date < order_purchase_timestamp THEN 'INVALID'::text
            ELSE 'VALID'::text
        END AS purchase_to_delivery_quality
   FROM olist_orders_dataset;