USE [BankCard];
GO

-- user
-- ==== 1- Nulls ====

SELECT 
	SUM(CASE WHEN id IS NULL OR id = '' THEN 1 ELSE 0 END ) AS blank_id,
	SUM(CASE WHEN current_age IS NULL OR current_age = '' THEN 1 ELSE 0 END) AS blank_age,
	SUM(CASE WHEN [per_capita_income] IS NULL OR [per_capita_income]  = '' THEN 1 ELSE 0 END) AS blank_capita,
	SUM(CASE WHEN [credit_score] IS NULL OR [credit_score] = '' THEN 1 ELSE 0 END) AS blank_credit_Score
FROM Bronze.[user];

-- ==== 2- Numeric Conversion ====

SELECT * 
FROM Bronze.[user]
WHERE TRY_CAST([id] AS INT) IS NULL;


SELECT * 
FROM Bronze.[user]
WHERE TRY_CAST([current_age] AS INT) IS NULL;


SELECT * 
FROM Bronze.[user]
WHERE TRY_CAST([credit_score] AS INT) IS NULL;



SELECT * 
FROM Bronze.[user]
WHERE TRY_CAST(REPLACE([per_capita_income], '$', '') AS INT) IS NULL;


SELECT * 
FROM Bronze.[user]
WHERE TRY_CAST(REPLACE([yearly_income], '$', '') AS INT) IS NULL;


SELECT * 
FROM Bronze.[user]
WHERE TRY_CAST(REPLACE([total_debt], '$', '') AS INT) IS NULL;


-- ==== 3- Out of range ====

SELECT * 
FROM Bronze.[user]
WHERE TRY_CAST([current_age] AS INT) NOT BETWEEN 0 AND 120;


SELECT * 
FROM Bronze.[user]
WHERE TRY_CAST([current_age] AS INT) > TRY_CAST([retirement_age] AS INT);

-- ==== 4- Inconsistent categories ====

SELECT DISTINCT 
	gender,
	COUNT(*) AS CNT
FROM Bronze.[user]
GROUP BY (gender);

-- ==== 5- Check ID Duplicates ====

SELECT 
	id,
	COUNT(*) AS CNT
FROM Bronze.[user]
GROUP BY (id)
HAVING COUNT(*) > 1;

-- ==== 6- Rows Count ====

SELECT COUNT(*) AS total_rows
FROM Bronze.[user];




-- Cards
-- ==== 1- Nulls ====

SELECT 
	SUM(CASE WHEN id IS NULL OR id = '' THEN 1 ELSE 0 END ) AS blank_id,
	SUM(CASE WHEN [client_id] IS NULL OR [client_id] = '' THEN 1 ELSE 0 END) AS blank_client_id,
	SUM(CASE WHEN [credit_limit] IS NULL OR [credit_limit]  = '' THEN 1 ELSE 0 END) AS blank_credit_limit,
	SUM(CASE WHEN [has_chip] IS NULL OR [has_chip] = '' THEN 1 ELSE 0 END) AS blank_ship
FROM [Bronze].[card];

-- ==== 2- Orphan Cards ====

SELECT c.*
FROM [Bronze].[card] AS c
LEFT JOIN [Bronze].[user] AS u 
	ON TRY_CAST(c.[client_id] AS INT ) = TRY_CAST(u.[id] AS INT ) 
WHERE u.id IS NULL;

-- ==== 3- Innconsistent categories ====

SELECT DISTINCT
	[card_brand],
	COUNT (*) AS CNT
FROM [Bronze].[card]
GROUP BY [card_brand];

SELECT DISTINCT
	[card_type],
	COUNT (*) AS CNT
FROM [Bronze].[card]
GROUP BY [card_type];

SELECT DISTINCT
	[has_chip],
	COUNT (*) AS CNT
FROM [Bronze].[card]
GROUP BY [has_chip];

SELECT DISTINCT
	[card_on_dark_web],
	COUNT (*) AS CNT
