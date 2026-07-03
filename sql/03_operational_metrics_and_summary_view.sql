-- Operational Metrics View

CREATE OR REPLACE VIEW v_operational_metrics AS
SELECT
    visit_id,
    branch,
    checkin_time,
    DATE_FORMAT(checkin_time, '%Y-%m') AS visit_month,
    TIMESTAMPDIFF(MINUTE, checkin_time, triage_start) AS triage_wait_mins,
    TIMESTAMPDIFF(MINUTE, triage_start, consult_start) AS consult_wait_mins,
    CASE
        WHEN lab_start IS NOT NULL
        THEN TIMESTAMPDIFF(MINUTE, consult_start, lab_start)
        ELSE NULL
    END AS lab_wait_mins,
    TIMESTAMPDIFF(MINUTE, consult_start, pharmacy_start) AS lab_and_pharm_wait_mins,
    TIMESTAMPDIFF(MINUTE, pharmacy_start, checkout_time) AS pharmacy_to_exit_mins,
    TIMESTAMPDIFF(MINUTE, checkin_time, checkout_time) AS total_turnaround_mins,
    CASE WHEN lab_start IS NOT NULL THEN 'Yes' ELSE 'No' END AS had_lab_test
FROM v_clean_visits;


CREATE OR REPLACE VIEW v_abandonment_summary AS
SELECT
    branch,
    DATE_FORMAT(checkin_time, '%Y-%m') AS visit_month,
    COUNT(*) AS total_visits,
    SUM(CASE WHEN checkout_time IS NULL THEN 1 ELSE 0 END) AS abandoned_visits,
    ROUND(SUM(CASE WHEN checkout_time IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS abandonment_rate_pct
FROM emr_clinic_visits
GROUP BY branch, visit_month;