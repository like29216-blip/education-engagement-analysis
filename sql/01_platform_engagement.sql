-- Online Education Platform | MySQL 5.7+ / 8.x compatible SQL
-- Source data: customer_engagement. Read sql/README.md for execution order.
USE customer_engagement;
SET SESSION sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- Business question: how much activity is observed, and when does it change?
CREATE OR REPLACE VIEW ce_platform_kpis AS
SELECT (SELECT COUNT(*) FROM student_info) AS registered_users,
 (SELECT COUNT(DISTINCT student_id) FROM ce_engagement) AS active_users,
 (SELECT COUNT(*) FROM ce_first_purchase) AS purchasers,
 (SELECT SUM(minutes_watched) FROM ce_learning) AS corrected_minutes,
 (SELECT COUNT(*) FROM student_certificates) AS certificates_issued;
CREATE OR REPLACE VIEW ce_daily_activity AS
SELECT date_engaged,paid,COUNT(DISTINCT student_id) AS active_users
FROM ce_engagement GROUP BY date_engaged,paid;
CREATE OR REPLACE VIEW ce_monthly_activity AS
SELECT DATE_FORMAT(date_engaged,'%Y-%m') AS activity_month,paid,COUNT(DISTINCT student_id) AS active_users
FROM ce_engagement GROUP BY DATE_FORMAT(date_engaged,'%Y-%m'),paid;
SELECT * FROM ce_platform_kpis;
SELECT * FROM ce_monthly_activity ORDER BY activity_month,paid;
-- Promotion timing is descriptive, without a causal counterfactual.
SELECT CASE WHEN date_engaged BETWEEN '2022-08-15' AND '2022-08-17' THEN 'free_days'
 ELSE 'prior_seven_days' END AS observation_window,
 COUNT(DISTINCT date_engaged) AS observed_days,COUNT(*)/COUNT(DISTINCT date_engaged) AS mean_daily_active
FROM ce_engagement WHERE date_engaged BETWEEN '2022-08-08' AND '2022-08-17'
GROUP BY observation_window;
