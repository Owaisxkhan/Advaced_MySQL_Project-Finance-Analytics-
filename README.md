
# 📊 Retail Sales & Forecast Analytics (SQL Project)

## 📌 Project Overview  
This project solves **13 real-world business problems** for AtliQ’s retail customer data using **SQL (MySQL)**.  
It focuses on **sales analysis, revenue tracking, market performance, and forecast accuracy** by designing **queries, views, and stored procedures** to generate actionable insights.  

---

## 🚀 Key Features & Business Questions Solved  

1. **Monthly Product Sales Report** – Track individual product sales with quantity, price, and revenue.  
2. **Monthly Gross Sales Report** – Aggregate monthly revenue for Croma India.  
3. **Yearly Sales Report** – Total gross sales by fiscal year.  
4. **Market Badge Procedure** – Classify markets as **Gold/Silver** based on total sales volume.  
5. **Top Markets/Products/Customers** – Identify top performers by net sales in a given year.  
6. **Net Sales View** – Create a reusable view and fetch top 5 customers by sales.  
7. **Top Markets by % Net Sales** – Generate bar chart reports for FY2021.  
8. **Stored Procedure: Top N Products** – Get top products by net sales (parameterized by year & N).  
9. **Regional Sales Breakdown** – % net sales contribution by customers across APAC, EU, LATAM, etc.  
10. **Top N Products by Division** – Rank products by quantity sold within divisions.  
11. **Top 2 Markets per Region** – Gross sales analysis per region.  
12. **Forecast Accuracy Report** – Measure accuracy between forecasted vs actual sales.  
13. **Forecast Accuracy Drop (2020 → 2021)** – Identify customers with declining forecast performance.  

---

## 🛠️ Tech Stack  
- **Database:** MySQL  
- **SQL Features Used:** Joins, CTEs, Views, Window Functions, Stored Procedures, Aggregations, Ranking Functions  

---

## 📂 Project Structure  
```
├── Analysis.sql        # SQL scripts with solutions for Q1–Q13
├── SqlQuestions.pdf      # Problem statements
├── README.md             # Project documentation
```

---

## ⚡ How to Run the Project  

1. **Install MySQL**  
   - Download & install MySQL Server + Workbench from: https://dev.mysql.com/downloads/  

2. **Set up the Database**  
   - Import the dataset/tables provided (e.g., `fact_sales_monthly`, `dim_product`, `dim_customer`, etc.).  
   - Ensure all tables are created before running queries.  

3. **Run SQL Scripts**  
   - Open `AllQueries.sql` in MySQL Workbench (or any SQL IDE).  
   - Execute queries for Q1–Q13 one by one.  
   - Modify fiscal years or customer codes as needed for testing.  

4. **Use Views & Stored Procedures**  
   - Execute the `CREATE VIEW` and `CREATE PROCEDURE` scripts first.  
   - Then call the stored procedures (e.g., `CALL get_market_badge('India', 2021, @badge);`).  
   - Query the views (`SELECT * FROM net_sales;`) for recurring analytics.  

5. **(Optional) Visualization**  
   - Export query results to Excel/CSV.  
   - Create bar charts (e.g., top markets by sales, forecast accuracy trends).  

---

## 📈 Sample Insights  
- Identified **top 5 customers** contributing highest net sales in FY2021.  
- Classified India’s 2021 market as **Gold** (sales > 5M units).  
- Found customers with **declining forecast accuracy** from 2020 to 2021.  
- Generated reusable **views & stored procedures** for recurring financial analysis.  

---

## 🎯 Learning Outcomes  
- Hands-on experience with **real-world business queries** in SQL.  
- Ability to **design reusable SQL assets** (views & stored procs) for analytics.  
- Practical understanding of **sales, revenue, and forecasting KPIs**.  

---

## 📌 Author  
👤 **Owais Khan**  
📧 Email: trgxowais2gmail.com
🔗 LinkedIn: https://www.linkedin.com/in/owais-khan-008929265/

---

👉 This project demonstrates strong SQL skills in solving **business analytics problems** and can be used as a **Data Analyst/Business Analyst portfolio project**.  
