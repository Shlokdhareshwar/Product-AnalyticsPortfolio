CREATE DATABASE IF NOT EXISTS analytics;
USE analytics;

CREATE TABLE cohort (
  user_id VARCHAR(32),
  signup_date DATE,
  active_date DATE
);

SELECT COUNT(*) AS numberofrows, COUNT(DISTINCT user_id) AS unique_users FROM cohort;
SELECT MIN(signup_date) AS first_signup, MAX(signup_date) AS last_signup FROM cohort;
SELECT MIN(active_date) AS first_active, MAX(active_date) AS last_active FROM cohort;

WITH base AS (
    SELECT
        user_id,
        DATE_FORMAT(signup_date, '%Y-%m-01') AS cohort_month,
        DATE_FORMAT(active_date, '%Y-%m-01') AS active_month
    FROM cohort
),
indexed AS (
    SELECT
        user_id,
        cohort_month,
        active_month,
        PERIOD_DIFF(
            DATE_FORMAT(active_month, '%Y%m'),
            DATE_FORMAT(cohort_month, '%Y%m')
        ) AS cohort_index
    FROM base
)
SELECT
    cohort_month,
    cohort_index,
    COUNT(DISTINCT user_id) AS users
FROM indexed
GROUP BY 1,2
ORDER BY 1,2;

