-- Online Education Platform | MySQL 5.7+ / 8.x compatible SQL
-- Source data: customer_engagement. Read sql/README.md for execution order.
USE customer_engagement;
SET SESSION sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- Per-watching-learner averages, not per registration; same person can appear under both statuses.
CREATE OR REPLACE VIEW ce_content_summary AS
SELECT paid,COUNT(DISTINCT student_id) AS watching_learners,ROUND(SUM(minutes_watched),2) AS minutes_watched,
 ROUND(SUM(minutes_watched)/COUNT(DISTINCT student_id),2) AS minutes_per_watching_learner
FROM ce_learning GROUP BY paid;
CREATE OR REPLACE VIEW ce_content_monthly AS
SELECT DATE_FORMAT(date_watched,'%Y-%m') AS watch_month,paid,COUNT(DISTINCT student_id) AS watching_learners,
 ROUND(SUM(minutes_watched),2) AS minutes_watched,
 ROUND(SUM(minutes_watched)/COUNT(DISTINCT student_id),2) AS minutes_per_watching_learner
FROM ce_learning GROUP BY DATE_FORMAT(date_watched,'%Y-%m'),paid;
-- Assignment simplification: first-to-last subscription SPAN, with gaps included.
CREATE OR REPLACE VIEW ce_subscription_dates AS
SELECT student_id,MIN(date_start) AS first_day,LEAST(MAX(date_end),'2022-10-31') AS last_day
FROM ce_purchases GROUP BY student_id;
CREATE OR REPLACE VIEW ce_subscription_minutes AS
SELECT d.student_id,i.date_registered,ROUND(COALESCE(SUM(l.minutes_watched),0),2) AS total_minutes_watched,
 DATEDIFF(d.last_day,d.first_day) AS num_paid_days
FROM ce_subscription_dates d JOIN student_info i ON i.student_id=d.student_id
LEFT JOIN student_learning l ON l.student_id=d.student_id AND l.date_watched BETWEEN d.first_day AND d.last_day
GROUP BY d.student_id,i.date_registered,d.first_day,d.last_day;
SELECT * FROM ce_content_summary ORDER BY paid;
SELECT * FROM ce_content_monthly ORDER BY watch_month,paid;

CREATE OR REPLACE VIEW ce_subscription_span AS
SELECT student_id,date_registered,total_minutes_watched,num_paid_days,
CASE WHEN total_minutes_watched=0 THEN '[0]'
 WHEN total_minutes_watched<=30 THEN '(0, 30]'
 WHEN total_minutes_watched<=60 THEN '(30, 60]'
 WHEN total_minutes_watched<=120 THEN '(60, 120]'
 WHEN total_minutes_watched<=240 THEN '(120, 240]'
 WHEN total_minutes_watched<=480 THEN '(240, 480]'
 WHEN total_minutes_watched<=1000 THEN '(480, 1000]'
 WHEN total_minutes_watched<=2000 THEN '(1000, 2000]'
 WHEN total_minutes_watched<=3000 THEN '(2000, 3000]'
 WHEN total_minutes_watched<=4000 THEN '(3000, 4000]'
 WHEN total_minutes_watched<=6000 THEN '(4000, 6000]' ELSE '6000+' END AS buckets FROM ce_subscription_minutes;
