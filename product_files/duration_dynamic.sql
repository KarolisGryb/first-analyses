/*Duration dynamic daily*/
WITH  prep_tbl AS (
                  SELECT 
                     TIMESTAMP_MICROS(event_timestamp) timestamp,
                     user_pseudo_id,
                     event_name,
                     category,
                     operating_system,
                     browser,
                     country,
                     language,
                     purchase_revenue_in_usd,
                     COUNT(CASE WHEN event_name = 'purchase' THEN 1 END) OVER (PARTITION BY user_pseudo_id, event_date ORDER BY event_timestamp) purchase_order,
                     MIN(CASE WHEN event_name = 'session_start' THEN TIMESTAMP_MICROS(event_timestamp) END) OVER(PARTITION BY user_pseudo_id, event_date) start_timestamp
                  FROM 
                     `raw_events`
                  
                  ),
      data_tbl AS (
                  SELECT
                     *,
                     TIMESTAMP_DIFF(timestamp, start_timestamp, SECOND) duration_secs,
                  FROM 
                     prep_tbl
                  WHERE 
                     purchase_order = 1 
                     AND event_name = 'purchase' 
                     AND purchase_revenue_in_usd > 0
                     AND timestamp >  start_timestamp
                  ),
wo_outliers_tbl AS (
                   SELECT 
                      *
                   FROM 
                      data_tbl, 
                      (SELECT (AVG(duration_secs) + STDDEV(duration_secs)*1.96) outlier FROM data_tbl)
                   WHERE duration_secs < outlier
                  )
SELECT 
   DATE(timestamp) date,
   category,
   operating_system,
   browser,
   country,
   language,
   duration_secs
FROM 
   wo_outliers_tbl 
ORDER BY 
   timestamp