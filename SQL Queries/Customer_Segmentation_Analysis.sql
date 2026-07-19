#Customer Segmentation Analysis

#Business Objective

#Understand different player segments based on activity, betting behavior, revenue contribution, and engagement.

#This module answers:

#Who are the VIP players?
#Which players generate the highest revenue?
#Which players are the most active?
#Which players have the highest betting volume?
#How should customers be segmented?
#Which customer segment deserves marketing investment?


#Player Value Segmentation

WITH player_summary AS (
SELECT
player_id,
SUM(bet_amount) total_bet,
SUM(win_amount) total_win,
SUM(net_gross_win) total_ngr,
SUM(player_active_days) active_days
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
GROUP BY player_id)
SELECT  
CASE
  WHEN total_bet <100 THEN 'Low Value'
  WHEN total_bet BETWEEN 100 AND 1000 THEN 'Medium Value'
  WHEN total_bet BETWEEN 1001 AND 5000 THEN 'High Value'
  ELSE 'VIP'
END player_segment,
COUNT(*) players,
ROUND(AVG(total_bet),2) avg_bet,
ROUND(AVG(total_ngr),2) avg_ngr
FROM player_summary
GROUP BY player_segment
ORDER BY avg_bet DESC;



#Player Activity Segmentation
SELECT  
CASE
  WHEN player_active_days BETWEEN 1 AND 5 THEN 'Occasional'
  WHEN player_active_days BETWEEN 6 AND 15 THEN 'Regular'
  WHEN player_active_days BETWEEN 16 AND 25 THEN 'Frequent'
  ELSE 'Highly Active'
END activity_segment,
COUNT(DISTINCT player_id) players,
ROUND(AVG(bet_amount),2) avg_bet
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
GROUP BY activity_segment
ORDER BY players DESC;


#Top 50 VIP Players
SELECT
player_id,
ROUND(SUM(bet_amount),2) total_bets,
ROUND(SUM(net_gross_win),2) total_ngr,
SUM(player_active_days) active_days
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
GROUP BY player_id
ORDER BY total_ngr DESC
LIMIT 50;


#RFM-style Customer Segmentation
WITH customer_summary AS (
SELECT
player_id,
MAX(activity_month) last_activity,
COUNT(DISTINCT activity_month) active_months,
SUM(bet_amount) total_bets
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
GROUP BY player_id)
SELECT
player_id,
DATE_DIFF(CURRENT_DATE(),last_activity,DAY) recency,
active_months frequency,
ROUND(total_bets,2) monetary
FROM customer_summary;



#Customer Quartile Segmentation

WITH customer_value AS (
SELECT
player_id,
SUM(bet_amount) total_bets
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
GROUP BY player_id)
SELECT
player_id,
total_bets,
NTILE(4) OVER(ORDER BY total_bets DESC) spending_quartile
FROM customer_value
ORDER BY total_bets DESC;


#Acquisition Channel Quality
SELECT
pd.acquisition_channel,
COUNT(DISTINCT pa.player_id) players,
ROUND(AVG(pa.bet_amount),2) avg_bet,
ROUND(AVG(pa.net_gross_win),2) avg_ngr,
ROUND(SUM(pa.net_gross_win),2) total_ngr
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails` pd
JOIN `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity` pa
ON SAFE_CAST(pd.player_id AS INT64)=pa.player_id
GROUP BY acquisition_channel
ORDER BY total_ngr DESC;


#Gender-wise Customer Value
SELECT
pd.gender,
COUNT(DISTINCT pa.player_id) players,
ROUND(AVG(pa.bet_amount),2) avg_bet,
ROUND(AVG(pa.net_gross_win),2) avg_ngr,
ROUND(SUM(pa.net_gross_win),2) total_ngr
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails` pd
JOIN `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity` pa
ON SAFE_CAST(pd.player_id AS INT64)=pa.player_id
GROUP BY gender
ORDER BY total_ngr DESC;


#Age Group Value
WITH player_age AS (
SELECT
SAFE_CAST(player_id AS INT64) player_id,
CASE
  WHEN DATE_DIFF(CURRENT_DATE(), SAFE.PARSE_DATE('%Y-%m-%d', dob), YEAR) BETWEEN 18 AND 24 THEN '18-24'
  WHEN DATE_DIFF(CURRENT_DATE(), SAFE.PARSE_DATE('%Y-%m-%d', dob), YEAR) BETWEEN 25 AND 34 THEN '25-34'
  WHEN DATE_DIFF(CURRENT_DATE(), SAFE.PARSE_DATE('%Y-%m-%d', dob), YEAR) BETWEEN 35 AND 44 THEN '35-44'
  WHEN DATE_DIFF(CURRENT_DATE(), SAFE.PARSE_DATE('%Y-%m-%d', dob), YEAR) BETWEEN 45 AND 54 THEN '45-54'
  ELSE '55+'
END age_group
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails`)
SELECT
age_group,
COUNT(DISTINCT pa.player_id) players,
ROUND(AVG(pa.bet_amount),2) avg_bet,
ROUND(SUM(pa.net_gross_win),2) total_ngr
FROM player_age a
JOIN `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity` pa
ON a.player_id=pa.player_id
GROUP BY age_group
ORDER BY total_ngr DESC;



#High-Risk Players
SELECT
player_id,
SUM(player_active_days) active_days,
ROUND(SUM(net_gross_win),2) total_ngr
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
GROUP BY player_id
HAVING SUM(player_active_days)>20 AND SUM(net_gross_win)<0
ORDER BY total_ngr;


#Customer Lifetime Value (Proxy)
SELECT
player_id,
ROUND(SUM(net_gross_win),2) lifetime_value,
SUM(player_active_days) lifetime_active_days
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
GROUP BY player_id
ORDER BY lifetime_value DESC
LIMIT 50;