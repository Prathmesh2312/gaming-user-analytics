#Deposit Conversion Analysis
#Business Objective
#Understand:

#1) How many registered users made their first deposit?
#2) Which acquisition channels drive depositing users?
#3) Which advertisers bring high-value customers?
#4) Which deposit methods and channels are most effective?
#5) How much revenue comes from first deposits?

#Total Depositors -How many registered players made their first deposit?
SELECT
COUNT(DISTINCT player_id) AS total_depositors
FROM `customer-churn-analysis-502804.Customer_churn_analysis.firstdeposit`
WHERE first_deposit_date IS NOT NULL;
# 127261 users has made deposit.

#Registration → Deposit Conversion Rate - What percentage of registered players completed their first deposit?
-- Registration → First Deposit Conversion Rate

SELECT
    -- Players who actually made a first deposit
    (
        SELECT COUNT(DISTINCT player_id)
        FROM `customer-churn-analysis-502804.Customer_churn_analysis.firstdeposit`
        WHERE first_deposit_date IS NOT NULL
    ) AS depositors,

    -- Total registered players
    (
        SELECT COUNT(DISTINCT player_id)
        FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails`
    ) AS registered_players,

    -- Conversion Rate
    ROUND(
        100 *
        (
            SELECT COUNT(DISTINCT player_id)
            FROM `customer-churn-analysis-502804.Customer_churn_analysis.firstdeposit`
            WHERE first_deposit_date IS NOT NULL
        )
        /
        (
            SELECT COUNT(DISTINCT player_id)
            FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails`
        ),
    2) AS conversion_rate;

#127261 43.47% of players has made his deposit.



#Monthly First Deposits -How many users made their first deposit each month?

SELECT
DATE_TRUNC(DATE(first_deposit_date), MONTH) AS deposit_month,
COUNT(DISTINCT player_id) AS depositors
FROM `customer-churn-analysis-502804.Customer_churn_analysis.firstdeposit`
WHERE first_deposit_date IS NOT NULL
GROUP BY deposit_month
ORDER BY deposit_month;


#Deposit Revenue by Month - How much first deposit revenue was generated each month?
SELECT
DATE_TRUNC(DATE(first_deposit_date), MONTH) AS deposit_month,
ROUND(SUM(first_deposit_amount),2) AS total_deposit,
ROUND(AVG(first_deposit_amount),2) AS average_deposit
FROM `customer-churn-analysis-502804.Customer_churn_analysis.firstdeposit`
WHERE first_deposit_date IS NOT NULL
GROUP BY deposit_month
ORDER BY deposit_month;


#Deposit Method Performance - Which payment methods are used most often?

SELECT
first_deposit_method,
COUNT(first_deposit_amount) AS total_transactions,
ROUND(SUM(first_deposit_amount),2) AS total_deposit,
ROUND(AVG(first_deposit_amount),2) AS avg_deposit
FROM `customer-churn-analysis-502804.Customer_churn_analysis.firstdeposit`
WHERE first_deposit_date IS NOT NULL
GROUP BY first_deposit_method
ORDER BY total_deposit DESC;

#visa has made most of the deposits


#Deposit Channel Performance- Which deposit channels generate the highest revenue?

SELECT
first_deposit_channel,
COUNT(first_deposit_amount) AS deposits,
ROUND(SUM(first_deposit_amount),2) AS total_amount,
ROUND(AVG(first_deposit_amount),2) AS avg_amount
FROM `customer-churn-analysis-502804.Customer_churn_analysis.firstdeposit`
WHERE first_deposit_date IS NOT NULL
GROUP BY first_deposit_channel
ORDER BY total_amount DESC;
#most of the deposits are done from online channnel.



#Acquisition Channel vs Deposit Conversion - Which acquisition channels convert users into depositors most effectively?

SELECT
    p.acquisition_channel,
    COUNT(DISTINCT p.player_id) AS registered_players,
    COUNT(DISTINCT CASE
        WHEN d.first_deposit_date IS NOT NULL THEN d.player_id
    END) AS depositors,
    ROUND( 100 * COUNT(DISTINCT CASE WHEN d.first_deposit_date IS NOT NULL THEN d.player_id END)/COUNT(DISTINCT p.player_id),2) AS conversion_rate
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails` p
LEFT JOIN `customer-churn-analysis-502804.Customer_churn_analysis.firstdeposit` d
ON p.player_id = CAST(d.player_id AS STRING)
GROUP BY p.acquisition_channel
ORDER BY conversion_rate DESC;



#Advertiser Performance - Which advertisers generate the highest first deposit revenue?

SELECT
p.advertiser_id,
COUNT(DISTINCT d.player_id) AS depositors,
ROUND(SUM(d.first_deposit_amount),2) AS total_deposit,
ROUND(AVG(d.first_deposit_amount),2) AS avg_deposit
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails` p
INNER JOIN `customer-churn-analysis-502804.Customer_churn_analysis.firstdeposit` d
ON p.player_id = CAST(d.player_id AS STRING)
WHERE d.first_deposit_date IS NOT NULL
GROUP BY p.advertiser_id
ORDER BY total_deposit DESC
LIMIT 10;


# Average Days to First Deposit - How long does it take users to make their first deposit after signup?
SELECT
ROUND(AVG(TIMESTAMP_DIFF(d.first_deposit_date,p.signup_date,DAY)),2) AS avg_days_to_first_deposit
FROM
`customer-churn-analysis-502804.Customer_churn_analysis.playerdetails` p
JOIN
`customer-churn-analysis-502804.Customer_churn_analysis.firstdeposit` d
ON p.player_id = CAST(d.player_id AS STRING)
WHERE d.first_deposit_date IS NOT NULL;
#after signup user required average 23 days to make his first deposit.



#Top 20 Highest First Deposits - Who are the highest-value first-time depositors?
SELECT
d.player_id,
p.acquisition_channel,
p.advertiser_id,
d.first_deposit_amount,
d.first_deposit_method,
d.first_deposit_channel
FROM
`customer-churn-analysis-502804.Customer_churn_analysis.firstdeposit` d
JOIN
`customer-churn-analysis-502804.Customer_churn_analysis.playerdetails` p
ON CAST(d.player_id AS STRING)=p.player_id
WHERE d.first_deposit_date IS NOT NULL
ORDER BY first_deposit_amount DESC
LIMIT 20;