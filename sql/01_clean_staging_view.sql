-- Clean Staging View

CREATE OR REPLACE VIEW v_clean_visits AS
SELECT
    visit_id,
    patient_id,
    branch,
    checkin_time,
    triage_start,
    consult_start,
    lab_start,
    pharmacy_start,
    checkout_time
FROM emr_clinic_visits
WHERE checkout_time IS NOT NULL          -- removes ghost sessions (walk-outs)
  AND consult_start >= triage_start;     -- removes clock sync lag