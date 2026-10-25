# Metric Definitions & Data Contract

Observation cutoff: **2022-10-31 inclusive**. All purchases and learning dates in this snapshot fall inside January–October. Later refund dates exist; they do not extend the analytical observation period. Rates in exports are fractions unless a field explicitly says otherwise; reports display percentages.

## Common definitions

| Concept | Exact definition | Caveat |
|---|---|---|
| Registration population | All 37,490 `student_info` rows | Snapshot completeness relative to the live platform is unknown |
| Active learner | At least one lesson, quiz or exam activity record | Not a login; one row per student-day after deduplication |
| Paid status (historical primary) | Activity date inclusively between a start/end interval from `ce_purchases`; MAX across subscriptions | Same person can be free and paid on different dates |
| Historical entitlement end | Original `MAKEDATE(YEAR(purchase),DAY(purchase))` plus purchase month + 0/2/11 months; refund date replaces end when present | Preserved for Tableau continuity, not presented as the only valid business contract |
| Fixed-day sensitivity | Start + 29/89/364 days, truncated by an earlier refund; inclusive end | Dictionary defines 30/90/365 days; changing this rule changes 122 activity-day status labels; it does not replace the original dashboard |
| Ever activated | Any engagement row by cutoff / all registrations in a signup month | Unequal follow-up, not registration-month activation |
| Daily activity | Distinct active learners on a given date | Daily paid/free groups are disjoint; monthly groups need not be |

## Retention: two explicitly different questions

### A. Historical Tableau status-entry retention

- Grain of membership: `(student_id, paid)`.
- Cohort date: first activity in that status. Cohort label: month of that date.
- Period: `TIMESTAMPDIFF(MONTH, cohort_date, date_engaged)`. This counts completed elapsed months; January 31 to February 1 is period 0.
- Denominator: distinct members entering the status in the named cohort month.
- Numerator: distinct members active in the same status at that period.
- Period 0 is 100% by construction. This is activity retention, not subscription survival or consecutive-month retention.
- `full_window_observed=1` only when `TIMESTAMPDIFF(MONTH, latest_entry_in_cohort, '2022-11-01') > period`. This conservative group flag requires the full elapsed interval for every member before cutoff. Rates in partial intervals remain labelled observed, not interpreted as mature outcomes.
- Tableau's saved retention chart uses a percent-of-value table calculation over the cohort/period layout. The SQL fixes the denominator explicitly. Free/Paid selections correspond to the group metrics; ALL can mix the same learner across status-entry months. Interactive selection can restrict the displayed partition; clear selections for baseline review.

### B. Registration calendar retention (SQL extension, not wired into original Tableau)

- Cohort: registration month; denominator: every registration, including never-active learners.
- Period: difference between activity calendar month and registration calendar month.
- Numerator: distinct cohort members active at least once in that calendar month, regardless of paid status.
- M0 is calendar-month activation, not 100%. M1 is next calendar month, not exactly 30 days.
- Unobserved future periods are omitted from SQL output, never assigned zero. Observed empty periods are zero-filled.
- One engagement date before registration is excluded only from this analytical extension; the source and historical comparisons preserve it.

## Free-to-paid assignment output

`ce_f2p`: exactly one row per registered student; columns `student_id`, `date_registered`, `f2p`, `total_minutes_watched`, `buckets`.

- `f2p=1` when at least one purchase record exists. Refunded and registration-day purchases count; an observed free activity stage is not required.
- Purchaser watch window: `[registration date, first purchase date]`, both inclusive.
- Nonpurchaser watch window: `[registration date, 2022-10-31]`, inclusive.
- No qualifying watch rows: zero, without dropping the learner.
- Aggregate raw course rows once, round total to two decimals, then assign exactly one bucket.
- Purchase incidence per bucket: `SUM(f2p) / COUNT(*)`; equivalent to Tableau `SUM(f2p)/COUNTD(student_id)` for this unique-key export.
- Required buckets: `[0]`, `(0,5]`, `(5,10]`, `(10,15]`, `(15,20]`, `(20,25]`, `(25,30]`, `(30,40]`, `(40,50]`, `(50,60]`, `(60,70]`, `(70,80]`, `(80,90]`, `(90,100]`, `(100,110]`, `(110,120]`, `(120,240]`, `(240,480]`, `(480,1000]`, `(1000,2000]`, `(2000,3000]`, `(3000,4000]`, `(4000,6000]`, `6000+` (>6000). Empty buckets have no aggregate row, not a zero-valued rate.
- Date-only purchase boundaries can include post-payment viewing on the purchase day. Exposure depends on purchase outcome and observation time, so the rates are not causal or prospective predictors.

**30-day extension:** complete January–September registration cohorts; purchase on days 0–29 (`first_purchase < registration + INTERVAL 30 DAY`). Include only whole registration months whose latest signup has all 30 days observed. October is excluded as a whole. Denominator includes every registration in each eligible month. It is purchase incidence, not net paid retention.

## Content and subscription duration

- Student-day minutes: sum **every** raw `student_learning` row by student/date before joining purchases. Never select nonaggregated minutes from a grouped query.
- Minutes per watching learner: total minutes in a status/window divided by distinct learners who watched in that status/window. Not per registration, not per month unless the query groups by month. Learners may occur in both status groups.
- Subscription assignment span: first subscription start to last subscription end, with end capped at cutoff. Minutes are summed inclusively inside that span, even across subscription gaps. `num_paid_days = DATEDIFF(last_day,first_day)` excludes the extra inclusive endpoint day; the historical name is retained for compatibility but means **span days**, not actual paid coverage.
- Subscription buckets: `[0]`, `(0,30]`, `(30,60]`, `(60,120]`, `(120,240]`, `(240,480]`, `(480,1000]`, `(1000,2000]`, `(2000,3000]`, `(3000,4000]`, `(4000,6000]`, `6000+`.

## Courses, assessment and tracks

| Metric | Numerator / denominator or grain | Interpretation |
|---|---|---|
| Course mean minutes | Total course minutes / distinct course watchers | Multiple watching days and rewatching count |
| `completion_rate` in export | Rounded mean minutes / course duration, rounded to 2 decimals | Viewing-duration ratio; not verified completion probability |
| Overall rating | Sum of all ratings / number of rating rows | Rating-weighted mean; not average of course averages |
| Exam pass rate | Passed attempt rows / all attempt rows within category | Repeated attempts remain separate |
| Certificate count | Issuance records | Distinct recipients are separately reported |
| Track enrollment | Distinct learner-track pair | People may enroll in multiple tracks |
| Course-exam stage | Enrolled track members attempting/passing any course exam belonging to that track | Not all courses completed; dates not sequence-enforced |
| Final-exam stage | Enrolled members attempting/passing a category-3 exam for that track | Historical last stage infers certification from pass status |
| Stage reach | Distinct students at stage / distinct enrolled students in same track | Unordered reach; not step-to-step causal attrition |

Track labels come from Tableau aliases: 1 Data Scientist, 2 Data Analyst, 3 Business Analyst. Actual career certificates use `certificate_type=2`; exam categories are 1 practice, 2 course, 3 career track. The assignment and observed exam data establish binary `exam_passed` despite imprecise dictionary wording.
