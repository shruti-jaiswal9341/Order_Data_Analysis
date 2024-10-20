----We are going to solve some important for order sales analysis that help to give a best optimization---

-- 1.Find top 10 highest reveue generating products.

Select product_id,sum(sales_price) as sales
from df_ordersales
group by product_id
order by sales desc
limit 10

--2.Find top 5 highest selling products in each region

SELECT region, product_id, sales
FROM (
    SELECT region, product_id, 
           SUM(sales_price) AS sales,
           RANK() OVER (PARTITION BY region ORDER BY SUM(sales_price) DESC) AS rank
    FROM df_ordersales
    GROUP BY region, product_id
) ranked
WHERE rank <= 5
ORDER BY region, rank;

--3.Find month over growth comparison for 2022 and 2023 sales eg :jan 2022 vs jan 2023

WITH cte AS (
    SELECT 
        EXTRACT(YEAR FROM order_date) AS order_year,
        EXTRACT(MONTH FROM order_date) AS order_month,
        SUM(sales_price) AS sales
    FROM df_ordersales
    GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
)
SELECT 
    order_month,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;


--4.For each category which month had highest sales 

with cte as (
select category
,TO_CHAR(order_date,'yyyy') as order_year
,TO_CHAR(order_date,'MM') as order_month
, sum(sales_price) as sales 
from df_ordersales
group by category,TO_CHAR(order_date,'yyyy'),TO_CHAR(order_date,'MM')
)
select * from (
select *,
row_number() over(partition by category order by sales desc) as rn
from cte
) a
where rn=1


--5.which sub category had highest growth by profit in 2023 compare to 2022

SELECT 
    sub_category,
    SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2022 THEN sales_price ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2023 THEN sales_price ELSE 0 END) AS sales_2023,
    (SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2023 THEN sales_price ELSE 0 END) - 
     SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2022 THEN sales_price ELSE 0 END)) AS growth
FROM df_ordersales
GROUP BY sub_category
ORDER BY growth DESC
LIMIT 1;




