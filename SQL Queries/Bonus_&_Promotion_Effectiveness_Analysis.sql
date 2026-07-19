# Bonus & Promotion Effectiveness Analysis

#Business Objective

#Evaluate the effectiveness of bonus campaigns in driving player activity, betting behavior, and revenue generation.

#This module answers:

#How much bonus was distributed?
#Which bonus products received the highest investment?
#Which bonus campaigns generated the highest betting activity?
#Which bonus campaigns produced the highest Net Gaming Revenue?
#Which players received the largest bonuses?
#Is there a relationship between bonus cost and betting volume?
#Which bonus campaigns delivered the best return?


#Overall Bonus Distribution

SELECT
COUNT(DISTINCT player_id) AS bonus_players,
ROUND(SUM(bonus_cost),2) AS total_bonus_cost,
ROUND(AVG(bonus_cost),2) AS avg_bonus_cost
FROM `customer-churn-analysis-502804.Customer_churn_analysis.bonus`;

#bonus_players	total_bonus_cost	avg_bonus_cost
#   100749	       23475538.45	      113.37

#Monthly Bonus Distribution

SELECT
activity_month,
COUNT(DISTINCT player_id) AS Total_players,
ROUND(SUM(bonus_cost),2) AS total_bonus,
ROUND(AVG(bonus_cost),2) AS avg_bonus
FROM `customer-churn-analysis-502804.Customer_churn_analysis.bonus`
GROUP BY activity_month
ORDER BY activity_month;


# Bonus Product Performance
SELECT
bonus_product,
COUNT(DISTINCT player_id) AS total_players,
ROUND(SUM(bonus_cost),2) AS total_bonus,
ROUND(AVG(bonus_cost),2) AS avg_bonus
FROM `customer-churn-analysis-502804.Customer_churn_analysis.bonus`
GROUP BY bonus_product
ORDER BY total_bonus DESC;

#Bonus Cost vs Betting Volume

SELECT
b.bonus_product,
COUNT(DISTINCT b.player_id) AS players,
ROUND(SUM(b.bonus_cost),2) AS total_bonus,
ROUND(SUM(pa.bet_amount),2) AS total_bets,
ROUND(AVG(pa.bet_amount),2) AS avg_bet
FROM `customer-churn-analysis-502804.Customer_churn_analysis.bonus` b
LEFT JOIN `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity` pa
ON b.player_id = pa.player_id
GROUP BY b.bonus_product
ORDER BY total_bets DESC;


#Bonus Cost vs Net Gaming Revenue

SELECT
b.bonus_product,
ROUND(SUM(b.bonus_cost),2) AS total_bonus,
ROUND(SUM(pa.net_gross_win),2) AS total_ngr,
ROUND(SUM(pa.net_gross_win)/ NULLIF(SUM(b.bonus_cost),0),2) AS ngr_per_bonus
FROM `customer-churn-analysis-502804.Customer_churn_analysis.bonus` b
LEFT JOIN `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity` pa
ON b.player_id = pa.player_id
GROUP BY b.bonus_product
ORDER BY total_ngr DESC;


#Top 20 Players Receiving Bonuses
SELECT
player_id,
ROUND(SUM(bonus_cost),2) AS total_bonus
FROM `customer-churn-analysis-502804.Customer_churn_analysis.bonus`
GROUP BY player_id
ORDER BY total_bonus DESC
LIMIT 20;


#Bonus Recipients vs Non-Recipients

SELECT
CASE
    WHEN b.player_id IS NOT NULL THEN 'Received Bonus'
    ELSE 'No Bonus'
END AS bonus_status,
COUNT(DISTINCT pa.player_id) AS active_players,
ROUND(AVG(pa.bet_amount),2) AS avg_bet,
ROUND(AVG(pa.net_gross_win),2) AS avg_ngr
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity` pa
LEFT JOIN
`customer-churn-analysis-502804.Customer_churn_analysis.bonus` b
ON pa.player_id=b.player_id
GROUP BY bonus_status;



# Bonus Efficiency Ranking

SELECT
bonus_product,
ROUND(SUM(bonus_cost),2) AS bonus_spend,
ROUND(SUM(pa.net_gross_win),2) AS total_ngr,
ROUND(SUM(pa.net_gross_win)/ NULLIF(SUM(bonus_cost),0),2) AS roi
FROM `customer-churn-analysis-502804.Customer_churn_analysis.bonus` b
LEFT JOIN
`customer-churn-analysis-502804.Customer_churn_analysis.playeractivity` pa
ON b.player_id=pa.player_id
GROUP BY bonus_product
ORDER BY roi DESC;


#Monthly Bonus ROI
SELECT
b.activity_month,
ROUND(SUM(b.bonus_cost),2) AS bonus_cost,
ROUND(SUM(pa.net_gross_win),2) AS revenue,
ROUND(SUM(pa.net_gross_win)/ NULLIF(SUM(b.bonus_cost),0),2) AS roi
FROM `customer-churn-analysis-502804.Customer_churn_analysis.bonus` b
LEFT JOIN
`customer-churn-analysis-502804.Customer_churn_analysis.playeractivity` pa
ON b.player_id=pa.player_id
AND b.activity_month=pa.activity_month
GROUP BY b.activity_month
ORDER BY b.activity_month;


# High Bonus Players

WITH player_bonus AS (
SELECT
b.player_id,
ROUND(SUM(bonus_cost),2) bonus_received,
ROUND(SUM(pa.bet_amount),2) total_bets,
ROUND(SUM(pa.net_gross_win),2) total_ngr
FROM `customer-churn-analysis-502804.Customer_churn_analysis.bonus` b
LEFT JOIN
`customer-churn-analysis-502804.Customer_churn_analysis.playeractivity` pa
ON b.player_id=pa.player_id
GROUP BY player_id)
SELECT *
FROM player_bonus
ORDER BY bonus_received DESC
LIMIT 20;

