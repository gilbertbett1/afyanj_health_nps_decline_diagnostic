CREATE DATABASE IF NOT EXISTS afyanj_health_analytics
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE afyanj_health_analytics;

CREATE TABLE IF NOT EXISTS emr_clinic_visits (
    visit_id VARCHAR(20) NOT NULL PRIMARY KEY,
    patient_id VARCHAR(12) NOT NULL,
    branch VARCHAR(20) NOT NULL,
    checkin_time DATETIME NOT NULL,
    triage_start DATETIME NOT NULL,
    consult_start DATETIME NOT NULL,
    lab_start DATETIME NULL,
    pharmacy_start DATETIME NULL,
    checkout_time DATETIME NULL
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS sms_nps_feedback (
    survey_id INT NOT NULL PRIMARY KEY,
    visit_id VARCHAR(20) NOT NULL,
    nps_score INT NULL,
    customer_comment  TEXT NULL,
    CONSTRAINT fk_sms_visit
        FOREIGN KEY (visit_id) REFERENCES emr_clinic_visits(visit_id)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;