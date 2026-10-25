-- Online Education Platform | MySQL 5.7+ / 8.x compatible SQL
-- Source data: customer_engagement. Read sql/README.md for execution order.
USE customer_engagement;
SET SESSION sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- These are count-based checks with explicit expected values; see docs/qa for executed evidence.
SELECT 'registrations' AS metric,COUNT(*) AS actual,37490 AS expected FROM student_info
UNION ALL SELECT 'f2p_rows',COUNT(*),37490 FROM ce_f2p
UNION ALL SELECT 'subscription_rows',COUNT(*),2338 FROM ce_subscription_span
UNION ALL SELECT 'funnel_rows',COUNT(*),15 FROM ce_funnel
UNION ALL SELECT 'preregistration_activity',COUNT(*),1 FROM student_engagement e JOIN student_info s ON s.student_id=e.student_id WHERE e.date_engaged<s.date_registered;
SELECT ROUND(SUM(minutes_watched),2) AS raw_minutes FROM student_learning;
SELECT ROUND(SUM(minutes_watched),2) AS corrected_daily_minutes FROM ce_learning;
SELECT COUNT(*) AS both_statuses FROM
 (SELECT student_id FROM ce_engagement GROUP BY student_id HAVING COUNT(DISTINCT paid)=2) s;
-- Explicit sensitivity; this alternative does NOT replace dashboard history.
SELECT SUM(e.paid<>e.paid_fixed_days) AS changed_activity_status_days FROM
 (SELECT e.student_id,e.date_engaged,e.paid,
 MAX(CASE WHEN e.date_engaged BETWEEN p.date_start AND p.date_end THEN 1 ELSE 0 END) AS paid_fixed_days
 FROM ce_engagement e LEFT JOIN ce_purchases_fixed_days p ON p.student_id=e.student_id
 GROUP BY e.student_id,e.date_engaged,e.paid) e;

-- Input integrity: the original snapshot contains these eleven table populations.
SELECT 'career_track_info' AS source_table,COUNT(*) AS actual,24 AS expected FROM career_track_info
UNION ALL SELECT 'course_info',COUNT(*),56 FROM course_info
UNION ALL SELECT 'course_ratings',COUNT(*),2731 FROM course_ratings
UNION ALL SELECT 'exam_info',COUNT(*),907 FROM exam_info
UNION ALL SELECT 'student_career_track_enrollments',COUNT(*),7874 FROM student_career_track_enrollments
UNION ALL SELECT 'student_certificates',COUNT(*),3683 FROM student_certificates
UNION ALL SELECT 'student_engagement',COUNT(*),68340 FROM student_engagement
UNION ALL SELECT 'student_exams',COUNT(*),35359 FROM student_exams
UNION ALL SELECT 'student_info',COUNT(*),37490 FROM student_info
UNION ALL SELECT 'student_learning',COUNT(*),85945 FROM student_learning
UNION ALL SELECT 'student_purchases',COUNT(*),3330 FROM student_purchases;
SELECT 'learning_orphan_student' AS check_name,COUNT(*) AS actual,0 AS expected
FROM student_learning l LEFT JOIN student_info s ON s.student_id=l.student_id WHERE s.student_id IS NULL
UNION ALL SELECT 'engagement_orphan_student',COUNT(*),0 FROM student_engagement e LEFT JOIN student_info s ON s.student_id=e.student_id WHERE s.student_id IS NULL
UNION ALL SELECT 'purchases_orphan_student',COUNT(*),0 FROM student_purchases p LEFT JOIN student_info s ON s.student_id=p.student_id WHERE s.student_id IS NULL
UNION ALL SELECT 'negative_or_null_minutes',COUNT(*),0 FROM student_learning WHERE minutes_watched<0 OR minutes_watched IS NULL
UNION ALL SELECT 'purchase_before_registration',COUNT(*),0 FROM ce_first_purchase p JOIN student_info s USING(student_id) WHERE p.first_purchase<s.date_registered
UNION ALL SELECT 'invalid_exam_pass',COUNT(*),0 FROM student_exams WHERE exam_passed NOT IN(0,1) OR exam_passed IS NULL
UNION ALL SELECT 'out_of_window_learning',COUNT(*),0 FROM student_learning WHERE date_watched NOT BETWEEN '2022-01-01' AND '2022-10-31'
UNION ALL SELECT 'out_of_window_purchases',COUNT(*),0 FROM student_purchases WHERE date_purchased NOT BETWEEN '2022-01-01' AND '2022-10-31';
