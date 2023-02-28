--- Utility Data Queries ---
CREATE VIEW utility_data AS(
SELECT c.channel_sales, c.cons_elec_12m,c.cons_gas_12m, c.cons_elec_last_month,
	c.date_active, c.date_end, c.date_renewal, c.forecast_elec_cons_12m, c.forecast_elec_cons_year,
	c.forecast_discount_energy, c.forecast_price_energy_off_peak, c.forecast_price_energy_peak, 
	c.forecast_price_pow_off_peak, c.has_gas, c.margin_gross_pow_elec,c.margin_net_pow_elec,
	c.num_active_products, c.total_net_margin, c.churn,
	p.*
FROM client_data c	
JOIN price_data p
ON c.id = p.id
)

---Utility Data Initial Query---
SELECT *
FROM utility_data

--- Comparing the current price energy peak vs the forecast price energy peak---
SELECT price_off_peak_var, forecast_price_energy_off_peak,
pricer_peak_var, forecast_price_energy_peak
FROM utility_data

--- Difference between each energy peak and forecast peak---
SELECT price_off_peak_var, forecast_price_energy_off_peak, 
(forecast_price_energy_off_peak-price_off_peak_var ) difference
FROM utility_data
ORDER BY difference DESC;

SELECT pricer_peak_var, forecast_price_energy_peak, 
(forecast_price_energy_peak-pricer_peak_var)
FROM utility_data
ORDER BY difference DESC;

---- Consumption of electricity based on each peak----
SELECT price_off_peak_var, cons_elec_12m
FROM utility_data
ORDER BY cons_elec_12m DESC;

SELECT price_mid_peak_var, cons_elec_12m
FROM utility_data
ORDER BY cons_elec_12m DESC;

SELECT pricer_peak_var, cons_elec_12m
FROM utility_data
ORDER BY cons_elec_12m DESC;

---Comparing the current price power peak vs the forecast price power peak---
SELECT price_off_peak_fix, forecast_price_pow_off_peak
FROM utility_data

--- Difference between each power peak and forecast power peak---
SELECT price_off_peak_fix, forecast_price_pow_off_peak,
(forecast_price_pow_off_peak - price_off_peak_fix) difference
FROM utility_data
ORDER BY difference DESC;

--- During which price energy peak did churn occur the most ---
SELECT price_off_peak_var, COUNT(churn) churn_count
FROM utility_data
WHERE churn = 'True'
GROUP BY 1
ORDER BY 2 DESC;

SELECT pricer_peak_var, COUNT(churn) churn_count
FROM utility_data
WHERE churn = 'True'
GROUP BY 1
ORDER BY 2 DESC;

SELECT price_mid_peak_var, COUNT(churn) churn_count
FROM utility_data
WHERE churn = 'True'
GROUP BY 1
ORDER BY 2 DESC;

--- During which price power peak did churn occur the most ---
SELECT price_off_peak_fix, COUNT(churn) churn_count
FROM utility_data
WHERE churn = 'True'
GROUP BY 1
ORDER BY 2 DESC;

SELECT price_peak_fix, COUNT(churn) churn_count
FROM utility_data
WHERE churn = 'True'
GROUP BY 1
ORDER BY 2 DESC;

SELECT price_mid_peak_fix, COUNT(churn) churn_count
FROM utility_data
WHERE churn = 'True'
GROUP BY 1
ORDER BY 2 DESC;

---- Consumption of power based on each peak----
SELECT price_off_peak_fix, cons_elec_12m
FROM utility_data
ORDER BY cons_elec_12m DESC;

SELECT price_peak_fix, cons_elec_12m
FROM utility_data
ORDER BY cons_elec_12m DESC;

SELECT pricer_mid_peak_fix, cons_elec_12m
FROM utility_data
ORDER BY cons_gas_12m DESC;