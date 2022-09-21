/*Time spent on events*/
WITH  clean_tbl AS (
                  SELECT 
                     TIMESTAMP_MICROS(event_timestamp) timestamp,
                     event_date,
                     user_pseudo_id,
                     event_name,
                     purchase_revenue_in_usd
                  FROM 
                     `raw_events`
                  ORDER BY 
                     timestamp
                  ),
       prep_tbl AS (
                   SELECT 
                       *,
                       LEAD(timestamp) OVER(PARTITION BY user_pseudo_id ORDER BY timestamp, event_name DESC) lead_timestamp
                   FROM 
                      clean_tbl
                   ),
       interm_tbl AS (
                    SELECT
                       *,
                       TIMESTAMP_DIFF(lead_timestamp, timestamp, SECOND) duration
                    FROM 
                       prep_tbl
                    WHERE
                      (purchase_revenue_in_usd > 0 OR purchase_revenue_in_usd IS NULL)
                      AND timestamp <> lead_timestamp
                   )
SELECT 
   event_name,
   AVG(duration) avg_time_spent,
   STDDEV(duration) avg_stdev,
   COUNT(1) count
FROM 
   interm_tbl
WHERE
   duration <=1800
GROUP BY
   event_name
ORDER BY 
   avg_time_spent DESC