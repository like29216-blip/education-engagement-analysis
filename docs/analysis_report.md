# Online Education Platform — Customer Engagement & Retention Analysis

## Executive perspective

The supplied January–October 2022 cohort contains **37,490 registered learners**, **19,332 ever-active learners**, and **2,338 purchasers**. The strongest opportunities are to build repeat learning habits and understand the path from initial content use to purchasing. The evidence supports targeted experiments, not claims that more viewing or a particular promotion causes conversion.

This report preserves the original SQL + Tableau project across seven modules. Historical Tableau definitions are retained unless an explicit correction is identified. **Verified** means recomputed in MySQL, with original CSVs and Tableau extracts separately reconciled. **Hypothesis** means a possible explanation requiring more evidence. The report does not reuse numerical claims solely because they appear in handwritten notes.

### Reading the two workbook versions

- `dashboard/customer_engagement.twbx` is the byte-identical original. Its daily-learning source undercounts minutes and its F2P minute field has a type-import defect.
- `dashboard/customer_engagement_reviewed.twbx` fixes those two sources only. All ten reviewed Hyper extracts match the curated MySQL outputs. Layout, navigation, filters, historical entitlement logic and cohort calculations are preserved. Fresh visual rendering and high-resolution screenshot capture still require manual Tableau review.
- Embedded previews are **original, cropped 384 × 384 caches**, not newly rendered screenshots of the reviewed workbook. They cannot establish that corrected numbers are visible in the revised UI.

## 1. Platform Engagement

**Business question.** How many registered learners use the platform, and when does activity change?

**Metrics and methodology.** An active student-day is a record of lesson, quiz or exam activity. Count distinct students for population totals and distinct student-days for daily activity. Free/paid labels use the subscription interval valid on the activity date under the historical SQL rule. Monthly free and paid populations may overlap; their counts must not be added to obtain monthly unique people.

**Verified findings.** Of 37,490 registrations, 19,332 have an activity record (**51.56%**). Daily active learners averaged **784.67** during August 15–17, versus **278.14** during August 8–14. The source contains 68,340 student-days; one predates registration and is retained for historical reconciliation, but excluded from the separately labelled registration-retention extension.

**Interpretation and hypotheses.** The activity spike coincides with the documented free-access event. Temporary access could encourage exploration, but learner composition, weekday effects and concurrent marketing could also explain the change. Purchased subscription status does not encode the temporary campaign entitlement.

**Recommendation.** Evaluate event traffic by acquisition channel, subsequent return activity and fixed-window purchase incidence before expanding free-access campaigns. Track incremental outcomes in an experiment where feasible.

**Limitations.** No exposure assignments or counterfactual group are available. A before/after activity difference is not causal lift. The snapshot may not include every platform user.

Evidence: `sql/01_platform_engagement.sql`, `data/results/platform_kpis.tsv`, execution log `01_platform_engagement.tsv`. Tableau: Overview and Engagement Date/Month/Year.

## 2. User Activation & Retention — Core Analysis

**Business question.** Do new users engage at least once, and do initially active users return?

### Activation

The original onboarding query defines activation as **ever doing a tracked action by October 31**, grouped by registration month. It is not completion of a designed onboarding flow and not necessarily activity during the registration month. January activation is **1,846 / 3,366 = 54.84%**; October is **2,654 / 4,151 = 63.94%**. October has shorter available follow-up, while seasonality and acquisition mix differ. The data do not substantiate a causal claim that September 16 gamification improved activation; another campaign began September 19.

### Original status-entry cohorts

For each `(student_id, paid)` pair, find the first activity date in that status. Its calendar month names the cohort, while `TIMESTAMPDIFF(MONTH, first_activity, activity_date)` assigns **completed elapsed-month periods**, not calendar months. Denominator: distinct learners entering that status in that cohort month. Numerator: distinct members active in the same status during the given period. Period 0 includes all entrants by construction.

**Verified findings.** January free-status entrants have **46 / 1,540 = 2.99%** retention in period 1; January paid-status entrants have **132 / 255 = 51.76%**. January paid retention is **74 / 255 = 29.02%** in period 4 and **59 / 255 = 23.14%** in period 8. Thus the historical “near 30%” statement is a rough mid-horizon description, not a stable long-run plateau.

