# Source Review & SQL Lineage

The current user request takes precedence over the handoff's older Notebook-oriented instructions. No Notebook or Python visualization is included in this portfolio. `CODEX_INSTRUCTIONS.md`, `PROJECT_CONTEXT.md` and `HANDOFF_README.md` were read as background; Assignment+1.pdf and the source dictionary guide metric review.

## Historical-query disposition

| Original query | Curated destination | Treatment |
|---|---|---|
| view_student_status(1).sql | 00_setup_views.sql | Preserve historical dates in ce_purchases; remove DROP/debug SELECT; add clearly separate fixed-day sensitivity |
| student_engagement(2).sql | 00 + 01 | Preserve student-day status; deterministic grouping |
| dshb_engagement_with_cohorts(2).sql | 02 | Preserve status-entry and TIMESTAMPDIFF; replace permissive SELECT * grouping with explicit entry view; add censoring flag |
| student_onboarding(2).sql | 00 + 02 | Preserve ever-engaged semantics; explain unequal follow-up |
| student_learning(3).sql | 00 + 03 | Fix invalid/incomplete outer wrapper and nonaggregated minutes; aggregate all learning rows before status join |
| student_buckets_f2p(3).sql | 04 | Retain inclusive first-purchase boundary, zeros and exact buckets; replace multiple UNION passes with left join; remove debug lookups |
| student_buckets_sub_duration(2).sql | 03 | Retain assignment span and cutoff; simplify zero-fill; explicitly distinguish span from covered days |
| courses_engagement(2).sql | 05 | Preserve rounded assignment output; add learner and rating support for interpretation |
| course_rating.sql | 05 | Preserve individual-rating export and overall weighted mean |
| student_exam_attempts(2).sql | 06 | Preserve attempt grain and category join |
| student_certificates(2).sql | 06 | Preserve issued-date status and issuance grain |
| career_track_funnel(1).sql | 07 | Restore missing final-exam-attempt stage to match the existing 15-row CSV; preserve unordered distinct-student reach |

All 12 supplied SQL files are retained verbatim in local-only `review_materials/original_sql/`. No byte-identical duplicate remains among the 12. The handoff says a duplicate `(3)` cohort file was removed before packaging; that absent file cannot be independently compared. Debug lookups, redundant zero-handling branches and duplicated status calculations were removed from curated code. Meaningful analyses in all seven requested modules were retained.

## Other sources

- Original dump: all 11 tables imported; record counts match the dictionary.
- Ten CSV exports: all fields and keys reconciled to the curated MySQL views. One known learning-source defect remains in the **original**, not in the curated result.
- Assignment PDF: F2P and subscription schemas, exact buckets, inclusive viewing window and expected populations verified.
- Dictionary workbook: table relations, tracked activity, plan duration and event dates inspected. The fixed-day duration conflicts with legacy SQL; both are documented, not silently conflated.
- TWBX: ZIP integrity, XML, all internal Hyper references, ten table populations, row-level data, nine dashboards, 22 worksheets, controls and action definitions inspected.
- Seven-page scanned notes: visually reviewed for analysis sequence, interpretation and experiment ideas. Unsupported causal/threshold claims were not promoted to facts.
- Resume PNG: excluded as personal context, not analytical evidence.

## Portfolio organization references

The following user-supplied public repositories informed presentation only:

- [E-Shop User Engagement](https://github.com/dmitryk5/E-Shop_User_Engagement): module-oriented SQL navigation and a clear Tableau entry point.
- [Customer Churn SQL Analysis](https://github.com/bhagyakelur/customer-churn-SQL-analysis): concise business overview and selected insights.
- [Revenue Metrics Analysis](https://github.com/anna-darda/revenue-metrics-analysis): metric explanations and dashboard component descriptions.

No external analytical conclusions, data, SQL or visualizations were copied. All results in this portfolio come from the supplied education-platform materials.
