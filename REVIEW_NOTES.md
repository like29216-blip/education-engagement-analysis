# Review Notes — SQL + Tableau Portfolio V1

## Delivered scope

All seven original analytical areas are retained: platform engagement; activation/retention; content consumption; F2P; course engagement; exams/certificates; career tracks. Retention and F2P receive deeper metric/window/censoring discussion. The original Tableau is preserved, a repaired derivative is separately named, and nine authentic embedded previews are available. The README is the short portfolio entry; detailed evidence is in the report and QA folder. Nothing was published.

## Preserved, merged and corrected

- Preserved original dump, ten CSVs, twelve SQL files, assignment/dictionary references and original TWBX without byte changes. Local-only originals are separated from curated public-facing materials.
- Merged repeated status/zero-fill logic into reusable `ce_` views. Removed ad hoc student-ID debug queries and malformed wrappers. No supplied SQL files were exact duplicates; the previously removed cohort duplicate was not in the archive.
- Kept the **historical entitlement calculation** and **elapsed-month status-entry cohorts** as the main Tableau contract. A fixed-day status alternative, registration-calendar retention and 30-day purchase comparison are explicitly separate; the two latter extensions are not wired into the preserved dashboard.
- Corrected daily learning sums: 12,181 student-days differ from the old CSV, which misses 359,783.14 minutes. SQL now aggregates every raw learning row before attaching status.
- Restored the final-exam-attempt funnel stage missing from saved SQL but already present in CSV/Tableau. The result is stage reach, not a validated sequential funnel.
- Discovered a second Tableau-only defect: the original F2P minutes field was integer-typed and contains 18,524 nulls where the CSV has decimals. Bucket and purchase fields are intact, so the original bucket rates remain valid.
- Created `customer_engagement_reviewed.twbx`: corrected two Hyper extracts and F2P type metadata; preserved all other extracts and dashboard logic/layout. Removed stale thumbnails from that derivative. Original embedded previews are labelled as historical and cropped.

## Verified results

| Check | Outcome / evidence |
|---|---|
| Actual MySQL execution | Nine numbered SQL modules executed successfully on isolated MySQL 5.7.24, strict mode including ONLY_FULL_GROUP_BY; rerun succeeds |
| Source populations | All 11 source tables match expected counts; core orphan/date/negative-minute checks pass |
| Assignment population | F2P 37,490 rows; subscription span 2,338; funnel 15 rows |
| SQL vs historical CSV | All keys/counts reconcile; nine datasets match values; learning has exactly 12,181 known mismatched rows |
| Original Hyper vs CSV | Nine datasets match; F2P minute field has 18,524 known discrepancies |
| Original Hyper vs corrected MySQL | Two documented defects: F2P minutes and daily-learning minutes; remaining eight match |
| Reviewed Hyper vs MySQL | All ten sources match at row/field level |
| Minute conservation | Correct daily aggregation and raw table both sum to 1,917,374.91 |
| Historical retention | January period 1: free 46/1,540 = 2.99%; paid 132/255 = 51.76% |
| Purchase count | 2,338 purchasers; 878 is both-status activity membership, not total conversions |
| Source integrity | Original file SHA-256 checks passed; TWBX ZIP checks pass and all ten internal extract paths resolve |
| Preview provenance | Nine PNGs decoded directly from original TWB thumbnail bytes, without retouching |

Machine-readable tables and execution logs are in `docs/qa/`. Optional QA helpers compare records; they do not implement analytical transformations in Python. Numeric comparison tolerance is 0.011 for two-decimal historical exports.

## Environment and limitations

- The original dump uses an 8.0-only collation. Actual testing used a disposable import copy with just that collation changed to `utf8mb4_unicode_ci` for MySQL 5.7.24; delivered raw bytes are unchanged. MySQL 9.1 initialization crashed locally. No MySQL 8.x/9.x runtime pass is claimed.
- The original workbook loaded in Tableau Public, with exposed navigation and filter UI. The screenshot API returned “Screenshot unavailable”; a reliable high-resolution export was not obtained. The embedded 384 × 384 images are **cropped caches**, not fresh full dashboards.
- The reviewed workbook passed data/package checks but **has not passed fresh visual rendering or exhaustive interaction testing**. Never describe it as fully visually verified.
- Late status-entry periods are censored. September paid period-1 observed retention of 35.37% is not a fair mature-cohort comparison. The added SQL flag documents this; original Tableau layout does not display the flag.
- One preregistration activity is retained for historical consistency and excluded only from the registration-calendar extension.
- Purchase-day intraday ordering, net revenue, exact entitlement semantics and causal intervention effects remain unresolved. The dictionary's fixed-day alternative changes 122 activity-day labels; historical status remains primary to avoid silently changing previous conclusions.
- Funnel stages are unordered and the last historical stage is inferred from exam pass. Actual issuance counts are separately checked, not equated with every exam pass at person/time level.
- Redistribution permission is undocumented. TWBX packages contain row-level data. `.gitignore` excludes both workbooks and `review_materials/`; source imagery permission also needs review before public publication.

## Manual completion before public presentation

1. Open the reviewed workbook locally, clear selections, set ALL and January 1–October 31; verify Overview shows 19,332 engaged learners, 1,917,374.91 minutes and 3,683 certificates.
2. Verify cohort Free/Paid selections, clear-selection behavior, F2P buckets and course chart switching. Check that decimal F2P minutes are preserved.
3. Export full-resolution Overview, Cohort Engagement, Student Learning and F2P, and Exams and Funnel images; optionally all nine pages. Replace the clearly labelled original thumbnail preview links only with actual reviewed renders. See `dashboard/screenshots/README.md`.
4. Establish data/visual redistribution permission; choose a code-and-aggregate public release or an authorized full-data release. Rebind historical source paths before any Refresh All. Do not upload the private review folder by default.

These are specific remaining presentation/rights checks, not unperformed SQL or data reconciliation work. This package is ready for independent technical and analytical review.
