--- Price Data Queries ---
SELECT *
FROM price_data;

--- The number of customers that joined by month---
SELECT EXTRACT('month' from price_date) month_date, COUNT(DISTINCT id) num_customers
FROM price_data
GROUP BY month_date
ORDER BY num_customers DESC;

--- Average energy price by period for each month---
SELECT EXTRACT('month' from price_date) month_date, AVG(price_off_peak_var) avg_1st_period_energy_price,
AVG(pricer_peak_var) avg_2nd_period_energy_price, 
AVG(price_mid_peak_var) avg_3rd_period_energy_price
FROM price_data
GROUP BY month_date
ORDER BY avg_1st_period_energy_price DESC, 
avg_2nd_period_energy_price DESC, avg_3rd_period_energy_price DESC;

--- Average price changes across periods for energy---
WITH energy_price AS(
SELECT id, AVG(price_off_peak_var) avg_1st_period_energy_price,
AVG(pricer_peak_var) avg_2nd_period_energy_price, 
AVG(price_mid_peak_var) avg_3rd_period_energy_price
FROM price_data
GROUP BY id)

SELECT t1.id, (t1.agg_1st_period_energy_price - t1.agg_2nd_period_energy_price) off_peak_peak_var_mean_diff,
(t1.agg_2nd_period_energy_price - t1.agg_3rd_period_energy_price) peak_mid_peak_var_mean_diff,
(t1.agg_1st_period_energy_price - t1.agg_3rd_period_energy_price) off_peak_mid_peak_fix_var_diff
FROM(
SELECT id, SUM(avg_1st_period_energy_price) agg_1st_period_energy_price,
SUM(avg_2nd_period_energy_price) agg_2nd_period_energy_price,
SUM(avg_3rd_period_energy_price) agg_3rd_period_energy_price
FROM energy_price
GROUP BY id) t1

--- Max price changes across energy and months ---
WITH energy_price AS(
SELECT id, EXTRACT('month' from price_date) price_month, AVG(price_off_peak_var) avg_1st_period_energy_price,
AVG(pricer_peak_var) avg_2nd_period_energy_price, 
AVG(price_mid_peak_var) avg_3rd_period_energy_price
FROM price_data
GROUP BY id, price_month)

SELECT t1.id, MAX(t1.agg_1st_period_energy_price - t1.agg_2nd_period_energy_price) max_off_peak_peak_var_mean_diff,
MAX(t1.agg_2nd_period_energy_price - t1.agg_3rd_period_energy_price) max_peak_mid_peak_var_mean_diff,
MAX(t1.agg_1st_period_energy_price - t1.agg_3rd_period_energy_price) max_off_peak_mid_peak_fix_var_diff
FROM(
SELECT id, price_month, SUM(avg_1st_period_energy_price) agg_1st_period_energy_price,
SUM(avg_2nd_period_energy_price) agg_2nd_period_energy_price,
SUM(avg_3rd_period_energy_price) agg_3rd_period_energy_price
FROM energy_price
GROUP BY id, price_month) t1
GROUP BY t1.id


---Average power price by period for each month---
SELECT EXTRACT('month' from price_date) month_date, AVG(price_off_peak_fix) avg_1st_period_power_price,
AVG(price_peak_fix) avg_2nd_period_power_price, 
AVG(price_mid_peak_fix) avg_3rd_period_power_price
FROM price_data
GROUP BY month_date
ORDER BY avg_1st_period_power_price DESC, 
avg_2nd_period_power_price DESC, avg_3rd_period_power_price DESC;

--- Average price changes across periods for power---
WITH power_price AS(
SELECT id, AVG(price_off_peak_fix) avg_1st_period_power_price,
AVG(price_peak_fix) avg_2nd_period_power_price, 
AVG(price_mid_peak_fix) avg_3rd_period_power_price
FROM price_data
GROUP BY id)

SELECT t1.id, (t1.agg_1st_period_power_price - t1.agg_2nd_period_power_price) off_peak_peak_fix_mean_diff,
(t1.agg_2nd_period_power_price - t1.agg_3rd_period_power_price) peak_mid_peak_fix_mean_diff,
(t1.agg_1st_period_power_price - t1.agg_3rd_period_power_price) off_peak_mid_peak_fix_mean_diff
FROM(
SELECT id, SUM(avg_1st_period_power_price) agg_1st_period_power_price,
SUM(avg_2nd_period_power_price) agg_2nd_period_power_price,
SUM(avg_3rd_period_power_price) agg_3rd_period_power_price
FROM power_price
GROUP BY id) t1

--- Max price changes across power and months ---
WITH power_price AS(
SELECT id, EXTRACT('month' from price_date) price_month, AVG(price_off_peak_fix) avg_1st_period_power_price,
AVG(price_peak_fix) avg_2nd_period_power_price, 
AVG(price_mid_peak_fix) avg_3rd_period_power_price
FROM price_data
GROUP BY id, price_month)

SELECT t1.id, MAX(t1.agg_1st_period_power_price - t1.agg_2nd_period_power_price) max_off_peak_peak_fix_mean_diff,
MAX(t1.agg_2nd_period_power_price - t1.agg_3rd_period_power_price) max_peak_mid_peak_fix_mean_diff,
MAX(t1.agg_1st_period_power_price - t1.agg_3rd_period_power_price) max_off_peak_mid_peak_fix_mean_diff
FROM(
SELECT id,price_month, SUM(avg_1st_period_power_price) agg_1st_period_power_price,
SUM(avg_2nd_period_power_price) agg_2nd_period_power_price,
SUM(avg_3rd_period_power_price) agg_3rd_period_power_price
FROM power_price
GROUP BY id, price_month) t1
GROUP BY t1.id;

--- Difference in off peak prices in December and Preceding January ---
WITH december AS (
SELECT id,
AVG(price_off_peak_fix) avg_1st_period_power_price,
AVG(price_off_peak_var) avg_1st_period_energy_price
FROM price_data
WHERE EXTRACT('month' from price_date) = '12' 	
GROUP BY id) ,

january AS(
SELECT id, 
AVG(price_off_peak_fix) avg_1st_period_power_price,
AVG(price_off_peak_var) avg_1st_period_energy_price
FROM price_data
WHERE EXTRACT('month' from price_date) = '1' 	
GROUP BY id
)

SELECT t1.id, (t1.dec_sum_1st_period_power_price-t1.jan_sum_1st_period_power_price) offpeak_diff_dec_january_power,
(t1.dec_sum_1st_period_energy_price - t1.jan_sum_1st_period_energy_price) offpeak_diff_dec_january_energy
FROM(
SELECT december.id, SUM(december.avg_1st_period_power_price) dec_sum_1st_period_power_price,
SUM(december.avg_1st_period_energy_price) dec_sum_1st_period_energy_price,
SUM(january.avg_1st_period_power_price) jan_sum_1st_period_power_price,
SUM(january.avg_1st_period_energy_price) jan_sum_1st_period_energy_price
FROM december
JOIN january
ON december.id = january.id
GROUP BY december.id) t1