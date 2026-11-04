RetailBank Data Warehouse (SQL Server + Power BI)
End-to-end banking data warehouse built on SQL Server
Uses the Medallion Architecture (Bronze → Silver → Gold)
Consumed by a one-page Power BI dashboard on transaction performance
Main goal: DWH design and ETL, with the dashboard as a simple consumption layer
Dashboard Preview

Dashboard

Key metrics

Transactions: ~3M
Total transaction amount: ~111M
Average transaction amount: 43.44
Users: ~2K
Cards: ~6K

Highlights

Volume was steady from 2010 (~54M) to 2011 (~56M)
Gender split is nearly even: 50.8% female, 49.2% male
Online transactions dominate (~16.1M vs. ~1.3M for top city, Houston)
Mastercard (~3.2K) and Visa (~2.3K) lead card brands, followed by Amex and Discover
Architecture
Raw CSV files → BRONZE → SILVER → GOLD → Power BI
Bronze
Raw data loaded as-is
No transformations
Silver
Cleaning and type casting
Standardization
Data validation checks
Gold
Business-ready star schema
Fact table + dimension tables
Optimized for analytics and reporting
Data Validation

Users (2,000 rows)

No nulls
Numeric values checked
No age outliers (current age vs. retirement age consistent)
No inconsistent gender values
No duplicate IDs

Cards (6,146 rows)

No nulls
No orphan cards (every card maps to a user)
No inconsistent values in card brand, card type, or has-chip
Credit limit conversion and comparison passed
No duplicate IDs

Transactions

Date and numeric conversions passed
MCC conversion checked
Null merchant_state (~277K) explained by online transactions (no physical location)
No issues in merchant_city, same online-transaction reason
Most common error: Insufficient Balance
Swipe transactions dominate over chip and online use
No duplicate IDs

TODO: verify exact counts against your SQL output before publishing.

Gold Layer: Data Model

Data Model

TODO: replace with your final Gold layer diagram
Fact table: transactions
Dimensions: users, cards, merchants/location, date
Tech Stack
SQL Server (T-SQL, stored procedures)
SSMS
Power BI
Git / GitHub
