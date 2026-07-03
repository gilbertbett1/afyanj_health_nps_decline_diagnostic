import os
from urllib.parse import quote_plus

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()

DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT", "3306")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = quote_plus(os.getenv("DB_PASSWORD", ""))
DB_NAME = os.getenv("DB_NAME")

EMR_CSV_PATH = "data/emr_clinic_visits.csv"
NPS_CSV_PATH = "data/sms_nps_feedback.csv"

engine = create_engine(
    f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

# Read CSV files
df_emr = pd.read_csv(EMR_CSV_PATH)
df_nps = pd.read_csv(NPS_CSV_PATH)

# Clean string fields
df_emr["visit_id"] = df_emr["visit_id"].astype(str).str.strip()
df_emr["patient_id"] = df_emr["patient_id"].astype(str).str.strip()
df_emr["branch"] = df_emr["branch"].astype(str).str.strip()

df_nps["visit_id"] = df_nps["visit_id"].astype(str).str.strip()
df_nps["customer_comment"] = df_nps["customer_comment"].astype("string")

# Parse datetime columns
emr_datetime_cols = [
    "checkin_time",
    "triage_start",
    "consult_start",
    "lab_start",
    "pharmacy_start",
    "checkout_time"
]

for col in emr_datetime_cols:
    df_emr[col] = pd.to_datetime(df_emr[col], errors="coerce")

# Truncate tables before reloading
with engine.begin() as conn:
    conn.execute(text("SET FOREIGN_KEY_CHECKS = 0;"))
    conn.execute(text("TRUNCATE TABLE sms_nps_feedback;"))
    conn.execute(text("TRUNCATE TABLE emr_clinic_visits;"))
    conn.execute(text("SET FOREIGN_KEY_CHECKS = 1;"))

# Load data into MySQL
df_emr.to_sql(
    name="emr_clinic_visits",
    con=engine,
    if_exists="append",
    index=False,
    chunksize=1000,
    method="multi"
)

df_nps.to_sql(
    name="sms_nps_feedback",
    con=engine,
    if_exists="append",
    index=False,
    chunksize=1000,
    method="multi"
)

# Validate row counts
with engine.connect() as conn:
    emr_count = conn.execute(text("SELECT COUNT(*) FROM emr_clinic_visits")).scalar()
    nps_count = conn.execute(text("SELECT COUNT(*) FROM sms_nps_feedback")).scalar()


# Check that the DB counts match the DataFrame rows exactly
assert emr_count == len(df_emr), f"EMR Count Mismatch! DF: {len(df_emr)}, DB: {emr_count}"
assert nps_count == len(df_nps), f"NPS Count Mismatch! DF: {len(df_nps)}, DB: {nps_count}"

print(f"Success! Successfully loaded {emr_count} EMR rows and {nps_count} NPS rows.")