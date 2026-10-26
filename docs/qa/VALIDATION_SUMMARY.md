# Validation Summary

## Executed scope

- Nine curated SQL modules, including idempotent setup, executed and rerun on isolated **MySQL 5.7.24** with strict `ONLY_FULL_GROUP_BY` settings.
- All **24** explicit expected-value checks in `08_quality_checks.sql` passed: population/known anomaly counts, all eleven source-table populations, and eight integrity/date checks.
- Thirteen aggregate result files exported directly by MySQL.
- All fields and keys of ten original CSVs compared against curated views. Nine match; the historical learning output differs on **12,181** student-days. Raw and corrected daily minutes agree at **1,917,374.91**.
- Original Hyper versus CSV: nine sources match; F2P has **18,524** minute-field discrepancies caused by null decimal values under the original integer schema. Existing bucket and purchase labels agree.
- Original Hyper versus corrected MySQL: two known defects. Reviewed Hyper versus MySQL: **all ten sources match**.
- Tableau source reconciliation covered the original and corrected extracts; corrected values matched the SQL outputs.
- Dashboard screenshots represent historical Tableau views and were not independently reconciled to the corrected extracts.
- Local Markdown links were checked in the prior validation.

## Evidence files

- `execution_logs/00_setup_views.tsv` through `08_quality_checks.tsv`: actual MySQL result logs.
- `mysql_csv_reconciliation.csv`: source CSV versus curated SQL.
- `hyper_csv_reconciliation.csv`: original Hyper versus source CSV.
- `tableau_mysql_reconciliation.csv`: both workbook versions versus SQL.
Numeric reconciliation tolerance is 0.011 for two-decimal exports; identifier/date/category fields are compared exactly. An expected historical defect is recorded as a defect, not as zero mismatches. Package validity and source equality do not prove every chart's visual correctness.

## Validation boundaries

SQL execution was validated on MySQL 5.7.24, not MySQL 8.x/9.x. Historical Tableau screenshots are included for visual context but should not be interpreted as validated corrected views. The analysis does not establish causal effects, net revenue conversion, or a chronologically ordered career-track funnel. Source-data redistribution rights have not been established.
