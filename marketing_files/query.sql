WITH  clean_tbl AS (
                  SELECT 
                     TIMESTAMP_MICROS(event_timestamp) timestamp,
                     user_pseudo_id,
                     event_name,
                     purchase_revenue_in_usd
                  FROM 
                     `raw_events`
                  ORDER BY
                     timestamp
                  ),
       temp_tbl AS ( --For bounce rate calc remove identical timestamps (for ex 'page_view', 'first_visit', 'session_start' usually has the same timestamp)
                   SELECT 
                       *,
                       LEAD(timestamp) OVER(PARTITION BY user_pseudo_id ORDER BY timestamp) temp_lead_timestamp
                   FROM
                      clean_tbl
                   ),
      prep_tbl AS (
                    SELECT
                     timestamp,
                     user_pseudo_id,
                     event_name,
                     LEAD(timestamp) OVER(PARTITION BY user_pseudo_id ORDER BY timestamp) lead_timestamp,
                     LAG(timestamp) OVER(PARTITION BY user_pseudo_id ORDER BY timestamp) lag_timestamp,
                     LEAD(event_name) OVER(PARTITION BY user_pseudo_id ORDER BY timestamp) lead_event,
                     purchase_revenue_in_usd
                    FROM 
                       temp_tbl
                    WHERE
                       timestamp <> temp_lead_timestamp
                       OR temp_lead_timestamp IS NULL
                       OR event_name = 'purchase'
                   ),
   session_tbl AS (
                    SELECT
                       *,
                       CASE WHEN TIMESTAMP_DIFF(timestamp, lag_timestamp, SECOND) > 677 --Time before new session assigned. It is defined by taking avg + 1.96*stddev of longest event 
                              OR lag_timestamp IS NULL                                  --in extra querry from product analyst project which calculates avg duration of each event type
                            THEN 1 ELSE 0 END AS if_new_session,
                       CASE WHEN TIMESTAMP_DIFF(lead_timestamp, timestamp, SECOND) <= 677
                            THEN TIMESTAMP_DIFF(lead_timestamp, timestamp, SECOND) END AS duration
                    FROM
                      prep_tbl                                                       
                   ),
    parameter_tbl AS (
                    SELECT
                       *,
                       SUM(if_new_session) OVER(PARTITION BY user_pseudo_id ORDER BY timestamp) session_no,
                       CASE WHEN if_new_session = 1 AND duration IS NULL
                            THEN 1 END AS single_event,
                       CASE WHEN event_name = 'purchase' 
                            THEN 1 END AS if_purchase_made
                    FROM
                      session_tbl
                   ),
   user_stats_tbl AS (--Calculating measurements for sessions and daily
                      SELECT
                         timestamp,
                         DATE_TRUNC(timestamp, DAY) day,
                         EXTRACT(DAYOFWEEK FROM timestamp) weekday,
                         user_pseudo_id id,
                         if_new_session,
                         session_no sess_no,
                         SUM(duration) OVER(PARTITION BY user_pseudo_id, session_no) sess_duration,
                         COUNT(event_name) OVER(PARTITION BY user_pseudo_id, session_no) clicks_per_sess,
                         AVG(if_purchase_made) OVER(PARTITION BY user_pseudo_id, session_no) if_purchase_per_sess,
                         SUM(purchase_revenue_in_usd) OVER(PARTITION BY user_pseudo_id, session_no) purchase_revenue_in_usd,
                         SUM(if_new_session) OVER(PARTITION BY user_pseudo_id, DATE_TRUNC(timestamp, DAY) ORDER BY timestamp) sess_per_day,
                         SUM(duration) OVER(PARTITION BY user_pseudo_id, DATE_TRUNC(timestamp, DAY)) duration_per_day,
                         COUNT(event_name) OVER(PARTITION BY user_pseudo_id, DATE_TRUNC(timestamp, DAY)) clicks_per_day,
                         AVG(if_purchase_made) OVER(PARTITION BY user_pseudo_id, DATE_TRUNC(timestamp, DAY)) if_purchase_per_day,
                         AVG(single_event) OVER(PARTITION BY user_pseudo_id, DATE_TRUNC(timestamp, DAY)) if_bounce_per_day,
                         SUM(purchase_revenue_in_usd) OVER(PARTITION BY user_pseudo_id, DATE_TRUNC(timestamp, DAY)) purchase_revenue_per_day
                      FROM
                         parameter_tbl
                     ),