The September paid cohort has **87 / 246 = 35.37%** observed period-1 retention. **This period is not fully observed for all members**: late-September entrants' second elapsed-month window extends into November. The query exposes `full_window_observed`; do not rank this cohort against mature cohorts as evidence of deterioration. The same caveat applies to the final observed period of older cohorts.

**Interpretation.** Paid-status entrants show more persistent same-status activity. This does not identify the effect of paying: motivation, prior experience, access, purchase timing and status expiry all select these groups. The same person can enter both cohorts. The original **878** figure is the number of learners observed in both statuses; it is neither all purchasers nor necessarily a free-to-paid transition, because paid-to-free transitions also qualify.

### Clearly separated registration-cohort extension

To answer a different question—retention of **all signups**, including never-active users—SQL also groups by registration month and uses calendar-month activity. M0 is activation in that calendar month; M1 is activity in the next calendar month. Unobserved future periods are absent, not zero. The known preregistration event is excluded only here.

Across mature January–September cohorts, registration-weighted M1 activity is **8.79%**. This is not comparable to the original 2.99%/51.76% figures: denominator, cohort membership and time windows all differ. It is not wired into the preserved Tableau charts.

**Recommendation.** Test first-week learning plans and reminders, using a prospectively defined return window and randomized assignment. Track activation and later return separately. Do not treat paid/free differences as expected treatment uplift.

**Limitations.** Same-status activity is not subscription survival. Completed-month windows vary with start date and require explicit censoring. Tableau's ALL option can place one learner in different status-entry cohort months; it does not make those cohorts mutually exclusive registration groups. Filters and chart selection can alter the visible population.

Evidence: `sql/02_activation_retention.sql`; `activation.tsv`, `status_retention.tsv`, `registration_retention.tsv`. Tableau: Cohort Engagement and Engagement dashboards.

## 3. Content Consumption

**Business question.** How much content is watched, by whom, and how does engagement intensity vary?

**Metrics and methodology.** Sum all course-learning rows to student-day before attaching daily paid status. Divide by distinct watching learners in each status, not by all registrations or all active learners. A person may contribute to both status groups. For subscription duration, preserve the assignment's first-start to last-end span, capped at October 31; it includes gaps and uses date difference rather than inclusive covered days.

**Verified findings.** Correct total viewing is **1,917,374.91 minutes**. The historical daily-learning CSV—and its original Tableau Hyper extract—contains **1,557,591.77**, a shortfall of **359,783.14 minutes (18.76% of raw total)** affecting 12,181 student-days. The legacy query selected an unaggregated minute value inside a student-day group, losing additional learning rows.

Corrected free-status viewing is **473,815.52 minutes / 17,836 watching learners = 26.57 minutes per watcher**; paid-status viewing is **1,443,559.39 / 2,174 = 664.01**. These replace the historical approximate 21 / 543.7 figures only in the explicitly revised data version. They are not averages per learner-month or per registration. August free-status viewing is 146,430.99 minutes, compared with July's 33,361.41.

**Hypothesis and recommendation.** Broader course access and higher intent may contribute to more viewing under paid status. Explore relevance and early learning friction; test course recommendations rather than assuming that simply increasing minutes causes retention.

**Limitations.** Viewing time does not prove comprehension. Subscription span is not true paid exposure or lifetime value. The corrected source changes the Overview minutes KPI and Learning charts; original cached previews still represent old data.

Evidence: `sql/03_content_consumption.sql`, `content_summary.tsv`, `content_monthly.tsv`. Tableau: Overview, Student Learning and F2P, Student Learning and Subs.

## 4. Free-to-Paid Conversion — Core Analysis

**Business question.** How does the likelihood of any recorded purchase vary with content viewed before or on the first purchase date?

### Assignment definition and population

All **37,490** learners are included. `f2p=1` means at least one purchase record, including refunded purchases. For buyers, sum minutes from registration **through first purchase date inclusive**; for nonbuyers, use registration through October 31. Learners without qualifying viewing remain in the zero bucket. Exact assignment intervals are right-inclusive and do not overlap.

