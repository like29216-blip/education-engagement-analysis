# Tableau Dashboard Guide

The original package contains **9 dashboards, 22 worksheets, 10 extract-backed data sources and 4 action definitions**, authored with a Tableau 2026.1.1 source build. All dashboards have a fixed **1366 × 768** desktop layout. The workbook has five main navigation themes: Overview, Engagement, Cohorts, Exams and Learning.

The workbooks listed below are local-review artifacts and are not distributed in the public repository: they contain record-level extracts with unconfirmed redistribution rights.

## Versions

| Workbook | Status | Data behavior |
|---|---|---|
| customer_engagement.twbx | Original, byte-identical to the input | Preserves historical source defects for traceability |
| customer_engagement_reviewed.twbx | Derived data repair | Replaces daily-learning extract with correct SQL sums; restores decimal F2P minutes and updates corresponding type metadata; all other embedded extracts unchanged |

The reviewed copy does **not** redefine entitlements, change cohorts, add SQL-only extensions to the dashboard, or redesign visualizations. Its cached thumbnails were removed to prevent old-data images from appearing as updated renders. All ten revised sources reconcile to MySQL at row/field level. A full fresh visual/interaction pass is still pending; structural and data verification are not claimed as visual verification.

## Pages, chart purpose and controls

| Dashboard | Main charts / business purpose | Visible controls and interaction scope |
|---|---|---|
| Overview | Active learners, watched minutes and certificates KPIs; course Top/Bottom 5; ratings distribution | Student status and date parameters affect linked KPI sources; course chart selector and Top/Bottom switch act on lifetime course aggregates. Ratings have no student/date fields |
| Engagement Date | Daily activity and registration-cohort onboarding | Start/end parameters and status selection; onboarding uses registration dates and ever-engaged flag |
| Engagement Month | Daily views within a chosen month | Month parameter and status control |
| Engagement Year | Monthly activity/onboarding overview | Status control; 2022 snapshot |
| Cohort Engagement | Cohort count heatmap and same-status elapsed-period retention curves | Free/Paid/ALL parameter; cohort-cell selection filters the retention view; clear selection to restore baseline |
| Exams and Certificates | Attempt outcomes and certificates issued | Exam-category and certificate-type controls |
| Exams and Funnel | Attempt outcomes and five career-track stages | Exam category and track selector |
| Student Learning and F2P | Monthly minutes / intensity and bucket purchase incidence | Paid status filters the Minutes Watched sheet; it is not a shared filter on the independent F2P population. Measure highlighting is configured |
| Student Learning and Subs | Monthly minutes / intensity and subscription-span buckets | Paid status filters viewing; duration uses a separate assignment source. Measure highlighting is configured |

Track aliases: Data Scientist, Data Analyst and Business Analyst. Source-file/date/status controls are not universally global filters. In particular, course and rating aggregates cannot respond to dates absent from their source tables. This matters when interpreting mixed KPI/aggregate pages.

The saved XML defines one cohort-selection filter action and three generated measure-highlighting actions. XML existence and targets were inspected; all interaction permutations have not been exhaustively tested in the UI.

## Source-to-SQL map

| Tableau source | Curated export view | Review concern |
|---|---|---|
| student_engagement | ce_engagement_cohorts | Historical elapsed-month status cohorts |
| student_onboarding | ce_onboarding | Ever engaged; unequal follow-up |
| student_learning | ce_learning | Original undercount repaired |
| student_buckets_f2p | ce_f2p | Decimal minute import repaired; bucket rates unchanged |
| student_buckets_sub_duration | ce_subscription_span | Span, not actual covered days |
| courses_engagement | ce_courses | Duration ratio, not completion probability |
| course_ratings | course_ratings (single column) | Lifetime self-selected ratings |
| student_exam_attempts | ce_exam_attempts | Attempts, not learners |
| student_certificates | ce_certificates | Actual issuance records |
| career_track_funnel | ce_funnel | Unordered reach; original missing SQL stage restored |

## Preview and visual-verification status

The original workbook loaded in the available Tableau Public application; its UI exposed navigation, date/type controls and page names. The file opened in the app was independently hashed and matched the supplied original exactly. The computer-use screenshot API reported **“Screenshot unavailable”**. The accessible export menus did not yield a reliable image export. Therefore no full-resolution screenshot is claimed.

Nine original embedded PNG thumbnails were decoded **without retouching** into `screenshots/`. They are cropped caches, not full dashboards, and do not represent the reviewed data. [Preview gallery and manual checklist](screenshots/README.md).

For the reviewed copy, verify in Tableau after clearing selections: ALL, January 1–October 31; active learners **19,332**; minutes **1,917,374.91**; certificates **3,683**. Check January Free/Paid retention separately and F2P bucket rates. Export full dashboard images using an available Tableau image-export command, or a clearly labelled presentation-mode screenshot. Do not publish to Tableau Public just to obtain screenshots without first confirming data rights.

A Refresh All operation can still reference historical local CSV locations for unchanged sources. Rebind explicitly using the view map. The reviewed learning/F2P refresh CSVs are included in `review_materials/tableau_refresh/`; original learning CSVs must not be used to refresh the corrected copy.
