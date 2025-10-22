create database churn;
use churn;
CREATE TABLE customer_transactions (
  customer_id VARCHAR(20),
  transaction_date DATE,
  transaction_value DECIMAL(10,2)
);
select * from customer_transactions;

SELECT MAX(transaction_date) AS max_date FROM customer_transactions;

SELECT
    customer_id,
    DATEDIFF('2025-10-21', MAX(transaction_date)) AS recency,
    COUNT(transaction_date) AS frequency,
    SUM(transaction_value) AS monetary
FROM customer_transactions
GROUP BY customer_id;

SELECT
    customer_id,
    DATEDIFF('2025-10-21', MAX(transaction_date)) AS recency,
    COUNT(transaction_date) AS frequency,
    SUM(transaction_value) AS monetary,
    CASE
        WHEN DATEDIFF('2025-10-21', MAX(transaction_date)) >= 90 THEN 1
        ELSE 0
    END AS churn
FROM customer_transactions
GROUP BY customer_id;
