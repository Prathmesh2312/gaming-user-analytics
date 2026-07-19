#Verify that every dataset has been loaded successfully.

SELECT 'playerdetails' AS table_name,COUNT(*) AS total_records
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails`

UNION ALL

SELECT 'firstdeposit', COUNT(*)
FROM `customer-churn-analysis-502804.Customer_churn_analysis.firstdeposit`

UNION ALL

SELECT 'firstbet', COUNT(*)
FROM `customer-churn-analysis-502804.Customer_churn_analysis.firstbet`

UNION ALL

SELECT 'playeractivity', COUNT(*)
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`

UNION ALL

SELECT 'bonus', COUNT(*)
FROM `customer-churn-analysis-502804.Customer_churn_analysis.bonus`;

##Confirms all five tables loaded successfully.

#Duplicate Player IDs
#Each player should appear only once in the master player table.
SELECT player_id, COUNT(*) AS duplicate_records
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails`
GROUP BY player_id
HAVING COUNT(*) > 1
ORDER BY duplicate_records DESC;

##No duplicate customer found.


#Missing Values in Player Details
SELECT COUNT(*) AS total_players, COUNTIF(player_id IS NULL) AS missing_player_id,COUNTIF(signup_date IS NULL) AS missing_signup_date,COUNTIF(acquisition_channel IS NULL) AS missing_acquisition_channel, COUNTIF(advertiser_id IS NULL) AS missing_advertiser, COUNTIF(gender IS NULL) AS missing_gender, COUNTIF(dob IS NULL) AS missing_dob, COUNTIF(internal_player IS NULL) AS missing_internal_player
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails`;
## total players are 292785 & No mussing values 


#Missing Values in Deposit Table

SELECT COUNT(*) AS total_records, COUNTIF(player_id IS NULL) AS missing_player, COUNTIF(first_deposit_date IS NULL) AS missing_date, COUNTIF(first_deposit_channel IS NULL) AS missing_channel, COUNTIF(first_deposit_method IS NULL) AS missing_method, COUNTIF(first_deposit_amount IS NULL) AS missing_amount
FROM `customer-churn-analysis-502804.Customer_churn_analysis.firstdeposit`;

## 1) deposit table all the data of players are present.
#  2) those players who does not deposited any money they have missing values, so these nulls has importance in the data so we can not remove it.

#Missing Values in First Bet Table
SELECT
COUNT(*) AS total_records,
COUNTIF(player_id IS NULL) AS missing_player,
COUNTIF(first_bet_datetime IS NULL) AS missing_datetime,
COUNTIF(first_betsilp_amount IS NULL) AS missing_amount,
COUNTIF(first_bet_product_group IS NULL) AS missing_product_group,
COUNTIF(first_bet_product IS NULL) AS missing_product,
COUNTIF(first_bet_channel IS NULL) AS missing_channel,
COUNTIF(first_bet_platform IS NULL) AS missing_platform
FROM `customer-churn-analysis-502804.Customer_churn_analysis.firstbet`;

# all the players are present in the data. same as deposit table here also some null values are present but that null values has importance in the data.


#Missing Values in Player Activity
SELECT
COUNT(*) total_rows,
COUNTIF(activity_month IS NULL) missing_month,
COUNTIF(product IS NULL) missing_product,
COUNTIF(subproduct IS NULL) missing_subproduct,
COUNTIF(player_active_days IS NULL) missing_active_days,
COUNTIF(bet_amount IS NULL) missing_bet_amount,
COUNTIF(win_amount IS NULL) missing_win_amount,
COUNTIF(gross_win IS NULL) missing_gross_win,
COUNTIF(net_gross_win IS NULL) missing_net_gross_win
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`;

# here null values are not present in data

#Missing Values in Bonus Table

SELECT
COUNT(*) total_bonus_rows,
COUNTIF(player_id IS NULL) missing_player,
COUNTIF(activity_month IS NULL) missing_month,
COUNTIF(bonus_product IS NULL) missing_product,
COUNTIF(bonus_cost IS NULL) missing_bonus_cost
FROM `customer-churn-analysis-502804.Customer_churn_analysis.bonus`;
#null values are not presnt in the dataset/table


#Future Dates- No transaction should occur in the future.
SELECT *
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails`
WHERE DATE(signup_date) > CURRENT_DATE(); 

SELECT *
FROM `customer-churn-analysis-502804.Customer_churn_analysis.firstdeposit`
WHERE DATE(first_deposit_date) > CURRENT_DATE();



#Distinct Category Values- Check inconsistent category names.

SELECT
acquisition_channel,
COUNT(*) AS total_players
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playerdetails`
GROUP BY acquisition_channel
ORDER BY total_players DESC;
# I have listed all the acquisition_channel and count of customers. most of customers came from Affiliate 

##Subproduct Distribution Check.

SELECT
    player_id,
    activity_month,
    product,
    COUNT(*) AS records_per_product
FROM `customer-churn-analysis-502804.Customer_churn_analysis.playeractivity`
GROUP BY
    player_id,
    activity_month,
    product
HAVING COUNT(*) > 1
ORDER BY records_per_product DESC;

#There are multiple records for the same player-month-product combination because activity is recorded separately for different subproducts. No exact duplicate records exist.