There are **2,338 purchasers (6.24%)**, of whom **1,146 purchased on registration day**. The label does not require an observed free learning stage. Date-only precision allows some purchase-day viewing to occur after payment.

### Verified bucket results

| Viewing minutes | Learners | Purchasers | Purchase incidence |
|---|---:|---:|---:|
| [0] | 18,771 | 563 | 3.00% |
| (0, 5] | 8,428 | 198 | 2.35% |
| (30, 40] | 1,036 | 160 | 15.44% |
| (100, 110] | 163 | 64 | 39.26% |
| (110, 120] | 138 | 63 | 45.65% |
| (120, 240] | 594 | 245 | 41.25% |
| (240, 480] | 186 | 30 | 16.13% |
| (480, 1000] | 49 | 3 | 6.12% |

The peak near 110–120 minutes is verified, but the curve is not monotonic and the high-minute tail is small. The SQL result table includes every populated assignment bucket. The original Tableau F2P Hyper extract has **18,524 null minute values caused by an integer import type**, while its bucket and purchase columns match the source CSV. Because the chart computes `SUM(f2p)/COUNTD(student_id)` against precomputed bucket labels, **the bucket rates remain valid**. The reviewed copy restores a real-valued minutes field with no missing values.

### Interpretation and a bounded extension

The bucket exposure window depends on the outcome: buyers stop accumulating minutes at purchase, while nonbuyers continue through cutoff. This design can itself create a nonmonotonic pattern. Prior motivation, course fit, pricing and different observation lengths remain uncontrolled. **“Make everyone watch 120 minutes” is not a supported recommendation.**

A separately labelled SQL extension gives each January–September registration cohort the same days 0–29 purchase window. **1,995 / 33,339 = 5.98%** purchase within that window. January is **9.15%**, August **3.10%**. October is excluded as a whole to avoid a partially eligible monthly cohort. This handles follow-up duration, not acquisition confounding, and it does not repair the original bucket exposure design. The extension is not displayed by the unchanged Tableau layout.

**Recommendation.** Test contextual upgrade prompts or relevant previews using only exposure known at the time of assignment—for example, a day-7 landmark among users still free. Randomize within eligible groups; measure later purchase with equal follow-up and monitor refunds and activity as guardrails.

**Limitations.** Purchase incidence is not net revenue or sustained subscription adoption. Bin sizes and censoring matter. No conversion uplift or optimal consumption threshold is estimated.

Evidence: `sql/04_f2p_conversion.sql`, `f2p_buckets.tsv`, `conversion_30day.tsv`. Tableau: Student Learning and F2P.

## 5. Course Engagement

**Business question.** Which courses attract the most viewing, and which deserve closer content-quality review?

**Metrics and methodology.** Course-level total minutes, distinct watchers, mean minutes per watcher, ratings count and mean rating. The assignment's `completion_rate` is mean watched minutes divided by course duration; the report calls it a **viewing-duration ratio**, not a probability of finishing.

**Verified findings.** Fifty of 56 catalog courses have learning records. The top five by total minutes—Introduction to Data and Data Science, SQL, Statistics, Introduction to Excel, and Python Programmer Bootcamp—account for **55.14%** of all viewing. Overall mean rating is **4.7946 / 5 across 2,731 ratings**. Introduction to Data and Data Science has 9,950 watchers and 297,197.71 minutes, but only 29.87 average minutes against 110.69 minutes of course duration.

**Interpretation and recommendation.** Foundational courses are high-reach locations for learning-path guidance. Review early stopping points using lesson-level progression before redesigning content. Combine viewing, ratings and denominator sizes; small courses should not be declared “best” solely from a high ratio or rating.

**Limitations.** Rewatching can push duration ratios above 100%; course length affects rankings; ratings are self-selected. Six courses are absent from historical inner-join results rather than proven to have zero quality. Overview date/status controls do not filter the lifetime course aggregate or one-column rating source.

Evidence: `sql/05_course_engagement.sql`, `courses.tsv`. Tableau: Overview chart selector and Top/Bottom 5 controls.

## 6. Exams & Certificates

