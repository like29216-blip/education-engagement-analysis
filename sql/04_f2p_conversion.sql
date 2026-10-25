-- Online Education Platform | MySQL 5.7+ / 8.x compatible SQL
-- Source data: customer_engagement. Read sql/README.md for execution order.
USE customer_engagement;
SET SESSION sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- Assignment: any purchase record, including refunds and registration-day purchases.
-- Buyers: registration through FIRST purchase day INCLUSIVE. Nonbuyers: through cutoff.
CREATE OR REPLACE VIEW ce_f2p_minutes AS
SELECT s.student_id,s.date_registered,IF(p.first_purchase IS NULL,0,1) AS f2p,
 ROUND(COALESCE(SUM(l.minutes_watched),0),2) AS total_minutes_watched
FROM student_info s LEFT JOIN ce_first_purchase p ON p.student_id=s.student_id
LEFT JOIN student_learning l ON l.student_id=s.student_id
 AND l.date_watched BETWEEN s.date_registered AND COALESCE(p.first_purchase,'2022-10-31')
GROUP BY s.student_id,s.date_registered,p.first_purchase;
CREATE OR REPLACE VIEW ce_f2p AS
SELECT student_id,date_registered,f2p,total_minutes_watched,
CASE WHEN total_minutes_watched=0 THEN '[0]'
 WHEN total_minutes_watched<=5 THEN '(0, 5]'
 WHEN total_minutes_watched<=10 THEN '(5, 10]'
 WHEN total_minutes_watched<=15 THEN '(10, 15]'
 WHEN total_minutes_watched<=20 THEN '(15, 20]'
 WHEN total_minutes_watched<=25 THEN '(20, 25]'
 WHEN total_minutes_watched<=30 THEN '(25, 30]'
 WHEN total_minutes_watched<=40 THEN '(30, 40]'
 WHEN total_minutes_watched<=50 THEN '(40, 50]'
 WHEN total_minutes_watched<=60 THEN '(50, 60]'
 WHEN total_minutes_watched<=70 THEN '(60, 70]'
 WHEN total_minutes_watched<=80 THEN '(70, 80]'
 WHEN total_minutes_watched<=90 THEN '(80, 90]'
 WHEN total_minutes_watched<=100 THEN '(90, 100]'
 WHEN total_minutes_watched<=110 THEN '(100, 110]'
 WHEN total_minutes_watched<=120 THEN '(110, 120]'
 WHEN total_minutes_watched<=240 THEN '(120, 240]'
 WHEN total_minutes_watched<=480 THEN '(240, 480]'
 WHEN total_minutes_watched<=1000 THEN '(480, 1000]'
 WHEN total_minutes_watched<=2000 THEN '(1000, 2000]'
 WHEN total_minutes_watched<=3000 THEN '(2000, 3000]'
 WHEN total_minutes_watched<=4000 THEN '(3000, 4000]'
 WHEN total_minutes_watched<=6000 THEN '(4000, 6000]' ELSE '6000+' END AS buckets FROM ce_f2p_minutes;
CREATE OR REPLACE VIEW ce_f2p_summary AS
SELECT buckets,COUNT(*) AS learners,SUM(f2p) AS purchasers,SUM(f2p)/COUNT(*) AS purchase_incidence,
 MIN(total_minutes_watched) AS min_minutes
FROM ce_f2p GROUP BY buckets;
-- A separately labelled equal-follow-up extension: whole Jan-Sep cohorts, days 0-29.
CREATE OR REPLACE VIEW ce_conversion_30day AS
SELECT DATE_FORMAT(s.date_registered,'%Y-%m') AS registration_month,COUNT(*) AS registrations,
 SUM(CASE WHEN p.first_purchase<DATE_ADD(s.date_registered,INTERVAL 30 DAY) THEN 1 ELSE 0 END) AS purchasers_30day,
 SUM(CASE WHEN p.first_purchase<DATE_ADD(s.date_registered,INTERVAL 30 DAY) THEN 1 ELSE 0 END)/COUNT(*) AS purchase_incidence_30day
FROM student_info s LEFT JOIN ce_first_purchase p ON p.student_id=s.student_id
WHERE DATE_ADD(LAST_DAY(s.date_registered),INTERVAL 29 DAY)<='2022-10-31'
GROUP BY DATE_FORMAT(s.date_registered,'%Y-%m');
SELECT * FROM ce_f2p_summary ORDER BY min_minutes;
SELECT * FROM ce_conversion_30day ORDER BY registration_month;
