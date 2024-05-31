-- make assessment query...

-- 1. Convert Dataset to SQL Database:
-- Create SQL statements to define and populate tables for menu_details and order_details using the 
--provided dataset.

-- create new database called "restaurant_DB"
create database restaurant_DB;


use restaurant_DB



-- create table "fact table" "orders_detalis" ...

create table orders_detalis (
							order_details_id int not null primary key,
							order_id int not null ,
							order_date date null,
							order_time time null ,
							item_id int not null 
							)

//*
alter table orders_detalis
alter column order_date date 


alter table orders_detalis
alter column order_time time 

UPDATE orders_detalis 
SET order_time = CAST(order_time AS TIME);


select * from order_details

drop table [dbo].[order_details01]

*//

-- create table dimentional table "menu_detalis"

create table menu_detalis (
						   menu_item_id int not null primary key,
						   item_name varchar(100) null,
						   category varchar(100),
						   price decimal(12,2) null
)

select * from menu_detalis

-- create the dimation and relation between the tables.
-- add foreign key to fact table "orders_detalis" with referances menu_detalis(menu_item_id)

alter table orders_detalis
add foreign key (item_id)
references menu_detalis(menu_item_id)



 alter table order_details01
 drop column column1
 -- drop the primary key
 alter table order_details01
 drop constraint [PK_order_details01]
 -- add primary key
alter table order_details01
add primary key (order_details_id)


-- insert the data in the menu_detalis table...

bulk insert menu_detalis
from "D:\projects\internships\placementdost_company\SQL\SQL\SQL Restaurant orders\menu_items.csv"
with (
		fieldterminator = ',',
		rowterminator = '\n',
		firstrow = 2 -- to skip header row
)



-- 2. Basic SELECT Queries: 

-- Retrieve all columns from the menu_items table.
select * from menu_detalis


--  Display the first 5 rows from the order_details table.
select top 10 * from order_details01

--3. Filtering and Sorting:
 -- Select the item_name and price columns for items in the 'Main Course' category.
 select item_name, price, category 
 from menu_detalis
 where category = 'Main Course'

 -- Sort the result by price in descending order.'
 select item_name, price, category 
 from menu_detalis
 order by price desc


 --4. Aggregate Functions:
 --- Calculate the average price of menu items.
 select avg(price) as avg_price
 from menu_detalis

 --- Find the total number of orders placed.
 select count(order_details_id) from order_details01
 
 --- 5. Joins:
---  - Retrieve the item_name, order_date, and order_time for all items in the order_details table, including 
--- their respective menu item details.
 
 select 
		M.item_name,
		O.order_date,
		O.order_time 
 from 
	  menu_detalis M
join
	  order_details01 O on M.menu_item_id = O.item_id


--6. Subqueries:
-- List the menu items (item_name) with a price greater than the average price of all menu items.select 	item_namefrom	menu_detaliswhere price > ( select avg(price) from menu_detalis) --7. Date and Time Functions:
 -- Extract the month from the order_date and count the number of orders placed in each month.

 select month(order_date) as month_no ,
		count(order_date) as order_no
 from 
	order_details01
group by 
	month(order_date)
order by month(order_date)


--8. Group By and Having:
-- Show the categories with the average price greater than $15.
select
	  category,
	  avg(price) as average_price
from 
	menu_detalis
GROUP BY 
	category
having
	avg(price) > 15

-- Include the count of items in each category.select 	category,	count(item_name) item_no from	menu_detalisgroup by 	categoryselect * from menu_detalis--9. Conditional Statements:
-- Display the item_name and price, and indicate if the item is priced above $20 with a new column named 
--'Expensive'.-- create table called "Expensive" alter table menu_detalisadd Expensive varchar(100)-- we can update the value with condations.update menu_detalisset Expensive = case	when price > 20 then 'exp'	else 'normal'end;--Display the item_name and price.select 	item_name,	pricefrom	menu_detaliswhere 	Expensive = 'exp'-- there is  no value has value above 20$--10. Data Modification - Update:
-- Update the price of the menu item with item_id = 101 to $25select * from 	menu_detaliswhere menu_item_id = 101begin transaction;update menu_detalisset price = 25where menu_item_id = 101commit transaction;-- check your update...select * from menu_detaliswhere menu_item_id = 135--11. Data Modification - Insert:
-- Insert a new record into the menu_items table for a dessert item.insert into menu_detalisvalues (136,'dessert','Amricano',10,'normal');--12. Data Modification - Delete:
-- Delete all records from the order_details table where the order_id is less than 100

delete from order_details01
where order_id < 100
--check your result is working or not...

