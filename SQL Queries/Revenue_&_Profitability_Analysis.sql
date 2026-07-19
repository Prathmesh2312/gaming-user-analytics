#Revenue & Profitability Analysis

#Business Objective

#Understand how revenue is generated, identify profitable products, evaluate player value, and analyze business profitability.

#This module answers:

#Which products generate the highest revenue?
#Which products generate the highest Net Gaming Revenue (NGR)?
#What is the average revenue per player?
#Who are the highest-value customers?
#Which months generated the highest revenue?
#How much do players win compared to how much they bet?
#Which products are most profitable?



#Overall Business Revenue

SELECT
ROUND(SUM(bet_amount),2) total_bet_amount,
ROUND(SUM(win_amount),2) total_win_amount,
ROUND(SUM(gross_win),2) gross_win,
ROUND(SUM(net_gross_win),2) net_gaming_revenue
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`;



#Monthly Revenue Trend
SELECT
activity_month,
ROUND(SUM(bet_amount),2) total_bet_amount,
ROUND(SUM(win_amount),2) total_win_amount,
ROUND(SUM(net_gross_win),2) total_net_gross_win
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
GROUP BY activity_month
ORDER BY activity_month;


#Product Revenue Performance
SELECT
product,
COUNT(DISTINCT player_id) players,
ROUND(SUM(bet_amount),2) total_bet_amount,
ROUND(SUM(win_amount),2) total_win_amount,
ROUND(SUM(net_gross_win),2) total_net_gross_revenue
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
GROUP BY product
ORDER BY total_net_gross_revenue DESC;


#Subproduct Profitability

SELECT
subproduct,
COUNT(DISTINCT player_id) players,
ROUND(SUM(bet_amount),2) total_bets,
ROUND(SUM(net_gross_win),2) total_ngr,
ROUND(AVG(net_gross_win),2) avg_ngr
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
GROUP BY subproduct
ORDER BY total_ngr DESC;


#Average Revenue Per Player

SELECT
ROUND(SUM(net_gross_win)/COUNT(DISTINCT player_id) ,2) AS average_revenue_per_player
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`;


# Top 20 Revenue Generating Players
SELECT
player_id,
ROUND(SUM(bet_amount),2) total_bets,
ROUND(SUM(win_amount),2) total_wins,
ROUND(SUM(net_gross_win),2) total_ngr
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
GROUP BY player_id
ORDER BY total_ngr DESC
LIMIT 20;



# Monthly Revenue by Product
SELECT
activity_month,
product,
ROUND(SUM(net_gross_win),2) total_ngr
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
GROUP BY activity_month,product
ORDER BY activity_month,total_ngr DESC;


#Player Profitability Segmentation
WITH player_profit AS (
SELECT
player_id,
SUM(net_gross_win) ngr
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
GROUP BY player_id)
SELECT
CASE
      WHEN ngr <0 THEN 'Loss Making'
      WHEN ngr BETWEEN 0 AND 100 THEN 'Low Value'
      WHEN ngr BETWEEN 101 AND 500 THEN 'Medium Value'
      WHEN ngr BETWEEN 501 AND 1000 THEN 'High Value'
      ELSE 'VIP'
END AS player_segment,
COUNT(*) players,
ROUND(AVG(ngr),2) avg_revenue
FROM player_profit
GROUP BY player_segment
ORDER BY avg_revenue DESC;



#House Edge
SELECT
ROUND(100*SUM(net_gross_win)/SUM(bet_amount),2) AS house_edge_percentage
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`;


#Product Share of Revenue

SELECT
product,
ROUND(SUM(net_gross_win),2) revenue,
ROUND(100*SUM(net_gross_win)/SUM(SUM(net_gross_win)) OVER(),2) contribution_percentage
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
GROUP BY product
ORDER BY contribution_percentage DESC;



#Highest Revenue Months
SELECT
activity_month,
ROUND(SUM(net_gross_win),2) revenue,
RANK() OVER(ORDER BY SUM(net_gross_win) DESC) revenue_rank
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
GROUP BY activity_month
ORDER BY revenue_rank;


#Revenue Efficiency
SELECT
product,
ROUND(SUM(net_gross_win)/SUM(bet_amount)*100,2) revenue_margin
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
GROUP BY product
ORDER BY revenue_margin DESC;