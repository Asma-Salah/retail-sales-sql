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
3. Q43