select * 
from 
	order_details01
where order_id < 100


--13. Window Functions - Rank:
-- Rank menu items based on their prices, displaying the item_name and its rank.select item_name,		price,		rank() over (order by price desc) as menu_item_rankfrom 	menu_detalis-- the result here will help to knew the rank of the price for example we have chicken torta-chicken tacos -chicken roll in the same rank of price we can choose anyone of them with same pirce rank 21-- and then semply we can knew any rank number ofter 21 it will be low price...

--14 - Window Functions - Lag and Lead:
-- Display the item_name and the price difference from the previous and next menu item.SELECT 
    item_name,
    price,
    price - LAG(price) OVER (ORDER BY price) AS diff_from_prev,
    LEAD(price) OVER (ORDER BY price) - price AS diff_from_next
FROM 
    menu_detalis;



 --15. Common Table Expressions (CTE):
 -- Create a CTE that lists menu items with prices above $15.
 select item_name 
 from 
	(select item_name,price from menu_detalis where price > 15) as ta
 -- Use the CTE to retrieve the count of such items. select	item_id, order_no from 	(select item_id , count(order_details_id) as order_no from order_details01 group by item_id)as tn--16. Advanced Joins:
-- Retrieve the order_id, item_name, and price for all orders with their respective menu item details.
-- Include rows even if there is no matching menu item.
select 
	O.order_id,
	M.item_name,
	M.price
from 
	order_details01 O
left join 
	menu_detalis M on M.menu_item_id = O.item_id


--17. Unpivot Data:
-- Unpivot the menu_items table to show a list of menu item properties (item_id, item_name, category, 
--price).

SELECT item_property, value
FROM 
    (SELECT menu_item_id, item_name, category, price
     FROM menu_detalis) as  p
UNPIVOT
    (value FOR item_property IN 
        (menu_item_id, 
         item_name, 
         category, 
         price)
    ) AS unpvt;


SELECT item_property, value
FROM 
    (SELECT CAST(menu_item_id AS VARCHAR(255)) AS menu_item_id, 
            CAST(item_name AS VARCHAR(255)) AS item_name, 
            CAST(category AS VARCHAR(255)) AS category, 
            CAST(price AS VARCHAR(255)) AS price
     FROM menu_detalis) AS p
UNPIVOT
    (value FOR item_property IN 
        (menu_item_id, 
         item_name, 
         category, 
         price)
    ) AS unpvt;


--18. Dynamic SQL:
-- Write a dynamic SQL query that allows users to filter menu items based on category and price range

-- you have to run the inter code
declare @category varchar(50); --filter by category
declare @MaxPrice decimal(10,2); -- fliter by max price
declare @MinPrice decimal(10,2); -- fliter by min price

set @category = 'American';
set @MaxPrice = 1;
set @MinPrice = 13;

select *
from
	menu_detalis
where 
	category = @category
and price between @MaxPrice and @MinPrice


--Stored Procedure:
-- Create a stored procedure that takes a menu category as input and returns the average price for that 
--category.
create procedure category_sorted
@category varchar(50)
as 
begin

	select category,
		   AVG(price) as avg_price
	from
		menu_detalis
	group by
		category
	having
		 category = @category ;
end;

exec category_sorted @category = 'Asian' ;


--20. Triggers:
-- Design a trigger that updates a log table whenever a new order is inserted into the order_details table.
-- trigger is help to put comment in in any action.... we can also create trigger for insert , update , delete.
-- hint: we can put validation value to make sure all the value which is in the table and DB it clear .
create trigger order_detalis_insert
after insert on order_detalis01 
for each row
begin
	insert into order_log(log_message,log_date) 
	value('new order is inserted')	
end;

CREATE TRIGGER order_detalis_insert
ON order_details01
AFTER INSERT 
as
BEGIN
    -- Assuming 'order_log' is a table designed to log messages with columns 'log_message' and 'log_date'
    INSERT INTO order_log (log_message, log_date)
    VALUES ('New order is inserted', CURRENT_TIMESTAMP);
END;


WITH RecursiveMenuCTE AS (
    -- Anchor member: select the root level menu items
    SELECT item_name, menu_item_id, 0 AS Level
    FROM menu_detalis
    

    UNION ALL

     -- Recursive member: select subcategories
    SELECT m.item_name, m.menu_item_id, Level + 1
    FROM menu_detalis m
    INNER JOIN RecursiveMenuCTE r ON m.menu_item_id = r.menu_item_id
)
-- Select from the CTE
SELECT * FROM RecursiveMenuCTE
ORDER BY Level, item_name;

