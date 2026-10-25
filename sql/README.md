# SQL Execution & Dependencies

Run against a **fresh local import** of the supplied `customer_engagement` database, not a production database. Files use MySQL syntax and were actually executed with MySQL 5.7.24 in strict `ONLY_FULL_GROUP_BY` mode. The original dump targets MySQL 8.0; see `data/README.md` for the test-environment collation adjustment. MySQL 8.x execution has not been performed in this environment.

## Order

```bash
bash scripts/run_sql.sh -u your_user -p
bash scripts/export_results.sh -u your_user -p
```

The password prompt may recur because each module uses a separate client. A local MySQL login path is preferable for repeated runs; do not put passwords in repository files. `MYSQL_BIN` can select a client binary. On Windows, execute the numbered files in order in MySQL Workbench, or use Bash with a compatible MySQL client.

| File | Purpose | Dependencies |
|---|---|---|
| 00_setup_views.sql | Historical and fixed-day entitlement views, daily learning/activity, onboarding, period scaffold; idempotent indexes | Eleven source tables |
| 01_platform_engagement.sql | Population KPIs, monthly/daily activity, descriptive campaign window | 00 |
| 02_activation_retention.sql | Activation; historical status-entry cohorts with censoring flag; separate registration-calendar extension | 00 |
| 03_content_consumption.sql | Correct daily sums, watcher averages, subscription-span assignment export | 00 |
| 04_f2p_conversion.sql | Assignment viewing windows/buckets; 30-day complete-cohort extension | 00 |
| 05_course_engagement.sql | Course reach, minutes, duration ratios and rating support | Source course/learning/rating tables |
| 06_learning_outcomes.sql | Exam-attempt outcomes and issuance-date status | 00 |
| 07_career_track_funnel.sql | Complete five-stage, per-track reach and actual issuance audit | Source track/exam/certificate tables |
| 08_quality_checks.sql | Population, conservation, orphan/date checks and entitlement sensitivity | 00–07 |

`ce_` objects are derived views. The setup adds four analytical indexes to the **local imported copy**; it does not change source row values or the supplied dump file. Views are idempotently replaced and contain deterministic grouped fields. No original query's trailing debug selects or user-specific lookup IDs remain in curated SQL.

`result_manifest.txt` drives aggregate exports. Shell helpers calculate no business metrics: MySQL executes every calculation. Optional Python helpers only compare rows or package Tableau extracts; no notebook or Python analytics pipeline is required.

## Assignment-compatible Tableau outputs

Export each SELECT as a comma-separated, UTF-8 CSV with a header using Workbench or another MySQL client. Do not rename a tab-separated `.tsv` to `.csv`.

| Original source | Export SELECT |
|---|---|
| student_engagement.csv | `SELECT * FROM ce_engagement_cohorts;` |
| student_onboarding.csv | `SELECT * FROM ce_onboarding;` |
| student_learning.csv | `SELECT * FROM ce_learning;` **Corrected daily minutes** |
| student_buckets_f2p.csv | `SELECT * FROM ce_f2p;` **Minutes must be decimal/real in Tableau** |
| student_buckets_sub_duration.csv | `SELECT * FROM ce_subscription_span;` |
| courses_engagement.csv | `SELECT * FROM ce_courses;` |
| course_ratings.csv | `SELECT course_rating FROM course_ratings;` |
| student_exam_attempts.csv | `SELECT * FROM ce_exam_attempts;` |
| student_certificates.csv | `SELECT * FROM ce_certificates;` |
| career_track_funnel.csv | `SELECT * FROM ce_funnel;` |

The historical engagement export filename in the handoff is `student_engagement(1).csv`. Its columns correspond to the cohort query, not merely the three-column activity query. Preserve header names when refreshing Tableau.
