# Validation Summary

## Executed scope

- Nine curated SQL modules, including idempotent setup, executed and rerun on isolated **MySQL 5.7.24** with strict `ONLY_FULL_GROUP_BY` settings.
- All **24** explicit expected-value checks in `08_quality_checks.sql` passed: population/known anomaly counts, all eleven source-table populations, and eight integrity/date checks.
- Thirteen aggregate result files exported directly by MySQL.
- All fields and keys of ten original CSVs compared against curated views. Nine match; the historical learning output differs on **12,181** student-days. Raw and corrected daily minutes agree at **1,917,374.91**.
- Original Hyper versus CSV: nine sources match; F2P has **18,524** minute-field discrepancies caused by null decimal values under the original integer schema. Existing bucket and purchase labels agree.
- Original Hyper versus corrected MySQL: two known defects. Reviewed Hyper versus MySQL: **all ten sources match**.
- **26 original files** retained byte-for-byte, including the original TWBX. Both ZIP containers pass integrity checks. All ten embedded extract paths resolve.
- Original and reviewed dashboard, worksheet and action XML sections are identical. Eight Hyper files are byte-identical; exactly two are deliberately rebuilt. F2P source type metadata changes are separately logged. Stale thumbnails are removed from the reviewed copy.
- Nine original thumbnail files match their embedded source bytes; these are cropped caches, not new full-resolution screenshots.
- Local Markdown links resolve. No notebook or Python-generated visualization exists in this repository.

## Evidence files

- `execution_logs/00_setup_views.tsv` through `08_quality_checks.tsv`: actual MySQL result logs.
- `mysql_csv_reconciliation.csv`: source CSV versus curated SQL.
- `hyper_csv_reconciliation.csv`: original Hyper versus source CSV.
- `tableau_mysql_reconciliation.csv`: both workbook versions versus SQL.
- `hyper_inventory.json`: original extract tables, schemas, row counts and hashes.
- `dashboard_inventory.json`: original page composition and controls.
- `original_file_integrity.csv`: retained original file hashes.
- `tableau_repair.json`: reviewed-workbook changes and hashes.

Numeric reconciliation tolerance is 0.011 for two-decimal exports; identifier/date/category fields are compared exactly. An expected historical defect is recorded as a defect, not as zero mismatches. Package validity and source equality do not prove every chart's visual correctness.

## Not verified / pending

- MySQL 8.x/9.x execution. Local 9.1 initialization crashed; testing used a disposable 5.7 import with only the unsupported collation name replaced. The delivered original dump is unchanged.
- Full-resolution rendering of all nine dashboards and all interaction/filter combinations. The screenshot channel was unavailable. The reviewed copy requires a fresh visual pass.
- A sequential, temporally eligible career funnel; causal marketing/gamification effects; net revenue conversion; exact intraday ordering; underlying data redistribution rights.

No remote database, GitHub upload or Tableau Public publication was used.
