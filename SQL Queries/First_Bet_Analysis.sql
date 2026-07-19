#First Bet Analysis

#Business Objective

#This module helps answer:
#1) How many users placed their first bet?
#2) Which products are most popular?
#3) Which platforms are preferred?
#4) Which acquisition channels produce bettors?
#5) How quickly do users place their first bet after depositing?
#6) Which users have the highest first bets?


#Total Players Who Placed a First Bet
SELECT
    COUNT(DISTINCT player_id) AS first_bettors
FROM `customer-churn-analysis-502804.Customer_churn_analysis.firstbet`;
# 292785 users placed first bet.


#First Bet Within 30 Days - How many players placed their first bet within 30 days of registration?
SELECT
    COUNT(DISTINCT fb.player_id) AS bettors_within_30_days
FROM `customer-churn-analysis-502804.Customer_churn_analysis.firstbet` fb
JOIN `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails` pd
ON fb.player_id = SAFE_CAST(pd.player_id AS INT64)
WHERE DATE_DIFF( DATE(fb.first_bet_datetime),DATE(pd.signup_date),DAY) BETWEEN 0 AND 30;
# total betters within 30 days are 145654




#Registration → First Bet Conversion (30 Days)
SELECT
COUNT(DISTINCT fb.player_id) AS first_bettors,
COUNT(DISTINCT SAFE_CAST(pd.player_id AS INT64)) AS registered_players,
ROUND(100 *COUNT(DISTINCT fb.player_id) / COUNT(DISTINCT SAFE_CAST(pd.player_id AS INT64)),2) AS conversion_rate
FROM
`customer-churn-analysis-502804.Customer_churn_analysis.playerdetails` pd
LEFT JOIN
`customer-churn-analysis-502804.Customer_churn_analysis.firstbet` fb
ON fb.player_id = SAFE_CAST(pd.player_id AS INT64) AND DATE_DIFF(DATE(fb.first_bet_datetime),DATE(pd.signup_date),DAY) BETWEEN 0 AND 30;
#from signup to 30 days 49.75% of players placed first bet.


#First Bet Product Performance - Which product attracted the most first bets?
SELECT
first_bet_product,
COUNT(DISTINCT player_id) AS players
FROM `customer-churn-analysis-502804.Customer_churn_analysis.firstbet`
GROUP BY first_bet_product
ORDER BY players DESC;
# Non Table Games & Prematch are the products where most of players placed first bet.


#First Bet Product Group - Which product group performs best?
SELECT
first_bet_product_group,
COUNT(DISTINCT player_id) AS players
FROM `customer-churn-analysis-502804.Customer_churn_analysis.firstbet`
GROUP BY first_bet_product_group
ORDER BY players DESC;
# most of the players placed their first bet in eGaming product group.


#First Bet Channel - Which acquisition channel do players use for their first bet?

SELECT
first_bet_channel,
COUNT(DISTINCT player_id) AS players
FROM `customer-churn-analysis-502804.Customer_churn_analysis.firstbet`
GROUP BY first_bet_channel
ORDER BY players DESC;
# online Channel most player use for his first bet.



#First Bet Platform - Mobile or Desktop?
SELECT
first_bet_platform,
COUNT(DISTINCT player_id) AS players
FROM `customer-churn-analysis-502804.Customer_churn_analysis.firstbet`
GROUP BY first_bet_platform
ORDER BY players DESC;
# most of players prefer mobile as their first betting platform



#Average First Bet Amount - What is the average first bet?

SELECT
COUNT(DISTINCT player_id) AS bettors,
ROUND(AVG(first_betsilp_amount),2) AS avg_first_bet,
ROUND(MIN(first_betsilp_amount),2) AS minimum,
ROUND(MAX(first_betsilp_amount),2) AS maximum
FROM `customer-churn-analysis-502804.Customer_churn_analysis.firstbet`;
# average first bet amount is 38.28 


#Top 20 Players by First Bet Amount - 

SELECT
player_id,
first_betsilp_amount
FROM `customer-churn-analysis-502804.Customer_churn_analysis.firstbet`
ORDER BY first_betsilp_amount DESC
LIMIT 20;




#Registration → First Bet Conversion (30 Days)

SELECT
COUNT(DISTINCT fb.player_id) AS first_bettors,
COUNT(DISTINCT SAFE_CAST(pd.player_id AS INT64)) AS registered_players,
ROUND(100 *COUNT(DISTINCT fb.player_id)/COUNT(DISTINCT SAFE_CAST(pd.player_id AS INT64)),2) AS conversion_rate
FROM
`customer-churn-analysis-502804.Customer_churn_analysis.playerdetails` pd
LEFT JOIN
`customer-churn-analysis-502804.Customer_churn_analysis.firstbet` fb
ON fb.player_id = SAFE_CAST(pd.player_id AS INT64) AND DATE_DIFF(DATE(fb.first_bet_datetime),DATE(pd.signup_date),DAY)BETWEEN 0 AND 30;


#Bet Sequence Analysis -
SELECT
CASE
WHEN DATE(fb.first_bet_datetime) < DATE(fd.first_deposit_date)
THEN 'Bet Before Deposit'
WHEN DATE(fb.first_bet_datetime) = DATE(fd.first_deposit_date)
THEN 'Same Day Bet'
WHEN DATE(fb.first_bet_datetime) > DATE(fd.first_deposit_date)
THEN 'Bet After Deposit'
ELSE 'No Deposit'
END AS player_sequence,
COUNT(*) AS players
FROM
`customer-churn-analysis-502804.Customer_churn_analysis.firstbet` fb
LEFT JOIN
`customer-churn-analysis-502804.Customer_churn_analysis.firstdeposit` fd
ON fb.player_id = fd.player_id
GROUP BY player_sequence
ORDER BY players DESC;




SELECT
COUNT(*) AS players
FROM
`customer-churn-analysis-502804.Customer_churn_analysis.firstbet` fb
JOIN
`customer-churn-analysis-502804.Customer_churn_analysis.firstdeposit` fd
ON fb.player_id = fd.player_id
WHERE DATE(fb.first_bet_datetime) < DATE(fd.first_deposit_date);

#around 4193 players bet befor making any deposits
#Bonus campaigns are effectively encouraging trial play.
#Free-bet promotions successfully convert new users into active bettors.
#The platform reduces initial friction by allowing engagement before requiring payment.

SELECT

player_id,

first_betsilp_amount,

NTILE(5) OVER(
ORDER BY first_betsilp_amount DESC
) AS spending_tier

FROM `customer-churn-analysis-502804.Customer_churn_analysis.firstbet`;
