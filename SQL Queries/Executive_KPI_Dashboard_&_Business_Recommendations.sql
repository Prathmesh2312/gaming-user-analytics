#Executive KPI Dashboard & Business Recommendations

#Business Objective

#Provide executive-level KPIs that summarize customer acquisition, engagement, revenue, profitability, and retention to support strategic business decisions.

#This module answers:

#What are the platform's most important KPIs?
#How healthy is the acquisition funnel?
#How profitable is the platform?
#Which acquisition channels create the highest-value customers?
#What recommendations should management implement?


#Executive KPI Summary

SELECT

-- Acquisition

(SELECT COUNT(DISTINCT player_id)
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails`)
AS Registered_Players,

-- Depositors
(SELECT COUNT(DISTINCT player_id)
FROM `customer-churn-analysis-502804.Customer_churn_analysis.firstdeposit`
WHERE first_deposit_date IS NOT NULL)
AS First_Depositors,

-- First Bet (30 Days)

( SELECT COUNT(DISTINCT fb.player_id)
FROM `customer-churn-analysis-502804.Customer_churn_analysis.firstbet` fb
JOIN `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails` pd

ON fb.player_id=SAFE_CAST(pd.player_id AS INT64)
WHERE DATE_DIFF( DATE(fb.first_bet_datetime),DATE(pd.signup_date),DAY) BETWEEN 0 AND 30)AS First_Bettors_30D,

-- Active Players

( SELECT COUNT(DISTINCT player_id)
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
WHERE player_active_days>0)AS Active_Players;




#Executive Revenue KPIs

SELECT
ROUND(SUM(bet_amount),2) Total_Bet,
ROUND(SUM(win_amount),2) Total_Win,
ROUND(SUM(gross_win),2) Gross_Gaming_Revenue,
ROUND(SUM(net_gross_win),2) Net_Gaming_Revenue,
ROUND(SUM(net_gross_win)/COUNT(DISTINCT player_id),2)AS ARPU
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`;


#Executive Conversion KPIs
SELECT
ROUND(
100*
(
SELECT COUNT(DISTINCT player_id)
FROM `customer-churn-analysis-502804.Customer_churn_analysis.firstdeposit`
WHERE first_deposit_date IS NOT NULL
)
/
(
SELECT COUNT(DISTINCT player_id)
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails`
)
,2)
AS Deposit_Conversion,
ROUND(
100*
(
SELECT COUNT(DISTINCT fb.player_id)
FROM `customer-churn-analysis-502804.Customer_churn_analysis.firstbet` fb
JOIN `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails` pd
ON fb.player_id=SAFE_CAST(pd.player_id AS INT64)
WHERE DATE_DIFF(DATE(fb.first_bet_datetime),DATE(pd.signup_date),DAY)BETWEEN 0 AND 30 )/(SELECT COUNT(DISTINCT player_id) FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails`),2) AS Bet_Conversion;



#Top Acquisition Channels
SELECT
pd.acquisition_channel,
COUNT(DISTINCT pa.player_id) active_players,
ROUND(SUM(pa.bet_amount),2) total_bets,
ROUND(SUM(pa.net_gross_win),2) total_ngr,
ROUND(AVG(pa.net_gross_win),2) avg_ngr
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails` pd
JOIN `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity` pa
ON SAFE_CAST(pd.player_id AS INT64)=pa.player_id
GROUP BY acquisition_channel
ORDER BY total_ngr DESC;



#Top Products
SELECT
product,
ROUND(SUM(bet_amount),2) Total_Bets,
ROUND(SUM(net_gross_win),2) Total_NGR,
ROUND(SUM(net_gross_win)/SUM(bet_amount)*100,2)Revenue_Margin
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
GROUP BY product
ORDER BY Total_NGR DESC;


#VIP Contribution

WITH player_revenue AS (
SELECT
player_id,
SUM(net_gross_win) revenue
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
GROUP BY player_id
),
ranked AS (
SELECT
*,
NTILE(10) OVER(ORDER BY revenue DESC) revenue_decile
FROM player_revenue
)
SELECT
revenue_decile,
COUNT(*) players,
ROUND(SUM(revenue),2) total_revenue,
ROUND(AVG(revenue),2) avg_revenue
FROM ranked
GROUP BY revenue_decile
ORDER BY revenue_decile;



#Executive Scorecard
SELECT
ROUND(SUM(net_gross_win)/SUM(bet_amount)*100,2)AS House_Edge,
ROUND(SUM(net_gross_win)/COUNT(DISTINCT player_id),2)AS Revenue_Per_Player,
ROUND(AVG(player_active_days),2)AS Avg_Active_Days
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`;