# Data and Reproduction

The analysis uses an educational 2022 online learning platform snapshot with 11 tables. This public version contains aggregate outputs in [`results/`](results/) but does not distribute the original database, row-level CSV exports or Tableau packaged workbooks. Reproduction requires authorized access to the original dataset.

## Workflow

1. Load an authorized copy of the source tables into an isolated MySQL database. Do not import a SQL dump over a database containing data you need to keep.
2. Review [`sql/README.md`](../sql/README.md) and execute the numbered SQL modules in order.
3. Use [`scripts/run_sql.sh`](../scripts/run_sql.sh) and [`scripts/export_results.sh`](../scripts/export_results.sh) where compatible with your environment.
4. Compare aggregate results to [`results/`](results/) and the documented metrics in [`../docs/metric_definitions.md`](../docs/metric_definitions.md).

**Validation environment:** the SQL modules were previously run on MySQL 5.7.24 with `ONLY_FULL_GROUP_BY`. The original MySQL 8 dump required a collation adjustment in an isolated test copy. See [`../docs/qa/VALIDATION_SUMMARY.md`](../docs/qa/VALIDATION_SUMMARY.md) for validation scope.

The corrected daily-learning totals and decimal viewing-minute types should be used in any newly built Tableau dashboard.