campaign_init_tbl AS (--Preparation of campaign table
                       SELECT
                          DATE_TRUNC(TIMESTAMP_MICROS(event_timestamp), DAY) day,
                          user_pseudo_id id,
                          campaign,
                          COUNT(user_pseudo_id) OVER(PARTITION BY user_pseudo_id, DATE_TRUNC(TIMESTAMP_MICROS(event_timestamp), DAY) ORDER BY TIMESTAMP_MICROS(event_timestamp)) c_count
                       FROM
                         `raw_events`
                       WHERE
                         campaign IN ('Data Share Promo', 'NewYear_V1', 'BlackFriday_V1', 'NewYear_V2', 'BlackFriday_V2', 'Holiday_V2', 'Holiday_V1',
                                      '(referral)', '(organic)', '(direct)') 
                      ),
      campaign_tbl AS (--Taking only first channel of the day because same user can have several different on the same day
                      SELECT
                        *
                      FROM
                        campaign_init_tbl
                      WHERE
                         c_count = 1
                      ),
          full_tbl AS (--Main stats table
                       SELECT
                          user_stats_tbl.*,
                          campaign_tbl.campaign
                       FROM
                          user_stats_tbl
                       LEFT JOIN
                          campaign_tbl
                       ON
                         user_stats_tbl.day = campaign_tbl.day
                         AND user_stats_tbl.id = campaign_tbl.id
                       WHERE
                         if_new_session = 1
                      ),
   task_results_tbl AS (--Resultant table of given task
                        SELECT
                           campaign,
                           weekday,
                           ROUND(AVG(duration_per_day), 0) avg_duration,
                           COUNT(duration_per_day) sess_count
                        FROM 
                           full_tbl
                        WHERE
                           sess_per_day = 1
                        GROUP BY
                           campaign, weekday
                        ORDER BY
                           campaign
                       ),
     path_extra_tbl AS (--Resultant table of purchases per session count
                         SELECT
                            sess_no,
                            CASE WHEN campaign IN ('Data Share Promo', 'NewYear_V1', 'BlackFriday_V1', 'NewYear_V2', 'BlackFriday_V2', 'Holiday_V2', 'Holiday_V1')
                                 THEN 'campaign' 
                                 ELSE campaign END AS user_type,
                            SUM(if_purchase_per_sess) conversions,
                            ROUND(AVG(purchase_revenue_in_usd), 0) avg_purchase,
                            COUNT(1) count
                         FROM
                            full_tbl
                         GROUP BY
                            sess_no, user_type
                         ORDER BY
                            sess_no, user_type
                        ),
  timeline_extra_tbl AS (--Resultant timeline of daily metrics
                         SELECT
                            day,
                            ROUND(AVG(duration_per_day), 0) avg_duration,
                            ROUND(AVG(clicks_per_day), 0) avg_clicks,
                            SUM(if_purchase_per_day) conversions,
                            ROUND(AVG(purchase_revenue_per_day), 0) avg_purchase,
                            SUM(CASE WHEN duration_per_day IS NULL
                                 THEN if_bounce_per_day END) bounce_count,
                            COUNT(1) user_count
                         FROM
                            full_tbl
                         WHERE
                            sess_per_day = 1
                         GROUP BY
                            day
                         ORDER BY
                            day
                        )
SELECT 
   *
FROM 
   task_results_tbl