USE afyanj_health_analytics;

-- Data Quality Audit 
SELECT
    COUNT(*) AS total_visits,
    SUM(CASE WHEN checkout_time IS NULL THEN 1 ELSE 0 END) AS ghost_sessions,
    SUM(CASE WHEN consult_start < triage_start THEN 1 ELSE 0 END) AS clock_sync_errors,
    SUM(CASE WHEN lab_start IS NULL THEN 1 ELSE 0 END) AS no_lab_required,
    MIN(checkin_time) AS earliest_visit,
    MAX(checkin_time) AS latest_visit
FROM emr_clinic_visits;