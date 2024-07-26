create database Final_Project_Guvi
Use  final_project_guvi
# Write a SQL query to join the customers and orders tables and select relevant customer details.
Select * from customers inner join orders on customers.customer_id = orders.customer_id;
#Use aggregate functions like SUM and GROUP BY to calculate total sales from the orders and order_items tables.
Select order_items.order_id,
SUM(order_items.quantity * order_items.list_price) as Total_Sales
from order_items  group by order_id;
#Write a subquery to identify products in the products table that do not appear in the order_items table.
Select* from Products where product_id Not in (select product_id from order_items);
#Write a SQL query to join the staffs table with itself to get staff and their manager information.
SELECT 
    s.staff_id AS employee_id,
    s.first_name AS employee_first_name,
    s.last_name AS employee_last_name,
    s.email AS employee_email,
    s.phone AS employee_phone,
    s.active AS employee_active,
    s.store_id AS employee_store_id,
    s.manager_id AS employee_manager_id,
    m.staff_id AS manager_id,
    m.first_name AS manager_first_name,
    m.last_name AS manager_last_name,
    m.email AS manager_email,
    m.phone AS manager_phone,
    m.active AS manager_active,
    m.store_id AS manager_store_id,
    m.manager_id AS manager_manager_id
FROM 
    staffs s
LEFT JOIN 
    staffs m ON s.manager_id = m.staff_id;
#Use window functions like ROW_NUMBER() or RANK() to rank stores based on total sales.
with store_sales as (
Select
 s.store_id, 
 s.store_name, 
 Round (sum(oi.quantity*oi.list_price*(1-oi.discount)),2)as Total_Sales
From
 orders o
Join
 order_items oi on o.order_id = oi.order_id
Join
 Stores s on o.store_id = s.store_id
group by
 s.store_id , s.store_name
 )
Select 
 store_id, store_name, Total_sales,
 Rank() over(order by total_sales desc) as sales_rank
From store_sales order by sales_rank;
#Use date functions to calculate the difference between shipped_date and order_date in the orders table.
SELECT order_id, order_date, shipped_date, (shipped_date - order_date) AS days_between FROM orders;
#Use CASE statements to categorize orders in the orders table into different status groups
Select order_id, customer_id, order_status, order_date, shipped_date, store_id, staff_id,
case
 When order_status = 4 Then 'order_delivered'
 When order_status in (1,2,3) Then 'Pending for Shippment'
 Else 'Other_Orders'
 End As Dleivery_Status
 from orders;
#Write a SQL query to join the orders, order_items, products, and stores tables
Select 
 o.order_id, o.customer_id, o.order_status, o.order_date, o.required_date, o.shipped_date, o.store_id, o.staff_id,
 oi.order_id, oi.item_id, oi.product_id, oi.quantity, oi.list_price as items_list_price, oi.discount,
 s.store_id, s.store_name, s.phone, s.email, s.street, s.city, s.state, s.zip_code,
 p.product_id, p.product_name, p.brand_id, p.category_id, p.model_year, p.list_price as Product_list_price
From orders o
Join order_items oi on o.order_id = oi.order_id
Join products P on oi.product_id = P.product_id
Join Stores S on o.store_id = s.store_id;
#Use CREATE TEMPORARY TABLE to store results of a complex calculation for further analysis
CREATE TEMPORARY TABLE temp_total_sales AS
SELECT 
    o.store_id,
    s.store_name,
    oi.product_id,
    p.product_name,
    Round(SUM(oi.quantity * oi.list_price * (1 - oi.discount)),2)AS total_sales
FROM 
    orders o
JOIN 
    order_items oi ON o.order_id = oi.order_id
JOIN 
    products p ON oi.product_id = p.product_id
JOIN 
    stores s ON o.store_id = s.store_id
GROUP BY 
    o.store_id, s.store_name, oi.product_id, p.product_name;
Select * from temp_total_sales;
#Create a stored procedure that updates the stocks table based on incoming shipment data.
