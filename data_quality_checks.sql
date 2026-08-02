--Duplicate events

SELECT
  event_id,
  COUNT(*) AS occurrences
FROM `marketing-analysis-501508.sql_practice.user_events`
GROUP BY event_id
HAVING COUNT(*) > 1;

--Nulls in critical fields

SELECT
  COUNTIF(user_id IS NULL) AS null_user_id,
  COUNTIF(event_type IS NULL) AS null_event_type,
  COUNTIF(event_date IS NULL) AS null_event_date,
  COUNTIF(traffic_source IS NULL) AS null_traffic_source
FROM `marketing-analysis-501508.sql_practice.user_events`;

--Unexpected event_type values

SELECT
  event_type,
  COUNT(*) AS row_count
FROM `marketing-analysis-501508.sql_practice.user_events`
GROUP BY event_type
ORDER BY row_count DESC;

--Date range 

SELECT
  MIN(event_date) AS earliest_event,
  MAX(event_date) AS latest_event,
  DATE_DIFF(DATE(MAX(event_date)), DATE(MIN(event_date)), DAY) AS days_covered,
  COUNT(DISTINCT DATE(event_date)) AS distinct_days_with_data
FROM `marketing-analysis-501508.sql_practice.user_events`;

--Traffic sources 

SELECT
  traffic_source,
  COUNT(*) AS row_count
FROM `marketing-analysis-501508.sql_practice.user_events`
GROUP BY traffic_source
ORDER BY row_count DESC;
