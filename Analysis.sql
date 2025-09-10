-- Q1.As a product owner, I want to generate a report of individual product sales 
-- (aggregated on a monthly basis at the product code level) for Croma India customer for FY=2021 so that 
-- I can track individual product sales and run further product analytics on it in excel.
-- The report should have the following fields,
-- 1. Month
-- 2. Product Name
-- 3. Variant
-- 4. Sold Quantity
-- 5. Gross Price Per Item
-- 6. Gross Price Total


SELECT 
		s.date,
        s.product_code,
        p.product,
        p.variant,
        s.sold_quantity,
        g.gross_price,
        ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total
FROM fact_sales_monthly s
JOIN dim_product p
ON 
	p.product_code = s.product_code
JOIN fact_gross_price g
ON 
	g.product_code = s.product_code
	AND g.fiscal_year = get_fiscal_year(s.date)
WHERE 
	customer_code = 90002002
	AND get_fiscal_year(s.date) = 2021
ORDER BY s.date ASC
LIMIT 10000000;
    
SELECT
		* 
FROM fact_sales_monthly
WHERE 
		get_fiscal_year(date) = 2021 and
        get_fiscal_quarter(date) = "Q4"
ORDER BY date
LIMIT 1000000;



-- Q2. As a product owner, I need an aggregate monthly gross sales report for Croma India Customer so that I can track 
-- how much sales this particular customer is generating for AtliQ and manage our relationship accordingly.

-- the report should hav the following fields,
-- 1. Month
-- 2. Total gross sales amount to Croma India in this month

SELECT 
		s.date,
        ROUND(SUM(s.sold_quantity * g.gross_price),2) as monthly_gross_sales
FROM fact_sales_monthly s
JOIN fact_gross_price g
ON 
	s.product_code = g.product_code AND
    g.fiscal_year = get_fiscal_year(s.date)
WHERE customer_code = 90002002 
GROUP BY s.date
ORDER BY s.date ASC;

-- Q3. Generate a yearly report for Croma India where there are two columns
-- 1.Fiscal Year
-- 2.Total Gross Sales amount in that year from Croma

SELECT 
		g.fiscal_year,
        ROUND(SUM(s.sold_quantity * g.gross_price),2) as yearly_gross_sales
FROM fact_sales_monthly s
JOIN fact_gross_price g
ON 
	s.product_code = g.product_code AND
    g.fiscal_year = get_fiscal_year(s.date)
WHERE customer_code = 90002002 
GROUP BY g.fiscal_year
ORDER BY g.fiscal_year ASC;

-- Q4.Create a stored process that can determine the market badge based on the following logic,
-- If total sold quantity > 5 million that market is considered Gold else it is Silver

-- My input will be
-- • market
-- • fiscal year
-- Output 
-- • market badge

-- India, 2021 --> Gold
-- Srilanka, 2020 --> Silver

-- CREATE DEFINER=`root`@`localhost` PROCEDURE `get_market_badge`(
-- 	IN in_market VARCHAR(45),
-- 	IN in_fiscal_year year,
--     OUT out_badge VARCHAR(45)
-- )
-- BEGIN
-- DECLARE qty int default 0; # variable name, datatype and default value is 0
-- IF in_market ="" THEN
-- 	SET in_market = "India";
-- END IF;    
-- # retrieve total qty for a given market + financial year
-- 	SELECT 
-- 		SUM(sold_quantity) INTO qty
-- 	FROM fact_sales_monthly s
-- 	JOIN dim_customer c
-- 	ON s.customer_code=c.customer_code
-- 	WHERE 	
-- 			get_fiscal_year(s.date)=in_fiscal_year 
--             and c.market = in_market
-- 	GROUP BY c.market;
--     # determine market badge
--     
--     if qty > 5000000 then 
-- 		set out_badge = "Gold";
-- 	else
-- 		set out_badge = "Silver";
-- 	end if;
-- END

-- Q5.As a product owner, I want a report for top markets, products, customers by net sales for a given financial year 
-- so that I can have a holistic view of our financial performance and can take appropriate actions to address any potential issues.
-- We will probably write stored proc for this as we will need is report going forward as well.

 -- create this view

-- CREATE 
--     ALGORITHM = UNDEFINED 
--     DEFINER = `root`@`localhost` 
--     SQL SECURITY DEFINER
-- VIEW `sales_preinv_discount` AS
--     SELECT 
--         `s`.`date` AS `date`,
--         `s`.`fiscal_year` AS `fiscal_year`,
--         `s`.`product_code` AS `product_code`,
--         `s`.`customer_code` AS `customer_code`,
--         `c`.`market` AS `market`,
--         `p`.`product` AS `product`,
--         `p`.`variant` AS `variant`,
--         `s`.`sold_quantity` AS `sold_quantity`,
--         `g`.`gross_price` AS `gross_price`,
--         ROUND((`g`.`gross_price` * `s`.`sold_quantity`),
--                 2) AS `gross_price_total`,
--         `pre`.`pre_invoice_discount_pct` AS `pre_invoice_discount_pct`
--     FROM
--         ((((`fact_sales_monthly` `s`
--         JOIN `dim_customer` `c` ON ((`s`.`customer_code` = `c`.`customer_code`)))
--         JOIN `dim_product` `p` ON ((`p`.`product_code` = `s`.`product_code`)))
--         JOIN `fact_gross_price` `g` ON (((`g`.`product_code` = `s`.`product_code`)
--             AND (`g`.`fiscal_year` = `s`.`fiscal_year`))))
--         JOIN `fact_pre_invoice_deductions` `pre` ON (((`pre`.`customer_code` = `s`.`customer_code`)
--             AND (`pre`.`fiscal_year` = `s`.`fiscal_year`))))

