#Cohort & Retention Analysis
#Business Objective

#Measure how well players are retained over time after registration and identify which acquisition channels and cohorts produce the most loyal players.

#This module answers:

#Which signup cohorts retain players the longest?
#How many players return after their signup month?
#Which acquisition channels have the highest retention?
#Which cohorts generate the highest revenue?
#Which cohorts become high-value customers?


#Monthly Signup Cohorts
SELECT
DATE_TRUNC(DATE(signup_date), MONTH) AS signup_month,
COUNT(DISTINCT player_id) AS registered_players
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails`
GROUP BY signup_month
ORDER BY signup_month;



#Monthly Active Players by Cohort
SELECT
DATE_TRUNC(DATE(pd.signup_date), MONTH) AS signup_cohort,
pa.activity_month,
COUNT(DISTINCT pa.player_id) AS active_players
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails` pd
JOIN `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity` pa
ON SAFE_CAST(pd.player_id AS INT64)=pa.player_id
GROUP BY signup_cohort, activity_month
ORDER BY signup_cohort, activity_month;


#Cohort Retention Rate
WITH cohort AS (
  SELECT
    SAFE_CAST(player_id AS INT64) player_id,
    DATE_TRUNC(DATE(signup_date), MONTH) signup_month
  FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails`
),
cohort_sizes AS (
  SELECT 
    signup_month,
    COUNT(DISTINCT player_id) AS total_cohort_players
  FROM cohort
  GROUP BY signup_month
),
activity AS (
  SELECT
    player_id,
    activity_month
  FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
)

SELECT
  c.signup_month,
  a.activity_month,
  COUNT(DISTINCT a.player_id) AS retained_players,
  ROUND(100 * COUNT(DISTINCT a.player_id) / cs.total_cohort_players, 2) AS retention_rate
FROM cohort c
JOIN cohort_sizes cs 
  ON c.signup_month = cs.signup_month
LEFT JOIN activity a
  ON c.player_id = a.player_id
GROUP BY c.signup_month, a.activity_month, cs.total_cohort_players
ORDER BY c.signup_month, a.activity_month;



#Acquisition Channel Retention
SELECT
pd.acquisition_channel,
COUNT(DISTINCT pa.player_id) retained_players,
ROUND(AVG(pa.player_active_days),2) avg_active_days,
ROUND(AVG(pa.bet_amount),2) avg_bet,
ROUND(SUM(pa.net_gross_win),2) total_ngr
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails` pd
JOIN `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity` pa
ON SAFE_CAST(pd.player_id AS INT64)=pa.player_id
GROUP BY acquisition_channel
ORDER BY retained_players DESC;



#Cohort Revenue
SELECT
DATE_TRUNC(DATE(pd.signup_date),MONTH) signup_cohort,
ROUND(SUM(pa.bet_amount),2) total_bets,
ROUND(SUM(pa.net_gross_win),2) total_ngr
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails` pd
JOIN `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity` pa
ON SAFE_CAST(pd.player_id AS INT64)=pa.player_id
GROUP BY signup_cohort
ORDER BY signup_cohort;



#Average Active Days by Cohort
SELECT
DATE_TRUNC(DATE(pd.signup_date),MONTH) signup_cohort,
ROUND(AVG(pa.player_active_days),2) avg_active_days,
COUNT(DISTINCT pa.player_id) active_players
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails` pd
JOIN `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity` pa
ON SAFE_CAST(pd.player_id AS INT64)=pa.player_id
GROUP BY signup_cohort
ORDER BY signup_cohort;



#High-Value Cohorts
SELECT
DATE_TRUNC(DATE(pd.signup_date),MONTH) signup_cohort,
COUNT(DISTINCT pa.player_id) players,
ROUND(AVG(pa.net_gross_win),2) avg_ngr,
ROUND(SUM(pa.net_gross_win),2) total_ngr
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails` pd
JOIN `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity` pa
ON SAFE_CAST(pd.player_id AS INT64)=pa.player_id
GROUP BY signup_cohort
ORDER BY total_ngr DESC;



#Product Retention
SELECT
product,
COUNT(DISTINCT player_id) players,
ROUND(AVG(player_active_days),2) avg_active_days,
ROUND(AVG(net_gross_win),2) avg_ngr
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
GROUP BY product
ORDER BY avg_active_days DESC;


# Monthly Returning Players
SELECT
activity_month,
COUNT(DISTINCT player_id) returning_players
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
WHERE player_active_days>1
GROUP BY activity_month
ORDER BY activity_month;


# Best Acquisition Channel by Retention

SELECT
pd.acquisition_channel,
COUNT(DISTINCT pa.player_id) retained_players,
ROUND(AVG(pa.player_active_days),2) avg_days,
ROUND(SUM(pa.net_gross_win),2) total_ngr,
RANK() OVER(ORDER BY SUM(pa.net_gross_win) DESC) channel_rank
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails` pd
JOIN `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity` pa
ON SAFE_CAST(pd.player_id AS INT64)=pa.player_id
GROUP BY acquisition_channel
ORDER BY channel_rank;