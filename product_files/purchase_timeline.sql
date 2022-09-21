/*Purchase timeline*/
WITH  clean_tbl AS (
                  SELECT 
                     TIMESTAMP_MICROS(event_timestamp) timestamp,
                     event_date,
                     user_pseudo_id,
                     event_name,
                     COUNT(event_name) OVER (PARTITION BY user_pseudo_id, event_date, event_name ORDER BY TIMESTAMP_MICROS(event_timestamp)) start_order
                  FROM 
                     `raw_events`
                  WHERE 
                     event_name = 'session_start'
                     OR (event_name = 'purchase' AND purchase_revenue_in_usd > 0)
                  ),
       prep_tbl AS (
                   SELECT 
                       *,
                       LEAD(user_pseudo_id) OVER(ORDER BY user_pseudo_id, timestamp) lead_id,
                       LEAD(event_name) OVER(ORDER BY user_pseudo_id, timestamp) lead_event,
                       LEAD(timestamp) OVER(ORDER BY user_pseudo_id, timestamp) lead_timestamp
                   FROM 
                      clean_tbl
                   WHERE 
                      start_order = 1
                   ),
       calc_tbl AS (
                    SELECT
                       *,
                       CASE WHEN event_name = 'session_start' AND lead_event = 'purchase' AND user_pseudo_id = lead_id THEN TIMESTAMP_DIFF(lead_timestamp, timestamp, SECOND)
                            END AS duration_with_purchase
                    FROM prep_tbl
                   )
SELECT 
   duration_with_purchase 
FROM 
   calc_tbl  
WHERE 
   duration_with_purchase IS NOT null
   AND duration_with_purchase <= 64800 
ORDER BY 
   timestamp
