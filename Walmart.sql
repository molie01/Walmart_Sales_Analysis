SELECT * 
FROM Walmart;


SELECT 
	COUNT(DISTINCT branch)
FROM Walmart;


-- Business Problems
-- Q.1 Find different payment method and number of transactions, number of quantity sold

SELECT payment_method, 
	COUNT(*) AS number_of_transactions,
	SUM(quantity) AS number_of_sold_quantity
FROM Walmart
GROUP BY payment_method;


-- Q.2  -- Identify the highest-rated category in each branch, displaying the branch, category
		-- AVG RATING 

SELECT *
FROM
(	SELECT branch, category, AVG(rating) AS avg_rating, RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as ranking
	FROM Walmart
	GROUP BY 1, 2
) AS sub_query
WHERE ranking = 1;


-- Q.3 Identify the busiest day for each branch based on the number of transactions

SELECT *
FROM
(	SELECT branch,DAYNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS day_name, 
	COUNT(*) AS number_of_transactions, RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
	FROM Walmart
	GROUP BY 1, 2
) AS sub_query_q3
WHERE ranking = 1;


-- Q.4 Calculate the total quantity of items sold per payment method. List payment_method and total quantity

SELECT payment_method, SUM(quantity) AS number_of_sold_quantity
FROM Walmart
GROUP BY payment_method;


-- Q.5  -- Determine the average, minimum, and maximum rating of category for each city
		-- List the city,average_rating, min_rating, and max_rating

SELECT city, category, MIN(rating) AS min_rating, MAX(rating) AS max_rating, AVG(rating) AS avg_rating
FROM Walmart
GROUP BY city, category;


-- Q.6  -- Calculate the total profit for each category by considering total_profit as (unit_price * quantity * profit_margin).
		-- List category and total_profit, ordered from highest to lowest profit
	
SELECT category, SUM(total) AS total_revenue, SUM(total * profit_margin) AS total_profit 
FROM Walmart
GROUP BY category
ORDER BY SUM(total * profit_margin) DESC
;


-- Q.7  -- Determine the most common payment method for each branch
		-- Display branch and the preferred_payment_method
        
SELECT *
FROM
(	SELECT branch, payment_method, COUNT(*) AS number_of_transactions, RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
	FROM Walmart
	GROUP BY branch, payment_method
) AS sub_query_q7
WHERE ranking = 1
;


-- Q.8 -- Categorize sales into 3 group MORNING, AFTERNOON, EVENING
		-- Find out which of the shift and number of invoices

SELECT branch,
CASE
	WHEN HOUR(time) < 12 THEN 'Morning'
 	WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'   
	ELSE 'Evening'
END day_time,
COUNT(*) AS number_of_transactions
FROM Walmart
GROUP BY branch, day_time
ORDER BY branch, COUNT(*) DESC
;


-- Q.9 -- Identify 5 branch with highest decrease ratio in revenue compare to last year (current year 2023 and last year 2022)

WITH revenue_2022
AS
(SELECT branch, SUM(total) AS total_revenue
FROM Walmart
WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
GROUP BY branch
),
revenue_2023
AS
(SELECT branch, SUM(total) AS total_revenue
FROM Walmart
WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
GROUP BY branch
)
SELECT last_year.branch, last_year.total_revenue, current_year.total_revenue,
	ROUND((CAST(last_year.total_revenue AS DECIMAL) - CAST(current_year.total_revenue AS DECIMAL))/ CAST(last_year.total_revenue AS DECIMAL) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS last_year
JOIN revenue_2023 AS current_year
	ON last_year.branch = current_year.branch
WHERE 
	last_year.total_revenue > current_year.total_revenue
ORDER BY 4 DESC
LIMIT 5
;














