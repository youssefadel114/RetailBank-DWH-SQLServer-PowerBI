-- DimDate

CREATE TABLE Gold.DimDate (
	datekey    INT NOT NULL PRIMARY KEY,
	full_date  DATE NOT NULL,
	[year]     INT NOT NULL,
	[quarter]  INT NOT NULL,
	[month]    INT NOT NULL,
	month_name VARCHAR(20) NOT NULL,
	[day]	   INT NOT NULL,
	day_name   VARCHAR(20) NOT NULL,
	is_weekend BIT NOT NULL
);
GO

DECLARE @start_date DATE , @end_date DATE, @current_date DATE;

SELECT 
	@start_date = MIN([transaction_date]),
	@end_date = MAX([transaction_date])
FROM [Silver].[transaction];

SET @current_date = @start_date;

SELECT @start_date, @end_date, @current_date;

WHILE @current_date <=  @end_date
BEGIN
	INSERT INTO Gold.DimDate(
		datekey    ,
		full_date  ,
		[year]     ,
		[quarter]  ,
		[month]    ,
		month_name ,
		[day]	   ,
		day_name   ,
		is_weekend)
	VALUES(
		CAST(FORMAT(@current_date, 'yyyyMMdd') AS INT),
		@current_date,
		YEAR(@current_date),
		DATEPART(QUARTER,@current_date),
		MONTH(@current_date),
		DATENAME(MONTH, @current_date),
		DAY(@current_date),
		DATENAME(WEEKDAY, @current_date),
		CASE 
			WHEN  DATEPART(WEEKDAY, @current_date) IN (1,7) THEN 1
			ELSE 0
		END
	);

	SET  @current_date = DATEADD(DAY,1, @current_date)
END;

SELECT * FROM  Gold.DimDate



-- DimUser
SELECT *
INTO Gold.DimUser
FROM [Silver].[user];

ALTER TABLE Gold.DimUser ALTER COLUMN user_id INT NOT NULL;
ALTER TABLE Gold.DimUser ADD CONSTRAINT PK_DimUser PRIMARY KEY (user_id);



--DimCard
SELECT *
INTO Gold.DimCard
FROM [Silver].[card];


ALTER TABLE Gold.DimCard ALTER COLUMN card_id INT NOT NULL;
ALTER TABLE Gold.DimCard ADD CONSTRAINT PK_DimCard PRIMARY KEY (card_id);



-- DimMerchant
WITH MerchantMcc AS (
	SELECT
		[merchant_id],
		mcc,
		COUNT(*) AS CNT,
		ROW_NUMBER() OVER (PARTITION BY [merchant_id] ORDER BY COUNT(*) DESC) AS rn
	FROM [Silver].[transaction]
	GROUP BY [merchant_id], mcc
)

SELECT 
	[merchant_id],
	mcc
INTO Gold.DimMerchant
FROM MerchantMcc
WHERE rn = 1;


ALTER TABLE Gold.DimMerchant ALTER COLUMN [merchant_id] INT NOT NULL;
ALTER TABLE Gold.DimMerchant ADD CONSTRAINT PK_DimMerchant PRIMARY KEY ( [merchant_id]);




-- FactTransaction

SELECT
	[transaction_id],
	CAST(FORMAT([transaction_date], 'yyyyMMdd') AS INT) AS date_key,
	[user_id],
	[card_id],
	[amount],
	[use_chip],
	[merchant_id],
	[merchant_city],
	[merchant_state],
	[zip],
	[mcc],
	[errors],
	[has_error]
INTO Gold.FactTransaction
FROM [Silver].[transaction]



ALTER TABLE Gold.FactTransaction ALTER COLUMN [transaction_id] INT NOT NULL;
ALTER TABLE Gold.FactTransaction ADD CONSTRAINT PK_FactTransaction PRIMARY KEY ([transaction_id]);





-- foreign keys

ALTER TABLE Gold.FactTransaction
	ADD CONSTRAINT FK_Fact_DimDate FOREIGN KEY (date_key) 
	REFERENCES Gold.DimDate ([datekey]);
GO


ALTER TABLE Gold.FactTransaction
	ADD CONSTRAINT FK_Fact_DimUser FOREIGN KEY ([user_id]) 
	REFERENCES Gold.DimUser ([user_id]);
GO


ALTER TABLE Gold.FactTransaction
	ADD CONSTRAINT FK_Fact_DimMerchant FOREIGN KEY ([merchant_id]) 
	REFERENCES Gold.DimMerchant ([merchant_id]);
GO





-- Indexes
CREATE INDEX IX_Fact_DateKey    ON Gold.FactTransaction (date_key);
CREATE INDEX IX_Fact_UserId     ON Gold.FactTransaction ([user_id]);
CREATE INDEX IX_Fact_CardId     ON Gold.FactTransaction ([card_id]);
CREATE INDEX IX_Fact_MerchantId ON Gold.FactTransaction ([merchant_id]);