use coffee_shop_sales;
select * from coffee_sales; 

-- Revenue by store_location 
 SELECT 
 store_location,
 ROUND(SUM(transaction_qty * unit_price), 2) AS revenue
 FROM coffee_sales
 GROUP BY store_location
 ORDER BY revenue DESC;

-- Revenue by product_category
 SELECT 
     product_category,
     ROUND(SUM(transaction_qty * unit_price), 2) AS revenue
 FROM coffee_sales
 GROUP BY product_category
 ORDER BY revenue DESC;

-- Quantity sold by product
 SELECT 
     product_detail,
     SUM(transaction_qty) AS total_quantity
 FROM coffee_sales
 GROUP BY product_detail
 ORDER BY total_quantity DESC
 LIMIT 10;

-- Revenue by month
 SELECT 
     MONTHNAME(transaction_date) AS month,
     ROUND(SUM(transaction_qty * unit_price), 2) AS revenue
 FROM coffee_sales
 GROUP BY MONTH
 ORDER BY month;

-- orders by hours
 SELECT 
     HOUR(transaction_time) AS hour,
     COUNT(transaction_id) AS total_orders
 FROM coffee_sales
 GROUP BY HOUR(transaction_time)
 ORDER BY total_orders DESC;

-- Revenue by weekdays/weekends
 SELECT 
     CASE 
         WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekend'
         ELSE 'Weekday'
     END AS day_type,
     ROUND(SUM(transaction_qty * unit_price),2) AS revenue
 FROM coffee_sales
 GROUP BY day_type;

--  avg_order_value by store location
 SELECT 
     store_location,
     ROUND(SUM(transaction_qty * unit_price) / 
           COUNT(DISTINCT transaction_id), 2) AS avg_order_value
 FROM coffee_sales
 GROUP BY store_location
 ORDER BY avg_order_value DESC;

 -- Revenue % by product
 SELECT 
     product_category,
     ROUND(SUM(transaction_qty * unit_price) * 100 /
           (SELECT SUM(transaction_qty * unit_price) 
            FROM coffee_sales), 2) AS revenue_percent
 FROM coffee_sales
 GROUP BY product_category
 ORDER BY revenue_percent DESC;

-- store-wise category perfomance
 SELECT 
     store_location,
     product_category,
     ROUND(SUM(transaction_qty * unit_price),2) AS revenue
 FROM coffee_sales
 GROUP BY store_location, product_category
 ORDER BY store_location, revenue DESC;

 -- Running total of revenue
 SELECT 
     transaction_date,
     daily_revenue,
     round(SUM(daily_revenue) OVER (ORDER BY transaction_date),2) AS running_total
 FROM (
     SELECT 
         transaction_date,
         round(SUM(transaction_qty * unit_price),2) AS daily_revenue
     FROM coffee_sales
     GROUP BY transaction_date
 ) t;

 -- top 3 product in each category
 SELECT *
 FROM (
     SELECT 
         product_category,
         product_detail,
         SUM(transaction_qty) AS total_qty,
         RANK() OVER (PARTITION BY product_category 
                      ORDER BY SUM(transaction_qty) DESC) AS rank_in_category
     FROM coffee_sales
     GROUP BY product_category, product_detail
 ) t
 WHERE rank_in_category <= 3;

-- Compare Each Store Revenue to Overall Average
 SELECT 
     store_location,
     revenue,
     ROUND(AVG(revenue) OVER (),2) AS avg_revenue,
     ROUND(revenue - AVG(revenue) OVER (),2) AS difference
 FROM (
     SELECT
         store_location,
         ROUND(SUM(transaction_qty * unit_price),2) AS revenue
     FROM coffee_sales
     GROUP BY store_location
 ) t;

-- Monthly Growth % (MoM Growth)
 SELECT 
     month,
     revenue,
     ROUND(
         (revenue - LAG(revenue) OVER (ORDER BY month)) 
         / LAG(revenue) OVER (ORDER BY month) * 100, 2
     ) AS mom_growth_percent
 FROM (
     SELECT 
         MONTH(transaction_date) AS month,
         round(SUM(transaction_qty * unit_price),2) AS revenue
     FROM coffee_sales
     GROUP BY MONTH(transaction_date)
 ) t;


-- Moving Average (7-Day Sales Average)
 SELECT 
     transaction_date,
     daily_revenue,
     ROUND(
         AVG(daily_revenue) OVER (
             ORDER BY transaction_date 
             ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
         ), 2
     ) AS moving_avg_7days
 FROM (
     SELECT 
         transaction_date,
         round(SUM(transaction_qty * unit_price) ,2)AS daily_revenue
     FROM coffee_sales
     GROUP BY transaction_date
 ) t;