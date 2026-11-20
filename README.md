# Retail Sales & Customer Intelligence (PostgreSQL)

SQL analysis of Duka Smart Electronics, a fictional Kenyan electronics retailer trading in ten towns since January 2025. I set up the database, answered 46 business questions in SQL, and wrote up what the results mean for management.

All people and companies in the data are fictional.

## What's in this repository

| File           | Purpose                                                |
| -------------- | ------------------------------------------------------ |
| `schema.sql`   | `CREATE TABLE` statements for `customers` and `orders` |
| `queries.sql`  | All 46 answers, numbered `-- Q1` to `-- Q46`           |
| `insights.md`  | Business insights drawn from the results               |
| `screenshots/` | Data verification output and selected query results    |

## The data

- **customers:** 150 rows (customer, city, segment, registration date)
- **orders:** 800 rows (product, category, quantity, prices, discount, payment method, status), from January 2025 to September 2026

## Business rules I applied

- Revenue = `quantity * unit_price * (1 - discount / 100)`
- Cost = `quantity * cost_price`; Profit = revenue - cost
- Money questions (revenue, cost, profit, spending) use **Completed** orders only
- Order counts include every status
- "Today" is the latest `order_date` in the data (2026-09-30), not the computer's date
- Months are year + month, using `DATE_TRUNC('month', order_date)`

## How to set it up

1. Install PostgreSQL 14 or newer and DBeaver.
2. In DBeaver, create a PostgreSQL connection (host `localhost`, port `5432`, user `postgres`).
3. Create a database named `retail_analytics` (right-click **Databases → Create New Database**, or run `CREATE DATABASE retail_analytics;`).
4. Connect to `retail_analytics` and run `schema.sql` with **Execute Script (Alt+X)**.
5. Load the data. The insert scripts come from the course and are not included here.
6. Check the load: 150 customers, 800 orders, and orders from 2025-01 to 2026-09.

## How to run the queries

### In DBeaver (main tool)

1. Open `queries.sql` (**File → Open File**) with the active connection set to `retail_analytics`.
2. Run one query at a time: select it and press **Ctrl+Enter**. Use **Alt+X** to run the whole script.
3. Q43 creates a view (`monthly_sales_summary`) and Q44 creates a function (`order_revenue_for`). Select the whole statement before running, because a blank line inside can split it.

### In VS Code (alternative)

1. Install the **SQLTools** and **SQLTools PostgreSQL/Cockroach Driver** extensions.
2. Add a PostgreSQL connection in SQLTools (server `localhost`, port `5432`, database `retail_analytics`, user `postgres`) and test it.
3. Open `queries.sql`, make sure the language mode says **SQL** and the connection is selected in the status bar.
4. Select a query, right-click, and choose **Run Selected Query**.

## Highlights

- Completed revenue is KSh 24.16M at an overall margin of about 12%, and Jan to Sep 2026 revenue is up 86% on the same months of 2025.
- Accessories are only 4.46% of revenue but have a 42.39% margin, against 9.92% to 11.38% for every other category.
- 43 High Value customers (a third of purchasing customers) bring in about 78% of revenue, and 8 of them have not ordered in over 90 days.

See `insights.md` for the full analysis.

## Tools

PostgreSQL 18, DBeaver, VS Code (SQLTools).
