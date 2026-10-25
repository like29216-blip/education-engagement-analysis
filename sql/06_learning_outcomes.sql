-- Online Education Platform | MySQL 5.7+ / 8.x compatible SQL
-- Source data: customer_engagement. Read sql/README.md for execution order.
USE customer_engagement;
SET SESSION sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE OR REPLACE VIEW ce_exam_attempts AS
SELECT s.exam_attempt_id,s.student_id,s.exam_id,e.exam_category,s.exam_passed,s.date_exam_completed
FROM student_exams s JOIN exam_info e ON e.exam_id=s.exam_id;
CREATE OR REPLACE VIEW ce_exam_summary AS
SELECT exam_category,COUNT(*) AS attempts,COUNT(DISTINCT student_id) AS students,
 SUM(exam_passed) AS passed_attempts,AVG(exam_passed) AS attempt_pass_rate
FROM ce_exam_attempts GROUP BY exam_category;
CREATE OR REPLACE VIEW ce_certificates AS
SELECT c.certificate_id,c.student_id,c.certificate_type,c.date_issued,
 MAX(CASE WHEN c.date_issued BETWEEN p.date_start AND p.date_end THEN 1 ELSE 0 END) AS paid
FROM student_certificates c LEFT JOIN ce_purchases p ON p.student_id=c.student_id
GROUP BY c.certificate_id,c.student_id,c.certificate_type,c.date_issued;
SELECT * FROM ce_exam_summary ORDER BY exam_category;
SELECT certificate_type,COUNT(*) AS certificates,COUNT(DISTINCT student_id) AS recipients
FROM ce_certificates GROUP BY certificate_type;