-- create this view also

-- CREATE 
--     ALGORITHM = UNDEFINED 
--     DEFINER = `root`@`localhost` 
--     SQL SECURITY DEFINER
-- VIEW `sales_postinv_discount` AS
--     SELECT 
--         `s`.`date` AS `date`,
--         `s`.`fiscal_year` AS `fiscal_year`,
--         `s`.`market` AS `market`,
--         `s`.`product_code` AS `product_code`,
--         `s`.`customer_code` AS `customer_code`,
--         `s`.`product` AS `product`,
--         `s`.`variant` AS `variant`,
--         `s`.`sold_quantity` AS `sold_quantity`,
--         `s`.`gross_price_total` AS `gross_price_total`,
--         `s`.`pre_invoice_discount_pct` AS `pre_invoice_discount_pct`,
--         ((1 - `s`.`pre_invoice_discount_pct`) * `s`.`gross_price_total`) AS `net_invoice_sales`,
--         (`po`.`other_deductions_pct` + `po`.`discounts_pct`) AS `post_invoice_discount_pct`
--     FROM
--         (`sales_preinv_discount` `s`
--         JOIN `fact_post_invoice_deductions` `po` ON (((`s`.`date` = `po`.`date`)
--             AND (`s`.`product_code` = `po`.`product_code`)
--             AND (`s`.`customer_code` = `po`.`customer_code`))))

-- using these views we easily get the net sales 

SELECT 
		*,
        (1-post_invoice_discount_pct) * net_invoice_sales as net_sales
FROM sales_postinv_discount;

-- this will get us the Net Sales, Create a view of this also for later use

-- Q6. Create a View Net Sales and then top 5 customers from them 

SELECT 
		customer, 
        round(SUM(net_sales)/1000000,2) AS net_sales_mln
FROM gdb0041.net_sales n
JOIN dim_customer c
ON
	n.customer_code = c.customer_code
WHERE fiscal_year = 2021 
GROUP  BY customer
ORDER BY net_sales_mln DESC
LIMIT 5;

-- Additional Query With pct
with cte1 as 
(
SELECT 
		customer, 
        round(SUM(net_sales)/1000000,2) AS net_sales_mln
FROM gdb0041.net_sales n
JOIN dim_customer c
ON
	n.customer_code = c.customer_code
WHERE fiscal_year = 2021
GROUP  BY customer
ORDER BY net_sales_mln DESC
)
SELECT 
		*,
        net_sales_mln * 100 /sum(net_sales_mln) over() as pct
FROM cte1;

-- Q7. as a product owner i want to see a bar chart report for FY=2021 for top 10 markets by % net sales. 

SELECT 
		market,
        ROUND(sum(net_sales)/1000000,2) as net_sales_mln
FROM gdb0041.net_sales
WHERE fiscal_year = 2021
GROUP BY market
ORDER BY net_sales_mln DESC
LIMIT 5;

-- Q8. Write a stored procedure to get the top n products by net sales for a given year.  
-- Use product name without a variant. Input of stored procedure is fiscal_year and top_n parameter

SELECT 
		product,
        ROUND(sum(net_sales)/1000000,2) as net_sales_mln
FROM net_sales
WHERE 
   fiscal_year = 2021
GROUP BY product
ORDER BY net_sales_mln DESC
LIMIT 5;

-- Q9.As a product owner, I want to see region wise (APAC, EU, LTAM etc) % net sales breakdown by customers in a 
-- respective region so that I can perform my regional analysis on financial performance of the company.
-- The end result should be bar charts in the following format for FY=2021. Build a reusable asset that we can 
-- use to conduct this analysis for any financial year.

with cte1 as 
(
SELECT
		c.customer,
        c.region,
		ROUND(sum(n.net_sales)/1000000,2) as net_sales_mln
FROM net_sales n
JOIN dim_customer c
ON 
	c.customer_code = n.customer_code
WHERE fiscal_year = 2021
GROUP BY c.customer,c.region
ORDER BY net_sales_mln DESC
)
SELECT
		*,
        net_sales_mln * 100 / SUM(net_sales_mln) OVER(PARTITION BY region) as pct
FROM cte1;

-- Q10.Write a stored proc for getting TOP n products in each division by their quantity sold in a given financial year. 
-- For example below would be the result for FY=2021.

