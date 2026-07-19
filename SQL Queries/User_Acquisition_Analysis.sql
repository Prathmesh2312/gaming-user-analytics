#The goal of this module is to understand:
#1) Where players come from.
#2) Which acquisition channels perform best.
#3) Registration trends.
#4) Customer demographics.
#5) Advertiser performance.
#6) Internal vs external players.

#Total Registered Players
SELECT
COUNT(DISTINCT player_id) AS total_registered_players
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails`;
#total Players are 292785

#Monthly Registration Trend- ow many new users registered each month?
SELECT
DATE_TRUNC(DATE(signup_date), MONTH) AS signup_month,
COUNT(DISTINCT player_id) AS new_players
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails`
GROUP BY signup_month
ORDER BY signup_month;
#Monthly registrations peaked in January 2019 (10,708 users) and gradually declined through the first half of the year, reaching a low of 5,991 users in June. Registrations partially recovered in the following months, suggesting seasonal effects or changes in acquisition campaigns.


#Acquisition Channel Performance- Which acquisition channels bring the most users?
SELECT
acquisition_channel,
COUNT(DISTINCT player_id) AS players
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails`
GROUP BY acquisition_channel
ORDER BY players DESC;
# Affiliate is the best channel.

#Acquisition Channel Contribution % - What percentage of users come from each acquisition channel?
SELECT
acquisition_channel,
COUNT(DISTINCT player_id) AS players,
ROUND(100 * COUNT(DISTINCT player_id)/SUM(COUNT(DISTINCT player_id)) OVER(),2) AS contribution_percentage
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails`
GROUP BY acquisition_channel
ORDER BY contribution_percentage DESC;
#33.58% of total users came from Affiliate channel.

#Gender Distribution - What is the gender distribution of registered users?

SELECT
gender,
COUNT(*) AS players,
ROUND(100*COUNT(*)/SUM(COUNT(*)) OVER(),2) AS percentage
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails`
GROUP BY gender
ORDER BY players DESC;
# 75.57% of tatal users are Male and 24.43 are female users.

#Age Segmentation
SELECT
CASE
WHEN age <18 THEN 'Below 18'
WHEN age BETWEEN 18 AND 24 THEN '18-24'
WHEN age BETWEEN 25 AND 34 THEN '25-34'
WHEN age BETWEEN 35 AND 44 THEN '35-44'
WHEN age BETWEEN 45 AND 54 THEN '45-54'
ELSE '55+'
END AS age_group,
COUNT(*) AS players
FROM( SELECT DATE_DIFF( CURRENT_DATE(), SAFE.PARSE_DATE('%Y-%m-%d',dob), YEAR) AS age FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails`)
GROUP BY age_group
ORDER BY age_group desc;
# most of players are from 25+ age group


#Top Advertisers - Which advertisers acquired the highest number of users?

SELECT
advertiser_id,
COUNT(DISTINCT player_id) AS players
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails`
GROUP BY advertiser_id
ORDER BY players DESC
LIMIT 10;
# advertisers with id 999999 and 130850 are on top.

#Internal vs External Players
SELECT
internal_player,
COUNT(*) players,
ROUND(100*COUNT(*)/SUM(COUNT(*)) OVER(),2) percentage
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails`
GROUP BY internal_player;
# 99.29% players are external players.



#Monthly Acquisition Channel Trend - How has each acquisition channel performed over time?
SELECT
DATE_TRUNC(DATE(signup_date),MONTH) signup_month,
acquisition_channel,
COUNT(DISTINCT player_id) players
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails`
GROUP BY signup_month, acquisition_channel
ORDER BY signup_month, players DESC;

SELECT

acquisition_channel,

COUNT(DISTINCT player_id) total_players,

COUNT(DISTINCT advertiser_id) advertisers,

COUNT(DISTINCT gender) genders,

MIN(DATE(signup_date)) first_signup,

MAX(DATE(signup_date)) latest_signup

FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails`

GROUP BY acquisition_channel

ORDER BY total_players DESC;