**Business question.** How do assessment attempts and issued credentials reflect learning progress?

| Assessment type | Attempts | Distinct students | Passed attempts | Attempt pass rate |
|---|---:|---:|---:|---:|
| Practice | 29,748 | 4,031 | 21,009 | 70.62% |
| Course | 5,509 | 1,178 | 3,794 | 68.87% |
| Career track | 102 | 64 | 45 | 44.12% |

**Methodology and verified findings.** Each row in `student_exams` is an attempt. Pass rate divides passed attempts by all attempts, not by students. Issued credentials comprise **3,640 course certificates to 1,029 people**, and **43 career-track certificates to 39 people**. Multiple attempts and multiple credentials per learner explain why these counts differ.

**Hypothesis and recommendation.** More demanding final assessments or a selected learner population may explain the lower final-attempt pass rate. Review the assessment experience and offer targeted practice only after checking exam-level difficulty and repeat-attempt behavior.

**Limitations.** Attempt pass rate is not eventual learner success. The source dictionary describes pass in percentage language, while observed values and the assignment are binary 0/1; the query follows the actual binary field. Exam passing and certificate issuance are different events.

Evidence: `sql/06_learning_outcomes.sql`, `exam_summary.tsv`, `certificate_summary.tsv`. Tableau: Exams and Certificates; Exams and Funnel.

## 7. Career Track Funnel

**Business question.** At which observed stages do career-track participants become scarce?

**Methodology.** Preserve distinct-student reach per track across five historical stages. The original saved query omits “Attempted a final exam”; the CSV and Tableau include it. The curated SQL restores that stage. It does not require that each event occurred after enrollment or that stages occurred in sequence, and passing one course exam does not imply completing all required courses.

| Track | Enrolled | Attempted course exam | Passed course exam | Attempted final exam | Passed final / historical credential stage |
|---|---:|---:|---:|---:|---:|
| Data Scientist (1) | 2,999 | 406 | 365 | 24 | 16 |
| Data Analyst (2) | 3,915 | 339 | 323 | 33 | 15 |
| Business Analyst (3) | 960 | 183 | 168 | 17 | 12 |

**Verified findings.** There are **7,874 learner-track enrollments among 6,876 distinct people**. Summing final-stage counts gives 43 learner-track successes (**0.55% of enrollments**), matching 43 issued career certificates in aggregate and per track; these counts do not independently prove person-level event alignment. Course-exam reach is 13.54%, 8.66% and 19.06% of enrolled students for tracks 1–3. Final-stage reach is 0.53%, 0.38% and 1.25% respectively.

**Interpretation and recommendation.** Much of the observed drop occurs before a first course-exam attempt. Examine track expectations, progress visibility and the transition from learning to assessment. The enrollment population is broad and follow-up differs; these rates are not a time-adjusted sequential conversion funnel.

**Limitations.** A learner can enroll in multiple tracks. The historical credential stage is derived from a final exam pass; actual issuance is audited separately. Counts are not artificially adjusted to satisfy a monotonic funnel requirement. A future chronological funnel needs enrollment-time eligibility, ordered events and equal follow-up.

Evidence: `sql/07_career_track_funnel.sql`, `career_track_funnel.tsv`. Tableau: Exams and Funnel.

## Prioritized decisions and next steps

1. **Improve repeat learning:** test a short onboarding learning plan and reminders; measure a prospectively defined return window rather than relying on same-status group differences.
2. **Evaluate conversion prompts experimentally:** use fixed pre-outcome exposure and equal follow-up; monitor refunds and engagement alongside purchases.
3. **Investigate campaign quality:** add acquisition and exposure logs before attributing the August/September patterns to campaigns or gamification.
4. **Keep the reporting contract stable:** use corrected daily minutes and decimal F2P minutes, retain original files, and document historical versus alternative entitlement rules.
5. **Finish the public presentation:** visually revalidate the reviewed Tableau copy, export full-resolution dashboards, and confirm redistribution rights before any public upload.

No complex model or causal effect estimate is needed to justify these next steps. The project remains SQL + Tableau; Python helpers are optional comparison and packaging utilities, not implementations of the business analysis.
