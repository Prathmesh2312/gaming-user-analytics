#Player Engagement & Retention Analysis

#Business Objective

#This module evaluates how engaged players become after registration and identifies behavioral patterns that influence long-term customer value.

#It answers:

#How active are players after joining?
#How frequently do players engage with the platform?
#Which products generate the highest engagement?
#Which players contribute the highest betting volume?
#Which products generate the highest Net Gaming Revenue (NGR)?
#How do bonus campaigns influence player engagement?
#Which player segments are most valuable?


#Active Players
SELECT
COUNT(DISTINCT player_id) AS active_players
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
WHERE player_active_days > 0;

#167327 players remained active, indicating that more than half of registered users engaged with the platform after registration.


# Active Days Distribution
SELECT
CASE
      WHEN player_active_days BETWEEN 1 AND 5 THEN '1-5 Days'
      WHEN player_active_days BETWEEN 6 AND 10 THEN '6-10 Days'
      WHEN player_active_days BETWEEN 11 AND 20 THEN '11-20 Days' ELSE '20+ Days'
END AS activity_segment,
COUNT(DISTINCT player_id) players,
ROUND(AVG(bet_amount),2) avg_bet_amount,
ROUND(AVG(net_gross_win),2) avg_net_gross_win
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
WHERE player_active_days>0
GROUP BY activity_segment
ORDER BY players DESC;

#Monthly Active Players
SELECT
activity_month,
COUNT(DISTINCT player_id) active_players
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
GROUP BY activity_month
ORDER BY activity_month;


#Product Performance
SELECT
product,
COUNT(DISTINCT player_id) players,
ROUND(SUM(bet_amount),2) total_bet_amount,
ROUND(SUM(win_amount),2) total_win_amount,
ROUND(SUM(net_gross_win),2) total_net_gross_win,
ROUND(AVG(net_gross_win),2) avg_net_gross_win
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
GROUP BY product
ORDER BY total_net_gross_win DESC;



#Subproduct Performance

SELECT
subproduct,
COUNT(DISTINCT player_id) players,
ROUND(SUM(bet_amount),2) total_bet_amount,
ROUND(SUM(net_gross_win),2) total_net_gross_win
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
GROUP BY subproduct
ORDER BY total_net_gross_win DESC;



# Top 20 High Value Players

SELECT
player_id,
ROUND(SUM(bet_amount),2) total_bets,
ROUND(SUM(win_amount),2) total_wins,
ROUND(SUM(net_gross_win),2) net_gaming_revenue,
SUM(player_active_days) active_days
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
GROUP BY player_id
ORDER BY total_bets DESC
LIMIT 20;



# Betting vs Winning

SELECT
ROUND(SUM(bet_amount),2) total_bets,
ROUND(SUM(win_amount),2) total_winnings,
ROUND(SUM(gross_win),2) gross_win,
ROUND(SUM(net_gross_win),2) net_gaming_revenue
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`;


# Bonus Campaign Analysis

SELECT
b.bonus_product,
COUNT(DISTINCT b.player_id) players,
ROUND(SUM(b.bonus_cost),2) total_bonus_cost,
ROUND(SUM(pa.bet_amount),2) total_bet_amount,
ROUND(SUM(pa.net_gross_win),2) total_net_gross_win
FROM `customer-churn-analysis-502804.Customer_churn_analysis.bonus` b
LEFT JOIN `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity` pa
ON b.player_id=pa.player_id
GROUP BY bonus_product
ORDER BY total_bonus_cost DESC;



# Acquisition Channel Quality

SELECT
pd.acquisition_channel,
COUNT(DISTINCT pa.player_id) active_players,
ROUND(SUM(pa.bet_amount),2) total_bets_amount,
ROUND(SUM(pa.net_gross_win),2) total_net_gross_win,
ROUND(AVG(pa.bet_amount),2) avg_bet_amount
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails` pd
JOIN `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity` pa
ON SAFE_CAST(pd.player_id AS INT64)=pa.player_id
GROUP BY acquisition_channel
ORDER BY total_net_gross_win DESC;


# Player Value Segmentation
WITH player_value AS (
SELECT
player_id,
ROUND(SUM(bet_amount),2) total_bet_amount
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
GROUP BY player_id)
SELECT
player_id,
total_bet_amount,
NTILE(5) OVER(ORDER BY total_bet_amount DESC) spending_tier
FROM player_value
ORDER BY total_bet_amount DESC;