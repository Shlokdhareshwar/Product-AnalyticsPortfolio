create database abtest;
use abtest;
CREATE TABLE ab_test_data (
    user_id INT,
    group_name VARCHAR(10),
    page_version VARCHAR(10),
    clicked INT,
    purchased INT,
    time_on_page FLOAT,
    country VARCHAR(50)
);
SELECT COUNT(*) FROM ab_test_data;

SELECT COUNT(*) AS total_users
FROM ab_test_data;

SELECT 
    group_name, 
    COUNT(*) AS users
FROM ab_test_data
GROUP BY group_name;

SELECT 
    country, 
    COUNT(*) AS users
FROM ab_test_data
GROUP BY country
ORDER BY users DESC;

SELECT * 
FROM ab_test_data
LIMIT 10;

SELECT 
    SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) AS null_user_id,
    SUM(CASE WHEN group_name IS NULL THEN 1 ELSE 0 END) AS null_group,
    SUM(CASE WHEN page_version IS NULL THEN 1 ELSE 0 END) AS null_page,
    SUM(CASE WHEN clicked IS NULL THEN 1 ELSE 0 END) AS null_clicked,
    SUM(CASE WHEN purchased IS NULL THEN 1 ELSE 0 END) AS null_purchased,
    SUM(CASE WHEN time_on_page IS NULL THEN 1 ELSE 0 END) AS null_time,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS null_country
FROM ab_test_data;

SELECT user_id, COUNT(*) AS occurrences
FROM ab_test_data
GROUP BY user_id
HAVING COUNT(*) > 1;

SELECT DISTINCT group_name, page_version
FROM ab_test_data;

SELECT 
    group_name,
    COUNT(*) AS total_users,
    SUM(clicked) AS total_clicks,
    ROUND(100.0 * SUM(clicked) / COUNT(*), 2) AS ctr_percentage
FROM ab_test_data
GROUP BY group_name;

SELECT 
    group_name,
    COUNT(*) AS total_users,
    SUM(purchased) AS total_purchases,
    ROUND(100.0 * SUM(purchased) / COUNT(*), 2) AS conversion_rate_percentage
FROM ab_test_data
GROUP BY group_name;

SELECT 
    group_name,
    SUM(clicked) AS total_clicks,
    SUM(purchased) AS total_purchases,
    100.0 * SUM(purchased) / SUM(clicked) AS click_to_purchase_rate
FROM ab_test_data
GROUP BY group_name;
