# Online Education Platform — Customer Engagement & Retention Analysis

**MySQL · Tableau · Business Intelligence**

How does a learning platform turn registrations into repeat learners and paying customers? This portfolio organizes an existing 2022 analysis into a traceable SQL-to-Tableau workflow, covering engagement, activation, retention, content use, conversion and learning outcomes. Retention and free-to-paid conversion are the central decisions.

## Dashboard Preview

The original interactive Tableau project contains five main dashboard sections. These screenshots are cropped from the actual Tableau interface (not recreated charts).

### Overview
![Overview dashboard](dashboard/screenshots/overview.png)

### Engagement & Onboarding
![Daily engagement and activation](dashboard/screenshots/engagement_daily.png)

### Cohort Engagement
![Cohort retention dashboard](dashboard/screenshots/cohorts.png)

### Student Learning & Free-to-Paid Conversion
![Viewing minutes and free-to-paid conversion](dashboard/screenshots/learning_conversion.png)

### Exams & Career Track Funnel
![Career-track funnel](dashboard/screenshots/career_track_funnel.png)

[Additional dashboard views](dashboard/screenshots/README.md) · [Workbook guide and availability](dashboard/README.md)

**Workbook note:** The reviewed Tableau workbook corrects two documented source defects while preserving layout and historical metric definitions. The screenshots above were provided from Tableau Public and have not been independently checked against the reviewed workbook; consult [review notes](REVIEW_NOTES.md) before treating all screenshot values as reconciled.

## Key Business Questions

- Do activated learners return, and how do free/paid status-entry cohorts differ?
- How does purchase incidence vary across pre-purchase viewing buckets?
- Which courses and learning stages warrant product attention?
- Which recommendations are supported as testable hypotheses rather than proven effects?

## Data & Methodology

The supplied case-study snapshot contains **37,490 registrations from January–October 2022** across 11 MySQL tables. The workflow is **raw database → reusable SQL views → validated exports → Tableau → business interpretation**. Assignment definitions and the accompanying dictionary guide the analysis; historical CSVs and Tableau Hyper extracts are independently checked.

Nine curated SQL modules run in order. The main analysis retains the original subscription-status and elapsed-month cohort rules. Corrections and separately labelled calendar-cohort / 30-day conversion extensions are documented; no definition is silently substituted. [Metric definitions](docs/metric_definitions.md) · [Reproduction instructions](data/README.md).

## Key Findings

| Verified finding | Business interpretation |
|---|---|
| **19,332 / 37,490 (51.56%)** registered learners are ever active | Acquisition alone does not ensure initial learning activity |
| January period-1 same-status retention: **2.99% free vs 51.76% paid** | Large descriptive difference; selected groups, not a causal effect of paying |
| **2,338 purchasers (6.24%)**; (110, 120] viewing-minute bucket: **63 / 138 (45.65%)** | Useful segmentation, but outcome-dependent exposure does not establish an optimal viewing target |
| Five foundational courses account for **55.14%** of raw watched minutes | High-reach locations for learning-path improvements |
| **43 career-track certificates to 39 people**, against **7,874 learner-track enrollments** | Investigate early assessment progression; these are not equivalent populations or a chronological funnel |

The original **878** figure is learners observed under both activity statuses, not all purchasers. The original daily-learning source understated viewing by **359,783.14 minutes**; the reviewed workbook corrects it. Its F2P minute field also restores **18,524** values lost during integer import; original bucket rates were unaffected.

## Business Recommendations

1. Test first-week learning plans and reminders to improve repeat activity.
2. Test relevant previews or upgrade prompts using exposure known before intervention, with equal purchase follow-up and refund guardrails.
3. Investigate campaign acquisition mix and the path from learning to first assessment before attributing changes to promotions or gamification.

[Full seven-module analysis](docs/analysis_report.md) separates verified findings, hypotheses, recommendations and limitations.

## Repository & Technical Review

```text
sql/                 00 setup + seven business modules + 08 quality checks
scripts/             MySQL execution/export; optional QA and Tableau repair helpers
dashboard/           Tableau guide, actual screenshots and original embedded previews
docs/                Analysis, metrics, source map and executed QA evidence
data/                Reproduction guide and aggregate SQL results
review_materials/    Local-only originals and corrected refresh CSVs; gitignored
REVIEW_NOTES.md       Changes, validation and remaining review steps
```

**Executed validation:** all nine SQL modules passed on isolated MySQL 5.7.24 under `ONLY_FULL_GROUP_BY`. Ten CSVs were checked: nine match; one has the documented learning defect. All ten reviewed Tableau extracts match SQL. [Review notes](REVIEW_NOTES.md).

## Limitations & Publication Status

Dates lack intraday order, purchase incidence includes refunds, and viewing windows differ between purchasers and nonpurchasers. Late elapsed-month retention periods are partially observed. Track stages are unordered reach counts. Promotions and gamification are contextual dates, not causal evidence.

The public repository includes SQL, reports, aggregate results and dashboard previews. Source data, reference materials and both packed Tableau workbooks are excluded because their redistribution rights are not established. Full reproduction requires authorized access to those local-only materials. Visual reconciliation of the supplied screenshots against the reviewed workbook remains pending. This is a SQL + Tableau project; no Python notebook is required or included.
