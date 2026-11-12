-- Which products and categories are top performers in terms of revenue, profit, profit margin, units sold?

--		Products
SELECT 
	Product_Name,
	ROUND(SUM(Sales_Amount), 2) AS Total_Revenue,
	ROUND(SUM(Profit), 4) AS Total_Profit,
	ROUND(SUM(Profit) / SUM(Sales_Amount), 4) AS Profit_Margin,
	SUM(Quantity) AS Units_Sold
FROM sales_staging_2
GROUP BY Product_Name
ORDER BY Total_Revenue DESC;

--		Categories
SELECT 
	Product_Category,
	ROUND(SUM(Sales_Amount), 4) AS Total_Revenue,
	ROUND(SUM(Profit), 2) AS Total_Profit,
	ROUND(SUM(Profit) / SUM(Sales_Amount), 4) AS Profit_Margin,
	SUM(Quantity) AS Units_Sold
FROM sales_staging_2
GROUP BY Product_Category
ORDER BY Total_Revenue DESC;



-- Which sales channel generates the most revenue?
SELECT
	Sales_Channel,
	ROUND(SUM(Sales_Amount), 2) AS Total_Revenue
FROM sales_staging_2
GROUP BY Sales_Channel 
ORDER BY Total_Revenue DESC;



-- Which countries generate the most revenue?
SELECT
	Country,
	ROUND(SUM(Sales_Amount), 2) AS Total_Revenue
FROM sales_staging_2
GROUP BY Country
ORDER BY Total_Revenue DESC;



-- Trends over time
SELECT
	MAX(Order_Year),
	MIN(Order_Year)
FROM sales_staging_2 ss ;

-- 		Total revenue and profit (2022 - 2025) by month
SELECT
	DATE_FORMAT(Order_Date, '%Y-%m') AS Month_Year,
	ROUND(SUM(Sales_Amount), 2) AS Total_Revenue,
	ROUND(SUM(Profit), 2) AS Total_Profit
FROM sales_staging_2
GROUP BY Month_Year
ORDER BY Month_Year;

--		Average revenue each month
WITH monthly_cte AS(
	SELECT
		DATE_FORMAT(Order_Date, '%Y-%m') AS Month_Year,
		SUM(Sales_Amount) AS Total_Revenue,
		SUM(Profit) AS Total_Profit
	FROM sales_staging_2
	GROUP BY Month_Year
) 
SELECT
	Right(Month_Year, 2) AS `Month`,
	ROUND(AVG(Total_Revenue), 2) AS Average_Revenue,
	ROUND(AVG(Total_Profit), 2) AS Average_Profit
FROM monthly_cte
GROUP BY `Month`
ORDER BY `Month`;



-- What share of revenue comes from each customer segment and which is most profitable?
SELECT
	Customer_Segment,
	ROUND(SUM(Sales_Amount), 2) AS Total_Revenue,
	ROUND(SUM(Sales_Amount)/(
		SELECT SUM(Sales_Amount)
		FROM sales_staging_2
	) * 100, 2) AS Percent_Of_Revenue,
	ROUND(SUM(Profit), 2) AS Total_Profit,
	ROUND(SUM(Profit)/(
		SELECT SUM(Profit)
		FROM sales_staging_2
	) * 100, 2) AS Percent_Of_Profit
FROM sales_staging_2
GROUP BY Customer_Segment
ORDER BY Percent_Of_Profit DESC;



-- Do higher discounts lead to more units sold per transaction and higher profit margins?
SELECT
	CASE 
		WHEN Discount_Percentage = 0 THEN '0%'
		WHEN Discount_Percentage > 1 AND Discount_Percentage <= 10 THEN '1-10%'
		WHEN Discount_Percentage > 11 AND Discount_Percentage <= 20 THEN '11-20%'
		WHEN Discount_Percentage > 21 AND Discount_Percentage <= 30 THEN '21-30%'
		ELSE '31% +'
	END AS Discount_Amount,
	COUNT(*) AS `Rows`,
	ROUND(AVG(Quantity), 2) AS Units_Sold_Per_Transaction,
	ROUND(SUM(Profit) / SUM(Sales_Amount), 2) AS Profit_Margin
FROM sales_staging_2
GROUP BY Discount_Amount
ORDER BY Discount_Amount;



-- Is a particular category more likely to be returned?
SELECT 
	Product_Category,
	COUNT(*) AS Transactions,
	SUM(Return_Flag = 'Yes') AS Number_Returns,
	ROUND(100 * SUM(Return_Flag = 'Yes') / COUNT(*), 2) AS Return_Rate_Pct
FROM sales_staging_2
GROUP BY Product_Category 
ORDER BY Number_Returns DESC;



-- What is the most common reason for a return?
SELECT
	Return_Reason,
	COUNT(*) AS Number_Returns
FROM sales_staging_2
WHERE Return_Flag = 'Yes'
GROUP BY Return_Reason
ORDER BY Number_Returns DESC;




