WITH cte1 AS
(
SELECT 
		p.product,
        p.division,
        sum(n.sold_quantity) AS sold_qty
FROM net_sales n
JOIN dim_product p
ON
	p.product_code = n.product_code
WHERE fiscal_year = 2021
GROUP BY p.product,p.division
), cte2 AS
(
SELECT 
		*,
        DENSE_RANK() OVER(PARTITION BY division ORDER BY sold_qty DESC) AS drnk
FROM cte1
)
SELECT 
		*
FROM cte2
WHERE drnk <= 3;

-- Q11.Retrieve the top 2 markets in every region by their gross sales amount in FY=2021. 

WITH cte1 AS 
(
SELECT 
		market,
        region,
        ROUND(SUM(gross_price_total) /1000000,2) as gross_price_mln
FROM gross_price_total_pro 
WHERE fiscal_year = 2021
GROUP BY region,market
), cte2 AS
(
SELECT 
		*,
        DENSE_RANK() OVER(PARTITION BY region ORDER BY gross_price_mln) as drnk
FROM cte1
)
SELECT 
		*
FROM cte2 
WHERE drnk <= 2 ;



-- Q12.Get Forecast Accuracy

WITH forecast_err_table AS
(
SELECT 
		s.customer_code,
        c.customer as customer_name,
        c.market as market,
		sum(s.sold_quantity) as total_sold_qty,
		sum(s.forecast_quantity) as total_forecast_qty,
        sum(forecast_quantity-sold_quantity) as net_err,
        sum((forecast_quantity-sold_quantity))*100/sum(forecast_quantity) as net_err_pct,
        sum(abs(forecast_quantity-sold_quantity)) as abs_err,
        sum(abs(forecast_quantity-sold_quantity))*100/sum(forecast_quantity) as abs_err_pct
FROM fact_act_est s
JOIN dim_customer c
ON
	c.customer_code = s.customer_code
WHERE s.fiscal_year = 2021
GROUP BY s.customer_code
)

SELECT 
		*,
        if(abs_err_pct >100, 0, 100-abs_err_pct) as forecast_accuracy
FROM forecast_err_table
ORDER BY forecast_accuracy DESC;


-- Q13.Write a query for the below scenario.
-- The supply chain business manager wants to see which customers’ forecast accuracy has dropped from 2020 to 2021. 
-- Provide a complete report with these columns: customer_code, customer_name, market, forecast_accuracy_2020, 
-- forecast_accuracy_2021
drop table if exists forecast_accuracy_2021;
CREATE TEMPORARY TABLE  forecast_accuracy_2021

WITH forecast_err_table AS
(
SELECT 
		s.customer_code,
        c.customer as customer_name,
        c.market as market,
		sum(s.sold_quantity) as total_sold_qty,
		sum(s.forecast_quantity) as total_forecast_qty,
        sum(forecast_quantity-sold_quantity) as net_err,
        sum((forecast_quantity-sold_quantity))*100/sum(forecast_quantity) as net_err_pct,
        sum(abs(forecast_quantity-sold_quantity)) as abs_err,
        sum(abs(forecast_quantity-sold_quantity))*100/sum(forecast_quantity) as abs_err_pct
FROM fact_act_est s
JOIN dim_customer c
ON
	c.customer_code = s.customer_code
WHERE s.fiscal_year = 2021
GROUP BY s.customer_code
)

SELECT 
		*,
        if(abs_err_pct >100, 0, 100-abs_err_pct) as forecast_accuracy_2021
FROM forecast_err_table
ORDER BY forecast_accuracy_2021 DESC;

drop table if exists forecast_accuracy_2020;
CREATE TEMPORARY TABLE  forecast_accuracy_2020

WITH forecast_err_table AS
(
SELECT 
		s.customer_code,
        c.customer as customer_name,
        c.market as market,
		sum(s.sold_quantity) as total_sold_qty,
		sum(s.forecast_quantity) as total_forecast_qty,
        sum(forecast_quantity-sold_quantity) as net_err,
        sum((forecast_quantity-sold_quantity))*100/sum(forecast_quantity) as net_err_pct,
        sum(abs(forecast_quantity-sold_quantity)) as abs_err,
        sum(abs(forecast_quantity-sold_quantity))*100/sum(forecast_quantity) as abs_err_pct
FROM fact_act_est s
JOIN dim_customer c
ON
	c.customer_code = s.customer_code
WHERE s.fiscal_year = 2020
GROUP BY s.customer_code
)

SELECT 
		*,
        if(abs_err_pct >100, 0, 100-abs_err_pct) as forecast_accuracy_2020
FROM forecast_err_table
ORDER BY forecast_accuracy_2020 DESC;


SELECT 
		customer_code,
        customer_name,
        market,
        round(a.forecast_accuracy_2020,2),
        round(b.forecast_accuracy_2021,2)
FROM forecast_accuracy_2020 a
JOIN forecast_accuracy_2021 b
USING(customer_code,market,customer_name)