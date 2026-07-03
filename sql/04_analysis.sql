-- 1. Branch × Month Trend 

SELECT
    o.branch,
    o.visit_month,
    COUNT(DISTINCT o.visit_id) AS total_visits,
    ROUND(AVG(o.total_turnaround_mins), 1) AS avg_total_tat_mins,
    COUNT(n.nps_score) AS nps_responses,
    ROUND(AVG(n.nps_score), 1) AS avg_nps_score,
    ROUND(
        (SUM(CASE WHEN n.nps_score >= 9 THEN 1 ELSE 0 END) -
         SUM(CASE WHEN n.nps_score <= 6 THEN 1 ELSE 0 END))
        * 100.0 / NULLIF(COUNT(n.nps_score), 0), 1
    ) AS calculated_nps
FROM v_penda_operational_metrics o
LEFT JOIN sms_nps_feedback n ON o.visit_id = n.visit_id
GROUP BY o.branch, o.visit_month
ORDER BY o.branch, o.visit_month;

-- ------------------------------------------------------- 

-- 2. Stage-by-Stage Bottleneck Breakdown
SELECT
    branch,
    visit_month,
    ROUND(AVG(triage_wait_mins), 1) AS avg_triage_wait,
    ROUND(AVG(consult_wait_mins), 1) AS avg_consult_wait,
    ROUND(AVG(lab_wait_mins), 1) AS avg_lab_wait,
    ROUND(AVG(lab_and_pharm_wait_mins), 1) AS avg_lab_pharm_wait,
    ROUND(AVG(pharmacy_to_exit_mins), 1) AS avg_pharmacy_exit_wait,
    ROUND(AVG(total_turnaround_mins), 1) AS avg_total_tat
FROM v_penda_operational_metrics
GROUP BY branch, visit_month
ORDER BY branch, visit_month;

-- --------------------------------------------------------------


-- 3. Patient Abandonment Rate by Branch × Month

SELECT
    branch,
    DATE_FORMAT(checkin_time, '%Y-%m') AS visit_month,
    COUNT(*) AS total_visits,
    SUM(CASE WHEN checkout_time IS NULL THEN 1 ELSE 0 END) AS abandoned_visits,
    ROUND(SUM(CASE WHEN checkout_time IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS abandonment_rate_pct
FROM emr_clinic_visits
GROUP BY branch, visit_month
ORDER BY branch, visit_month;

-- ---------------------------------------------------------------

-- 4. NPS Tier Breakdown by Branch (full population)

SELECT
    e.branch,
    COUNT(CASE WHEN n.nps_score >= 9 THEN 1 END) AS promoters,
    COUNT(CASE WHEN n.nps_score BETWEEN 7 AND 8 THEN 1 END) AS passives,
    COUNT(CASE WHEN n.nps_score <= 6 THEN 1 END) AS detractors,
    COUNT(n.nps_score) AS total_responses,
    ROUND(
        (COUNT(CASE WHEN n.nps_score >= 9 THEN 1 END) -
         COUNT(CASE WHEN n.nps_score <= 6 THEN 1 END))
        * 100.0 / COUNT(n.nps_score), 1
    ) AS calculated_nps
FROM sms_nps_feedback n
JOIN emr_clinic_visits e ON n.visit_id = e.visit_id
GROUP BY e.branch
ORDER BY calculated_nps;

-- -----------------------------------------------------------------


