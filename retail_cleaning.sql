SELECT *
FROM sales_transactions;


-- Copy table
CREATE TABLE sales_staging
LIKE sales_transactions;

SELECT * FROM sales_staging;

INSERT sales_staging
SELECT *
FROM sales_transactions;

SELECT * FROM sales_staging;

-- Remove Duplicates
SELECT
	*,
	ROW_NUMBER() OVER(PARTITION BY Transaction_ID, Order_ID, Customer_ID, Customer_Name, Product_ID, Quantity, Order_Date, Order_Time) AS row_num
FROM sales_staging;

WITH duplicate_cte AS 
	(SELECT
		*,
		ROW_NUMBER() OVER(PARTITION BY Transaction_ID, Order_ID, Customer_ID, Customer_Name, Product_ID, Quantity, Order_Date, Order_Time) AS row_num
	FROM sales_staging)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM sales_staging
WHERE Order_ID = 'O0103264';

CREATE TABLE `sales_staging_2` (
  `Transaction_ID` varchar(50) DEFAULT NULL,
  `Order_ID` varchar(50) DEFAULT NULL,
  `Customer_ID` varchar(50) DEFAULT NULL,
  `Customer_Name` varchar(50) DEFAULT NULL,
  `Customer_Age` double DEFAULT NULL,
  `Customer_Gender` varchar(50) DEFAULT NULL,
  `Customer_Segment` varchar(50) DEFAULT NULL,
  `Order_Date` varchar(50) DEFAULT NULL,
  `Order_Time` varchar(50) DEFAULT NULL,
  `Sales_Channel` varchar(50) DEFAULT NULL,
  `Store_ID` varchar(50) DEFAULT NULL,
  `Store_Name` varchar(50) DEFAULT NULL,
  `Country` varchar(50) DEFAULT NULL,
  `Region` varchar(50) DEFAULT NULL,
  `City` varchar(50) DEFAULT NULL,
  `Product_ID` varchar(50) DEFAULT NULL,
  `Product_Name` varchar(50) DEFAULT NULL,
  `Product_Category` varchar(50) DEFAULT NULL,
  `Product_Subcategory` varchar(50) DEFAULT NULL,
  `Quantity` int DEFAULT NULL,
  `Unit_Price` double DEFAULT NULL,
  `Discount_Percentage` double DEFAULT NULL,
  `Sales_Amount` double DEFAULT NULL,
  `Cost_Amount` double DEFAULT NULL,
  `Profit` double DEFAULT NULL,
  `Payment_Method` varchar(50) DEFAULT NULL,
  `Order_Status` varchar(50) DEFAULT NULL,
  `Shipping_Method` varchar(50) DEFAULT NULL,
  `Delivery_Days` double DEFAULT NULL,
  `Return_Flag` varchar(50) DEFAULT NULL,
  `Return_Reason` varchar(50) DEFAULT NULL,
  `Sales_Representative` varchar(50) DEFAULT NULL,
  `Promotion_Code` varchar(50) DEFAULT NULL,
  `Customer_Rating` double DEFAULT NULL,
  `Inventory_Level` double DEFAULT NULL,
  `Order_Year` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM sales_staging_2;

INSERT INTO sales_staging_2
SELECT
	*,
	ROW_NUMBER() OVER(PARTITION BY Transaction_ID, Order_ID, Customer_ID, Customer_Name, Product_ID, Quantity, Order_Date, Order_Time) AS row_num
FROM sales_staging;

SELECT *
FROM sales_staging_2
WHERE row_num > 1;

DELETE
FROM sales_staging_2
WHERE row_num > 1;


-- Standardize
SELECT *
FROM sales_staging_2;

SELECT Order_Date, STR_TO_DATE(Order_Date, '%Y-%m-%d')
FROM sales_staging_2;

UPDATE sales_staging_2
SET Order_Date = STR_TO_DATE(Order_Date, '%Y-%m-%d');

ALTER TABLE sales_staging_2 
MODIFY COLUMN Order_Date DATE;

SELECT Order_Time, STR_TO_DATE(Order_Time, '%H:%i:%s')
FROM sales_staging_2;

UPDATE sales_staging_2
SET Order_Time = STR_TO_DATE(Order_Time, '%H:%i:%s');

ALTER TABLE sales_staging_2 
MODIFY COLUMN Order_Time TIME;

SELECT DISTINCT Customer_Gender
FROM sales_staging_2;

SELECT *
FROM sales_staging_2
WHERE Customer_Gender LIKE 'Non%';

UPDATE sales_staging_2
SET Customer_Gender = 'Non-binary'
WHERE Customer_Gender LIKE 'Non%';

SELECT DISTINCT City
FROM sales_staging_2
ORDER BY 1;

UPDATE sales_staging_2
SET City = 'New York'
WHERE City LIKE '%New York%';

SELECT DISTINCT Region
FROM sales_staging_2
ORDER BY 1;

UPDATE sales_staging_2
SET Region = 'Northeast'
WHERE Region LIKE 'North%'

SELECT DISTINCT Payment_Method
FROM sales_staging_2
ORDER BY 1;

UPDATE sales_staging_2
SET Payment_Method = 'Debit Card'
WHERE Payment_Method LIKE 'Debit%';


-- Nulls/blanks --- payment method

DESCRIBE sales_staging_2;

SELECT COUNT(*)
FROM sales_staging_2;

-- Fill in blank genders

SELECT *
FROM sales_staging_2
WHERE Customer_Gender IS NULL OR Customer_Gender = '';

SELECT *
FROM sales_staging_2
WHERE Customer_ID = 'C03746';

SELECT
	t1.Customer_Gender,
	t2.Customer_Gender
FROM sales_staging_2 t1
JOIN sales_staging_2 t2
	ON t1.Customer_ID = t2.Customer_ID
WHERE t1.Customer_Gender = '' AND t2.Customer_Gender != '';

UPDATE sales_staging_2 t1
JOIN sales_staging_2 t2
	ON t1.Customer_ID = t2.Customer_ID
SET t1.Customer_Gender = t2.Customer_Gender
WHERE t1.Customer_Gender = '' AND t2.Customer_Gender != '';

SELECT *
FROM sales_staging_2
WHERE Customer_Gender = '';

UPDATE sales_staging_2
SET Customer_Gender = 'Unknown'
WHERE Customer_Gender = '';

-- Fill in blank ages - 17 still NULL

SELECT *
FROM sales_staging_2
WHERE Customer_Age IS NULL OR Customer_Age = '';

SELECT
	t1.Customer_Age,
	t2.Customer_Age
FROM sales_staging_2 t1
JOIN sales_staging_2 t2
	ON t1.Customer_ID = t2.Customer_ID
WHERE t1.Customer_Age IS NULL AND t2.Customer_Age IS NOT NULL;

UPDATE sales_staging_2 t1
JOIN sales_staging_2 t2
	ON t1.Customer_ID = t2.Customer_ID
SET t1.Customer_Age = t2.Customer_Age
WHERE t1.Customer_Age IS NULL AND t2.Customer_Age IS NOT NULL;

-- Fill in blank product names

SELECT *
FROM sales_staging_2
WHERE Product_Name = '';

SELECT
	t1.Product_Name,
	t2.Product_Name
FROM sales_staging_2 t1
JOIN sales_staging_2 t2
	ON t1.Product_ID = t2.Product_ID
WHERE t1.Product_Name = '' AND t2.Product_Name != '';

UPDATE sales_staging_2 t1
JOIN sales_staging_2 t2
	ON t1.Product_ID = t2.Product_ID
SET t1.Product_Name = t2.Product_Name
WHERE t1.Product_Name = '' AND t2.Product_Name != '';


-- Fill in blank payment methods (no join possible)

SELECT *
FROM sales_staging_2
WHERE Payment_Method = '';

SELECT
	t1.Payment_Method,
	t2.Payment_Method
FROM sales_staging_2 t1
JOIN sales_staging_2 t2
	ON t1.Transaction_ID = t2.Transaction_ID
WHERE t1.Payment_Method = '' AND t2.Payment_Method != '';

UPDATE sales_staging_2
SET Payment_Method = 'Unknown'
WHERE Payment_Method = '';

-- 
SELECT *
FROM sales_staging_2
WHERE Store_ID = '';


-- Remove unnecessary columns
ALTER TABLE sales_staging_2 
DROP COLUMN row_num;











