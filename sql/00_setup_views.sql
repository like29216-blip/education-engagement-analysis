-- Online Education Platform | MySQL 5.7+ / 8.x compatible SQL
-- Source data: customer_engagement. Read sql/README.md for execution order.
USE customer_engagement;
SET SESSION sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- Add only derived views/indexes in your LOCAL imported database; original rows are untouched.
-- Idempotent analytical indexes avoid quadratic joins on the supplied unindexed foreign keys.
SET @index_ddl = IF(EXISTS(SELECT 1 FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='student_learning' AND index_name='ce_student_learning'),'SELECT 1', 'CREATE INDEX ce_student_learning ON student_learning(student_id,date_watched)');
PREPARE index_stmt FROM @index_ddl; EXECUTE index_stmt; DEALLOCATE PREPARE index_stmt;
SET @index_ddl = IF(EXISTS(SELECT 1 FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='student_engagement' AND index_name='ce_student_engagement'),'SELECT 1', 'CREATE INDEX ce_student_engagement ON student_engagement(student_id,date_engaged)');
PREPARE index_stmt FROM @index_ddl; EXECUTE index_stmt; DEALLOCATE PREPARE index_stmt;
SET @index_ddl = IF(EXISTS(SELECT 1 FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='student_purchases' AND index_name='ce_student_purchases'),'SELECT 1', 'CREATE INDEX ce_student_purchases ON student_purchases(student_id,date_purchased)');
PREPARE index_stmt FROM @index_ddl; EXECUTE index_stmt; DEALLOCATE PREPARE index_stmt;
SET @index_ddl = IF(EXISTS(SELECT 1 FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='student_exams' AND index_name='ce_student_exams'),'SELECT 1', 'CREATE INDEX ce_student_exams ON student_exams(student_id,exam_id)');
PREPARE index_stmt FROM @index_ddl; EXECUTE index_stmt; DEALLOCATE PREPARE index_stmt;

-- Preserve the exact historical entitlement rule for continuity with the supplied Tableau.
-- This is NOT the dictionary's fixed 30/90/365-day rule; sensitivity view is separate.
CREATE OR REPLACE VIEW ce_purchases AS
SELECT purchase_id,student_id,purchase_type,date_purchased AS date_start,
 COALESCE(date_refunded,
   DATE_ADD(MAKEDATE(YEAR(date_purchased),DAY(date_purchased)),
     INTERVAL (MONTH(date_purchased)+CASE purchase_type WHEN 0 THEN 0 WHEN 1 THEN 2 WHEN 2 THEN 11 END) MONTH)
 ) AS date_end
FROM student_purchases;

CREATE OR REPLACE VIEW ce_purchases_fixed_days AS
SELECT purchase_id,student_id,purchase_type,date_purchased AS date_start,
 LEAST(COALESCE(date_refunded,'9999-12-31'),
 DATE_ADD(date_purchased, INTERVAL (CASE purchase_type WHEN 0 THEN 30 WHEN 1 THEN 90 WHEN 2 THEN 365 END - 1) DAY)) AS date_end
FROM student_purchases;

CREATE OR REPLACE VIEW ce_first_purchase AS
SELECT student_id, MIN(date_purchased) AS first_purchase
FROM student_purchases GROUP BY student_id;

-- Includes the one preregistration anomaly to preserve historical exports; flagged in QA.
CREATE OR REPLACE VIEW ce_engagement AS
SELECT e.student_id,e.date_engaged,
 MAX(CASE WHEN e.date_engaged BETWEEN p.date_start AND p.date_end THEN 1 ELSE 0 END) AS paid
FROM student_engagement e LEFT JOIN ce_purchases p ON e.student_id=p.student_id
GROUP BY e.student_id,e.date_engaged;

-- Aggregate course rows BEFORE attaching subscription status: no loss or multiplication.
CREATE OR REPLACE VIEW ce_daily_minutes AS
SELECT student_id,date_watched,ROUND(SUM(minutes_watched),2) AS minutes_watched
FROM student_learning GROUP BY student_id,date_watched;
CREATE OR REPLACE VIEW ce_learning AS
SELECT l.student_id,l.date_watched,l.minutes_watched,
 MAX(CASE WHEN l.date_watched BETWEEN p.date_start AND p.date_end THEN 1 ELSE 0 END) AS paid
FROM ce_daily_minutes l LEFT JOIN ce_purchases p ON l.student_id=p.student_id
GROUP BY l.student_id,l.date_watched,l.minutes_watched;

CREATE OR REPLACE VIEW ce_onboarding AS
SELECT s.student_id,s.date_registered,IF(COUNT(e.student_id)>0,1,0) AS student_onboarded
FROM student_info s LEFT JOIN student_engagement e ON e.student_id=s.student_id
GROUP BY s.student_id,s.date_registered;

CREATE OR REPLACE VIEW ce_periods AS
SELECT 0 AS period UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
UNION ALL SELECT 8 UNION ALL SELECT 9;
