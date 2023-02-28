--- Client Data Queries ---
SELECT *
FROM client_data;

--- Total number of people who churned---
SELECT churn, COUNT(churn) churn_count
FROM client_data
GROUP BY churn
ORDER BY churn_count DESC;

--- Percentage of people who churned ---
SELECT churn, COUNT(churn) *100/(SELECT SUM(t1.churn_count)
								 FROM (
								 SELECT churn, COUNT(churn) churn_count
								 FROM client_data
								 GROUP BY churn
								 ) t1) percent_of_total
FROM client_data
GROUP BY churn
ORDER BY percent_of_total DESC

--- Percentage of churn by channel sales ---
SELECT churn, channel_sales, COUNT(churn) *100/(SELECT SUM(t1.churn_count)
								 FROM (
								 SELECT churn, channel_sales, COUNT(churn) churn_count
								 FROM client_data
								 GROUP BY churn, channel_sales
								 ) t1) percent_of_total
FROM client_data
GROUP BY churn, channel_sales 
ORDER BY percent_of_total DESC

---- Churn by Tenure Categroy---
SELECT CASE WHEN t1.tenure < 6 THEN '< 6 Years'
WHEN t1.tenure BETWEEN 6 AND 9 THEN '6-9 Years'
WHEN t1.tenure > 9 THEN '> 9 Years' END AS tenure_category,
AVG(t1.churn_count) avg_churn_count
FROM(
SELECT (date_end -date_active)/365 tenure, COUNT(churn) churn_count
FROM client_data
WHERE churn = 'True'
GROUP BY tenure) t1
GROUP BY tenure_category

--- Churn by Contract Type ---
SELECT t1.has_gas, AVG(churn_count)avg_churn_count
FROM(
SELECT has_gas, COUNT(churn) churn_count
FROM client_data
WHERE churn = 'True'
GROUP BY has_gas
) t1
GROUP BY t1.has_gas

--- Churn by number of active products --- 
SELECT num_active_products, COUNT(churn) churn_count
FROM client_data
WHERE churn = 'True'
GROUP BY num_active_products
ORDER BY churn_count DESC;
--- Channel where most utility consumption was coming from ---
SELECT channel_sales, COUNT(channel_sales) channel_count
FROM client_data
GROUP BY channel_sales
ORDER BY channel_count DESC;

--- If people consumed more electric in the past month than all of last year ---
SELECT id, SUM(cons_elec_12m) sum_cons_elec_last_year, 
SUM(cons_elec_last_month) sum_cons_elec_last_month
FROM client_data
GROUP BY id
HAVING SUM(cons_elec_12m) < SUM(cons_elec_last_month);

--- If forecasted electricity consumption is going to be greater than electricity consumption now---
SELECT id, AVG(cons_elec_12m) avg_elec_cons_12m, AVG(forecast_elec_cons_12m) avg_forecasted_elec_cons
FROM client_data
GROUP BY id
HAVING AVG(cons_elec_12m) > AVG(forecast_elec_cons_12m);

---- How long did it take for a customer to renew its contract (on average) from when their first contract was active---
SELECT id, AVG((date_renewal - date_active)/365) renewal_years
FROM client_data
GROUP BY id
ORDER BY renewal_years;