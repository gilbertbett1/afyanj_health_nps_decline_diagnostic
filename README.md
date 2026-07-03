# AfyaNJ Health NPS Decline Diagnostic

This portfolio project simulates a real business problem for a brick-and-click healthcare organization experiencing a decline in Net Promoter Score (NPS). It uses synthetic but realistic outpatient visit and SMS feedback data to diagnose the operational drivers of falling patient satisfaction.

## Project overview

The project is designed around a typical brick-and-click organization's-style outpatient environment in which operational throughput, patient experience, and subscription retention are closely linked. The analysis focuses on three high-volume clinics; Kawangware, Umoja, and Sunton, and investigates whether long turnaround times and queue bottlenecks are contributing to lower NPS.

## Business problem

A sustained drop in NPS can signal deteriorating patient experience, rising dissatisfaction, and greater churn risk in a competitive, price-sensitive healthcare market. In this project, the core business question is whether delays across the outpatient journey, especially inside lab and pharmacy workflows, are driving poor satisfaction outcomes.

## Objective

The goal of this project is to build an end-to-end analytics workflow that:

- Ingests raw outpatient visit and survey data.
- Cleans operational data quality issues such as ghost sessions and EMR clock lag.
- Calculates stage-by-stage patient wait times.
- Identifies the main operational bottleneck by branch and visit stage.
- Links operational delays directly to NPS outcomes.
- Produces actionable recommendations for clinic operations leaders.

## Dataset

The project uses two synthetic but realistic datasets linked by `visit_id`.

### 1. `emr_clinic_visits`
This table contains outpatient visit timestamps, including:

- `checkin_time`
- `triage_start`
- `consult_start`
- `lab_start`
- `pharmacy_start`
- `checkout_time`

### 2. `sms_nps_feedback`
This table contains post-visit SMS survey responses, including:

- `survey_id`
- `visit_id`
- `nps_score`
- `customer_comment`

## Tools and stack

- **Python** for synthetic data generation and flaw injection.
- **MySQL** for data cleaning, transformation, and SQL analysis.
- **Power BI** for KPI cards, heatmaps, scatter plots, and management dashboards.
- **GitHub** for version control and portfolio presentation.

## Data quality issues handled

The project intentionally includes realistic operational data issues to simulate production-like healthcare data challenges.

| Issue | Description | Treatment |
|------|-------------|-----------|
| Ghost sessions | Visits with missing `checkout_time` because a patient left before completion. | Filtered out in a clean staging view. |
| Clock sync lag | Cases where `consult_start` appears earlier than `triage_start` due to EMR sync issues. | Removed in the cleaned analytical view. |
| Missing lab events | Some visits do not require lab testing, so `lab_start` is null. | Preserved and handled conditionally in wait-time calculations. |

## Analysis workflow

The analytical workflow follows these steps:

1. Generate synthetic visit and NPS data using Python.
2. Load the raw CSV files into MySQL.
3. Audit and clean the data using SQL views.
4. Compute stage-by-stage operational metrics such as triage wait, consult wait, lab wait, and total turnaround time.
5. Aggregate branch performance against NPS outcomes.
6. Visualize the findings in Power BI for management use.

## Key findings

The analysis shows a clear divergence between branches. Kawangware and Umoja experienced rising total turnaround times from the mid-40 minute range in March to the low-70 minute range in May, while Sunton remained stable at about 45 minutes.

The main bottleneck is the lab-and-pharmacy stage, not triage or doctor consultation. In May, average lab-and-pharmacy wait time reached 48.9 minutes in Kawangware and 49.4 minutes in Umoja, compared with 21.3 minutes in Sunton.

NPS declined sharply where turnaround times increased. Kawangware’s average NPS score fell from 7.4 in March to 3.9 in May, while Umoja dropped from 7.1 to 4.0 over the same period; Sunton remained stable around 7.3 to 7.4.

Patient abandonment also worsened at the worst-performing branches. In May, abandonment reached 5.68% in Kawangware and 4.55% in Umoja, versus 1.02% in Sunton.

## Recommendations

Based on the analysis, the project recommends:

- Reallocating one lab technician from Sunton to Kawangware during peak demand windows, especially Fridays to Sundays from 16:00 to 19:30.
- Introducing an EMR red-flag alert for patients waiting more than 20 minutes in the lab queue.
- Creating a fast-track workflow for non-lab patients, who make up about half of visits.
- Running a weekly dashboard review to monitor branches exceeding the 45-minute turnaround target.

## Repository structure

```text
afyanj_health_nps_decline_diagnostic/
|
|-- data/
│   |-- emr_clinic_visits.csv
│   |__ sms_nps_feedback.csv
│
|-- sql/
│   |-- 00_create_db_tables.sql
│   |-- 01_clean_staging_view.sql
│   |-- 02_data_quality_audit.sql
│   |-- 03_operational_metrics_and_summary_view.sql
│   |-- 04_analysis.sql
│
|-- powerbi/
│   |-- afyanj_dash.pbix
    |__afyanj_dash.pdf
│
|-- README.md
```

## Dashboard outputs

The Power BI dashboard is designed as a single-page management view with:

- KPI cards for average turnaround time, global NPS, total visits tracked, and visits over 60 minutes.
- A bottleneck heatmap by branch and visit stage.
- A scatter plot showing the relationship between total turnaround time and NPS score.
- A peak-hour bar chart to identify staffing pressure windows.

## Why this project matters

This project demonstrates how healthcare operations analytics can move beyond reporting and support practical decision-making. It connects patient experience metrics to operational flow, showing how queue design, staffing, and EMR visibility can influence satisfaction and retention.

## Disclaimer

This is a speculative portfolio project built with synthetic data for learning and demonstration purposes. It is designed to reflect realistic outpatient operational patterns and analytics workflows, but it does not use real patient data.