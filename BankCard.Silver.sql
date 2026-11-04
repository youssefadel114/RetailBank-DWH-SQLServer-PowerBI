USE BankCard;
Go

-- ====   Silver.user ====

SELECT
	TRY_CAST(id AS INT)					AS user_id,
	TRY_CAST([current_age] AS INT)		AS [current_age],
	TRY_CAST([retirement_age] AS INT)   AS [retirement_age],
	TRY_CAST([birth_year] AS INT)		AS [birth_year],
	TRY_CAST([birth_month] AS INT)		AS [birth_month],
	ISNULL( LTRIM(RTRIM(gender)) , '')  AS gender,
	ISNULL( LTRIM(RTRIM([address])) , '')   AS [address],
	TRY_CAST([latitude] AS DECIMAL(9,4))    AS [latitude],
	TRY_CAST([longitude] AS DECIMAL(9,4))   AS [longitude],
	TRY_CAST(REPLACE([per_capita_income], '$', '') AS INT) AS [per_capita_income],
	TRY_CAST(REPLACE([yearly_income], '$', '') AS INT)	   AS [yearly_income],
	TRY_CAST(REPLACE([total_debt], '$', '') AS INT)		   AS [total_debt],
	TRY_CAST([credit_score] AS INT)						   AS [credit_score],
	TRY_CAST([num_credit_cards] AS INT)					   AS [num_credit_cards]
INTO Silver.[user]
FROM [Bronze].[user];

ALTER TABLE Silver.[user] ALTER COLUMN user_id INT NOT NULL;

ALTER TABLE Silver.[user] ADD CONSTRAINT PK_Silver_user PRIMARY KEY (user_id);

-- ====   Silver.cards ====

SELECT
	TRY_CAST(id AS INT)								AS card_id,
	TRY_CAST([client_id] AS INT)					AS user_id,
	ISNULL( LTRIM(RTRIM([card_brand])) , '')		AS [card_brand],
	ISNULL( LTRIM(RTRIM([card_type])) , '')			AS [card_type],
	card_number,
	[expires],
	TRY_CAST([cvv] AS INT)						    AS [cvv],
	CASE
		WHEN UPPER(LTRIM(RTRIM([has_chip]))) = 'YES' THEN 1
		ELSE 0 
	END												AS [has_chip],
	TRY_CAST(id AS INT)								AS [num_cards_issued],
	TRY_CAST(REPLACE([credit_limit], '$', '') AS INT)		   AS [credit_limit],
	[acct_open_date],
	TRY_CAST([year_pin_last_changed] AS INT)				   AS [year_pin_last_changed],
	CASE
		WHEN UPPER(LTRIM(RTRIM([card_on_dark_web]))) = 'YES' THEN 1
		ELSE 0 
	END														   AS  [card_on_dark_web]
INTO  SIlver.[card]
FROM  [Bronze].[card];


ALTER TABLE [Silver].[card] ALTER COLUMN [card_id] INT NOT NULL;
ALTER TABLE [Silver].[card] ADD CONSTRAINT PK_Silver_card PRIMARY KEY ([card_id]);


-- ====   Silver.Transaction ====

SELECT
	TRY_CAST(id AS BIGINT)				AS transaction_id,
	TRY_CAST([date] AS DATE)			AS transaction_date,
	TRY_CAST([client_id] AS INT)		AS user_id,
	TRY_CAST([card_id] AS INT)		    AS [card_id],
	TRY_CAST(REPLACE([amount], '$', '') AS DECIMAL(12,2)) AS [amount],
	LTRIM(RTRIM([use_chip]))			AS [use_chip],
	TRY_CAST([merchant_id] AS INT)   AS [merchant_id],
	ISNULL(LTRIM(RTRIM([merchant_city])), '') AS [merchant_city],
	ISNULL(LTRIM(RTRIM([merchant_state])), '')AS [merchant_state],
	ISNULL(LTRIM(RTRIM([zip])), '')		      AS [zip],
	TRY_CAST([mcc] AS INT)					  AS [mcc],
	ISNULL(LTRIM(RTRIM([errors])), '')		  AS errors,
	CASE 
		WHEN ISNULL(LTRIM(RTRIM([errors])), '') = '' THEN 0
		ELSE 1
	END								          AS has_error
INTO Silver.[transaction]
FROM [Bronze].[transaction];

ALTER TABLE Silver.[transaction] ALTER COLUMN   transaction_id INT NOT NULL;
ALTER TABLE Silver.[transaction] ADD CONSTRAINT PK_Silver_transaction PRIMARY KEY (transaction_id);



SELECT TOP 5 *
FROM Silver.[transaction];

SELECT TOP 5 *
FROM [Silver].[card];

SELECT TOP 5 *
FROM [Silver].[user];