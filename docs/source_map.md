# SQL Lineage and Data Sources

The 2022 educational dataset contains 11 relational tables. The curated SQL modules retain historical cohort and subscription-status definitions while consolidating reusable logic.

| SQL module | Analytical scope |
|---|---|
| `00_setup_views.sql` | Reusable student, activity, purchase and status views |
| `01_platform_engagement.sql` | Platform activity and registration KPIs |
| `02_activation_retention.sql` | Onboarding, activation and cohort retention |
| `03_content_consumption.sql` | Learning minutes and subscription duration |
| `04_f2p_conversion.sql` | Viewing-minute segments and purchase incidence |
| `05_course_engagement.sql` | Course consumption and ratings |
| `06_learning_outcomes.sql` | Exam attempts and certificates |
| `07_career_track_funnel.sql` | Career-track stage reach |
| `08_quality_checks.sql` | Data integrity and reconciliation checks |

The daily-learning aggregation was corrected to sum all student/course/day learning rows before attaching status. The Tableau free-to-paid minute field requires decimal precision. The original raw database and row-level extracts are not distributed in this repository. See [metric definitions](metric_definitions.md) and [validation evidence](qa/VALIDATION_SUMMARY.md).
