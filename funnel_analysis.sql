
-- E-COMMERCE FUNNEL & CONVERSION ANALYSIS
-- Data: marketing-analysis-501508.sql_practice.user_events
-- Window: trailing 30 days from the most recent event in the data

-- Business questions this file answers:
-- 1. Where in the funnel are we losing the most users?
-- 2. Which stage-to-stage transition has the worst conversion?
-- 3. Which traffic sources convert best, and which performs the worst?
-- 4. How long does it typically take a user to go from first view to purchase?
-- 5. What is this funnel actually worth in revenue terms?

-- Note: SAFE_DIVIDE() is used throughout instead of "/" so that the result returns
-- NULL instead of crashing the whole query.


-- Q1: Overall funnel volume by stage
-- Business question: How many distinct users reach each stage of the purchase funnel in the last 30 days?

WITH funnel_stages AS (
  SELECT
    COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS stage_1_views,
    COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS stage_2_cart,
    COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS stage_3_checkout,
    COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id END) AS stage_4_payment,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS stage_5_purchase
  FROM `marketing-analysis-501508.sql_practice.user_events`
  WHERE event_date >= (
    SELECT TIMESTAMP_SUB(MAX(event_date), INTERVAL 30 DAY)
    FROM `marketing-analysis-501508.sql_practice.user_events`
  )
)
SELECT * FROM funnel_stages;



-- Q2: Stage-to-stage conversion rates
-- Business question: Of the users who reach one stage, what percentage make it to the next? 
-- This shows exactly where the funnel leaks the most customers, which is more actionable
-- than an overall conversion rate alone.

WITH funnel_stages AS (
  SELECT
    COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS stage_1_views,
    COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS stage_2_cart,
    COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS stage_3_checkout,
    COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id END) AS stage_4_payment,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS stage_5_purchase
  FROM `marketing-analysis-501508.sql_practice.user_events`
  WHERE event_date >= (
    SELECT TIMESTAMP_SUB(MAX(event_date), INTERVAL 30 DAY)
    FROM `marketing-analysis-501508.sql_practice.user_events`
  )
)
SELECT
  stage_1_views,
  stage_2_cart,
  ROUND(SAFE_DIVIDE(stage_2_cart * 100, stage_1_views), 1) AS view_to_cart_rate_pct,
  stage_3_checkout,
  ROUND(SAFE_DIVIDE(stage_3_checkout * 100, stage_2_cart), 1) AS cart_to_checkout_rate_pct,
  stage_4_payment,
  ROUND(SAFE_DIVIDE(stage_4_payment * 100, stage_3_checkout), 1) AS checkout_to_payment_rate_pct,
  stage_5_purchase,
  ROUND(SAFE_DIVIDE(stage_5_purchase * 100, stage_1_views), 1) AS overall_conversion_rate_pct
FROM funnel_stages;



-- Q3: Funnel performance by traffic source
-- Business question: Which channels bring visitors who actually buy, versus channels that generate views but never convert?
-- This informs where marketing focus should shift.

WITH source_funnel AS (
  SELECT
    traffic_source,
    COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS views,
    COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS cart,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchases
  FROM `marketing-analysis-501508.sql_practice.user_events`
  WHERE event_date >= (
    SELECT TIMESTAMP_SUB(MAX(event_date), INTERVAL 30 DAY)
    FROM `marketing-analysis-501508.sql_practice.user_events`
  )
  GROUP BY traffic_source
)
SELECT
  traffic_source,
  views,
  ROUND(SAFE_DIVIDE(cart * 100, views), 1) AS view_to_cart_rate_pct,
  cart,
  ROUND(SAFE_DIVIDE(purchases * 100, cart), 1) AS cart_to_purchase_rate_pct,
  purchases,
  ROUND(SAFE_DIVIDE(purchases * 100, views), 1) AS view_to_purchase_rate_pct
FROM source_funnel
ORDER BY purchases DESC;



-- Q4: Time-to-conversion for users who purchased
-- Business question: How long does it take a converting user to move through the funnel? 
-- This tells us where in the user journey from start to end the user hesitates to move onto the next step and whether the
-- final purchase decision is impulsive or considered. This also tells the business to look into why it is happening and 
-- therefore what they can do about it.

WITH user_journey AS (
  SELECT
    user_id,
    MIN(CASE WHEN event_type = 'page_view' THEN event_date END) AS view_time,
    MIN(CASE WHEN event_type = 'add_to_cart' THEN event_date END) AS cart_time,
    MIN(CASE WHEN event_type = 'purchase' THEN event_date END) AS purchase_time
  FROM `marketing-analysis-501508.sql_practice.user_events`
  WHERE event_date >= (
    SELECT TIMESTAMP_SUB(MAX(event_date), INTERVAL 30 DAY)
    FROM `marketing-analysis-501508.sql_practice.user_events`
  )
  GROUP BY user_id
  HAVING MIN(CASE WHEN event_type = 'purchase' THEN event_date END) IS NOT NULL
)
SELECT
  COUNT(*) AS converted_users,
  ROUND(AVG(TIMESTAMP_DIFF(cart_time, view_time, MINUTE)), 2) AS avg_view_to_cart_minutes,
  ROUND(AVG(TIMESTAMP_DIFF(purchase_time, cart_time, MINUTE)), 2) AS avg_cart_to_purchase_minutes,
  ROUND(AVG(TIMESTAMP_DIFF(purchase_time, view_time, MINUTE)), 2) AS avg_total_journey_minutes
FROM user_journey;


-- Q5: Revenue impact of the funnel
-- Business question: What is this funnel worth? 
-- Translating the funnel into dollars (AOV, revenue per buyer, revenue per visitor) is what turns a conversion-rate exercise into
-- something a stakeholder will act on.

WITH revenue_funnel AS (
  SELECT
    COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS total_visitors,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS total_buyers,
    SUM(CASE WHEN event_type = 'purchase' THEN amount END) AS total_revenue,
    COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) AS total_orders
  FROM `marketing-analysis-501508.sql_practice.user_events`
  WHERE event_date >= (
    SELECT TIMESTAMP_SUB(MAX(event_date), INTERVAL 30 DAY)
    FROM `marketing-analysis-501508.sql_practice.user_events`
  )
)
SELECT
  total_visitors,
  total_buyers,
  total_revenue,
  total_orders,
  ROUND(SAFE_DIVIDE(total_revenue, total_orders), 2) AS avg_order_value,
  ROUND(SAFE_DIVIDE(total_revenue, total_buyers), 2) AS revenue_per_buyer,
  ROUND(SAFE_DIVIDE(total_revenue, total_visitors), 2) AS revenue_per_visitor
FROM revenue_funnel;
