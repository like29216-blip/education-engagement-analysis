-- Online Education Platform | MySQL 5.7+ / 8.x compatible SQL
-- Source data: customer_engagement. Read sql/README.md for execution order.
USE customer_engagement;
SET SESSION sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- Activation is EVER engaged by cutoff, NOT necessarily active in registration month.
CREATE OR REPLACE VIEW ce_activation AS
SELECT DATE_FORMAT(date_registered,'%Y-%m') AS registration_month,
 COUNT(*) AS registrations,SUM(student_onboarded) AS ever_engaged,
 SUM(student_onboarded)/COUNT(*) AS activation_rate
FROM ce_onboarding GROUP BY DATE_FORMAT(date_registered,'%Y-%m');

-- Historical status-entry cohorts: each learner may enter free AND paid cohorts.
CREATE OR REPLACE VIEW ce_status_entry AS
SELECT student_id,paid,MIN(date_engaged) AS cohort FROM ce_engagement GROUP BY student_id,paid;
CREATE OR REPLACE VIEW ce_engagement_cohorts AS
SELECT e.student_id,e.date_engaged,e.paid,c.cohort,
 TIMESTAMPDIFF(MONTH,c.cohort,e.date_engaged) AS period
FROM ce_engagement e JOIN ce_status_entry c ON e.student_id=c.student_id AND e.paid=c.paid;
CREATE OR REPLACE VIEW ce_status_sizes AS
SELECT DATE_FORMAT(cohort,'%Y-%m') AS cohort_month,paid,COUNT(*) AS cohort_size,MAX(cohort) AS latest_entry
FROM ce_status_entry GROUP BY DATE_FORMAT(cohort,'%Y-%m'),paid;
CREATE OR REPLACE VIEW ce_status_counts AS
SELECT DATE_FORMAT(cohort,'%Y-%m') AS cohort_month,paid,period,COUNT(DISTINCT student_id) AS retained_users
FROM ce_engagement_cohorts GROUP BY DATE_FORMAT(cohort,'%Y-%m'),paid,period;
CREATE OR REPLACE VIEW ce_status_retention AS
SELECT s.cohort_month,s.paid,n.period,s.cohort_size,
 COALESCE(c.retained_users,0) AS retained_users,
 COALESCE(c.retained_users,0)/s.cohort_size AS observed_retention,
 -- Full elapsed-month interval for ALL members must end before the observation cutoff.
 TIMESTAMPDIFF(MONTH,s.latest_entry,'2022-11-01')>n.period AS full_window_observed
FROM ce_status_sizes s CROSS JOIN ce_periods n
LEFT JOIN ce_status_counts c ON c.cohort_month=s.cohort_month AND c.paid=s.paid AND c.period=n.period
WHERE n.period<=TIMESTAMPDIFF(MONTH,STR_TO_DATE(CONCAT(s.cohort_month,'-01'),'%Y-%m-%d'),'2022-10-31');

-- Separately labelled extension: registration calendar cohorts; NOT a replacement for Tableau.
CREATE OR REPLACE VIEW ce_registration_sizes AS
SELECT DATE_FORMAT(date_registered,'%Y-%m') AS cohort_month,COUNT(*) AS cohort_size
FROM student_info GROUP BY DATE_FORMAT(date_registered,'%Y-%m');
CREATE OR REPLACE VIEW ce_registration_counts AS
SELECT DATE_FORMAT(s.date_registered,'%Y-%m') AS cohort_month,
 PERIOD_DIFF(EXTRACT(YEAR_MONTH FROM e.date_engaged),EXTRACT(YEAR_MONTH FROM s.date_registered)) AS period,
 COUNT(DISTINCT e.student_id) AS active_users
FROM student_info s JOIN ce_engagement e ON e.student_id=s.student_id
 AND e.date_engaged>=s.date_registered
GROUP BY DATE_FORMAT(s.date_registered,'%Y-%m'),PERIOD_DIFF(EXTRACT(YEAR_MONTH FROM e.date_engaged),EXTRACT(YEAR_MONTH FROM s.date_registered));
CREATE OR REPLACE VIEW ce_registration_retention AS
SELECT s.cohort_month,n.period,s.cohort_size,
 COALESCE(c.active_users,0) AS active_users,COALESCE(c.active_users,0)/s.cohort_size AS retention_rate
FROM ce_registration_sizes s CROSS JOIN ce_periods n
LEFT JOIN ce_registration_counts c ON s.cohort_month=c.cohort_month AND n.period=c.period
WHERE n.period<=PERIOD_DIFF(202210,REPLACE(s.cohort_month,'-',''));
SELECT * FROM ce_activation ORDER BY registration_month;
SELECT * FROM ce_status_retention ORDER BY paid,cohort_month,period;
SELECT * FROM ce_registration_retention ORDER BY cohort_month,period;
