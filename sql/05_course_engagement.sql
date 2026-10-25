-- Online Education Platform | MySQL 5.7+ / 8.x compatible SQL
-- Source data: customer_engagement. Read sql/README.md for execution order.
USE customer_engagement;
SET SESSION sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- Preserve assignment ratio while naming its limitation: duration ratio is NOT completion probability.
CREATE OR REPLACE VIEW ce_course_base AS
SELECT c.course_id,c.course_title,c.course_duration,COUNT(DISTINCT l.student_id) AS learners,
 ROUND(SUM(l.minutes_watched),2) AS minutes_watched,
 ROUND(SUM(l.minutes_watched)/COUNT(DISTINCT l.student_id),2) AS minutes_per_student
FROM course_info c JOIN student_learning l ON l.course_id=c.course_id
GROUP BY c.course_id,c.course_title,c.course_duration;
CREATE OR REPLACE VIEW ce_courses AS
SELECT course_id,course_title,minutes_watched,minutes_per_student,
 ROUND(minutes_per_student/course_duration,2) AS completion_rate FROM ce_course_base;
CREATE OR REPLACE VIEW ce_course_ratings AS
SELECT course_id,COUNT(*) AS rating_count,ROUND(AVG(course_rating),4) AS mean_rating
FROM course_ratings GROUP BY course_id;
SELECT b.*,c.completion_rate AS viewing_duration_ratio,r.rating_count,r.mean_rating
FROM ce_course_base b JOIN ce_courses c ON c.course_id=b.course_id
LEFT JOIN ce_course_ratings r ON r.course_id=b.course_id
ORDER BY b.minutes_watched DESC;
SELECT COUNT(*) AS ratings,ROUND(AVG(course_rating),4) AS mean_rating FROM course_ratings;