FROM [Bronze].[card]
GROUP BY [card_on_dark_web];

-- ==== 4- limit Conversion ====

SELECT * 
FROM[Bronze].[card]
WHERE TRY_CAST(REPLACE([credit_limit], '$', '') AS INT) IS NULL;

-- ==== 5- Check Duplicates ====

SELECT 
	id,
	COUNT(*) AS CNT
FROM [Bronze].[card]
GROUP BY (id)
HAVING COUNT(*) > 1;

-- ==== 6- Row Count ====

SELECT COUNT(*) AS Total_Rows FROM Bronze.card;




-- transaction
-- ==== 1- Nulls ====

SELECT 
	SUM(CASE WHEN id IS NULL OR id = '' THEN 1 ELSE 0 END ) AS blank_id,
	SUM(CASE WHEN [date] IS NULL OR [date] = '' THEN 1 ELSE 0 END) AS blank_date,
	SUM(CASE WHEN [amount] IS NULL OR [amount]  = '' THEN 1 ELSE 0 END) AS blank_amount,
	SUM(CASE WHEN [merchant_city] IS NULL OR [merchant_city] = '' THEN 1 ELSE 0 END) AS blank_merchant_city,
	SUM(CASE WHEN [merchant_state] IS NULL OR [merchant_state] = '' THEN 1 ELSE 0 END) AS blank_merchant_state,
	SUM(CASE WHEN [errors] IS NULL OR [errors] = '' THEN 1 ELSE 0 END) AS blank_errors
FROM [Bronze].[transaction];

-- ==== 2- Confirm blank city/state/zip ====

SELECT
	[use_chip],
	COUNT(*) AS CNT
FROM [Bronze].[transaction]
WHERE [merchant_city] IS NULL OR [merchant_city] = ''
GROUP BY [use_chip]

-- ==== 3- Date Conversion ====

SELECT *
FROM [Bronze].[transaction]
WHERE TRY_CAST([date] AS DATE) IS NULL;

-- ==== 4- Numerical Conversion ====

SELECT *
FROM [Bronze].[transaction]
WHERE TRY_CAST(REPLACE([amount], '$', '') AS DECIMAL(12,2)) IS NULL;

-- ==== 5- Orphan transactions ====

SELECT COUNT(*) AS orphan_users
FROM [Bronze].[transaction] AS t
LEFT JOIN [Bronze].[user] AS u
	ON TRY_CAST(u.id AS INT) = TRY_CAST(t.client_id AS INT)
WHERE u.id IS NULL;


SELECT COUNT(*) AS orphan_cards
FROM [Bronze].[transaction] AS t
LEFT JOIN [Bronze].[card] AS c
	ON TRY_CAST(c.id AS INT) = TRY_CAST(t.[card_id] AS INT)
WHERE c.id IS NULL;

-- ==== 6- mcc conversion ====

SELECT *
FROM [Bronze].[transaction]
WHERE TRY_CAST([mcc] AS INT) IS NULL;

-- ==== 7- Distinct error types ====

SELECT DISTINCT
	errors,
	COUNT(*) AS CNT
FROM [Bronze].[transaction]
WHERE errors IS NOT NULL AND errors <> ''
GROUP BY errors
ORDER BY CNT DESC;

-- ==== 8- Distinct use_chip ====

SELECT DISTINCT 
	[use_chip],
	COUNT(*) AS CNT
FROM [Bronze].[transaction]
GROUP BY [use_chip]

-- ==== 9- Duplicate ====

SELECT
	id,
	COUNT(*) AS CNT
FROM [Bronze].[transaction]
GROUP BY id
HAVING COUNT(*) > 1;

SELECT 
	[merchant_id],
	COUNT(DISTINCT mcc) AS distinct_mcc_count
FROM [Bronze].[transaction]
GROUP BY [merchant_id]
HAVING COUNT(DISTINCT mcc) > 1
ORDER BY distinct_mcc_count DESC;
