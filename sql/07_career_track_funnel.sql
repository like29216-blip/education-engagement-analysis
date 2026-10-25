-- Online Education Platform | MySQL 5.7+ / 8.x compatible SQL
-- Source data: customer_engagement. Read sql/README.md for execution order.
USE customer_engagement;
SET SESSION sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- Historical unordered stage reach, DISTINCT learners PER TRACK; NOT an ordered journey.
-- Complete missing final-exam-attempt stage. Do not force monotonicity.
CREATE OR REPLACE VIEW ce_funnel AS
SELECT 'Enrolled in a track' AS action,track_id AS track,COUNT(DISTINCT student_id) AS count FROM student_career_track_enrollments GROUP BY track_id
UNION ALL
SELECT 'Attempted a course exam',e.track_id,COUNT(DISTINCT e.student_id)
FROM student_career_track_enrollments e JOIN career_track_info c USING(track_id)
JOIN exam_info x ON x.course_id=c.course_id JOIN student_exams s ON s.student_id=e.student_id AND s.exam_id=x.exam_id WHERE x.exam_category=2 GROUP BY e.track_id
UNION ALL
SELECT 'Completed a course exam',e.track_id,COUNT(DISTINCT e.student_id)
FROM student_career_track_enrollments e JOIN career_track_info c USING(track_id)
JOIN exam_info x ON x.course_id=c.course_id JOIN student_exams s ON s.student_id=e.student_id AND s.exam_id=x.exam_id WHERE x.exam_category=2 AND s.exam_passed=1 GROUP BY e.track_id
UNION ALL
SELECT 'Attempted a final exam',e.track_id,COUNT(DISTINCT e.student_id)
FROM student_career_track_enrollments e JOIN exam_info x USING(track_id)
JOIN student_exams s ON s.student_id=e.student_id AND s.exam_id=x.exam_id WHERE x.exam_category=3 GROUP BY e.track_id
UNION ALL
SELECT 'Earned a career track certificate',e.track_id,COUNT(DISTINCT e.student_id)
FROM student_career_track_enrollments e JOIN exam_info x USING(track_id)
JOIN student_exams s ON s.student_id=e.student_id AND s.exam_id=x.exam_id WHERE x.exam_category=3 AND s.exam_passed=1 GROUP BY e.track_id;
SELECT f.action,f.track,f.count,e.count AS enrolled_students,f.count/e.count AS share_of_enrolled
FROM ce_funnel f JOIN ce_funnel e ON f.track=e.track AND e.action='Enrolled in a track'
ORDER BY f.track,FIELD(f.action,'Enrolled in a track','Attempted a course exam','Completed a course exam','Attempted a final exam','Earned a career track certificate');
-- Separately audit actual certificate issuance; historical funnel infers it from exam passing.
SELECT track_id,COUNT(*) AS issued_certificates,COUNT(DISTINCT student_id) AS recipients
FROM student_certificates WHERE certificate_type=2 GROUP BY track_id;
