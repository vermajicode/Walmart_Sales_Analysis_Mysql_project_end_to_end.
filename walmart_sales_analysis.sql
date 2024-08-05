create database if not exists salesdatawalmart;
create table if not exists sales(
invoice_id varchar(30) not null primary key,
branch varchar(5) not null,
city varchar(30) not null,
customer_type varchar(30) not null,
gender varchar(10) not null,
product_line varchar(100) not null,
unit_price decimal(10,2) not null,
quantity int not null,
vat float(6,4) not null,
total decimal(12,4) not null,
date datetime not null,
time time not null,
payment_method varchar(15) not null,
cogs decimal(10,2) not null,
gross_margin_product float(11,9),
gross_income decimal(12,4) not null,
rating float(2,1)
);
-- --------------------------------------------------------------------------
-- ------STEP 1:- DATA CLEANING----------------------------------------------
-- --------------------------------------------------------------------------

-- ------=> SINCE WE HAVE USED ALREADY A PARAMETER NAMED AS NOT NULL SO THERE IS NO NEED OF DATA CLEANING

-- --------------------------------------------------------------------------
-- ------STEP 2:- FEATURE ENGINEERING----------------------------------------
-- --------------------------------------------------------------------------

-- ------=> WE'LL ADD THREE COLUMNS :- (1) TIME OF DAY (2) DAY NAME (3)MONTH NAME ; SO THAT WE CAN ANALYSE EFFICIENTLY BY USING THIS

-- ------(1) TIME OF DAY
select time,
(case
    when `time` between "00:00:00" and "12:00:00" then "morning"
    when `time` between "12:01:00" and "16:00:00" then "morning"
	else "evening"
end) as time_of_date
from sales;
alter table sales add column time_of_day varchar(20);
update sales 
set time_of_day = (case 
when `time` between "00:00:00" and "12:00:00" then "morning"
when `time` between "12:01:00" and "16:00:00" then "afternoon"
else "evening"
end );

-- ------(2) DAY NAME
select date, dayname(date) as day_name from sales;
alter table sales add column day_name varchar(10);
update sales set day_name = dayname(date);

-- ------(3) MONTH NAME
select date, monthname(date) as month_name from sales;
alter table sales add column month_name varchar(10);
update sales set month_name = monthname(date);

-- ------------------------------------------------------------------------------------------------------
-- ----------------------------STEP 3:- EDA => BY PERFORMING THIS WILL GOING TO ANSWER SOME BUSINESS QUESTION---------------
-- ------------------------------------------------------------------------------------------------------

-- ----------------------------(1) GENERIC QUESTION (2) Product (3) Sales (4) Customer

-- ------------------------------------------------------
-- ---------(1) GENERIC QUESTION
-- ------------------------------------------------------

-- ---------(A) How many unique cities does the data have?
select distinct city from sales;

-- ---------(B) In which city is each branch?
select distinct branch from sales;
select distinct city, branch from sales;

-- --------------------------------------------------------
-- ----------(2)  Product RELATED QUESTION
-- --------------------------------------------------------

-- ----------(A) How many unique product lines does the data have?
select distinct product_line from sales;

-- ----------(B) What is the most common payment method?
select payment_method, count(payment_method) from sales group by payment_method order by count(payment_method)  DESC;

-- ----------(C) What is the most selling product line?
select product_line, count(product_line) from sales group by product_line order by count(product_line)  DESC;

-- ----------(D) What is the total revenue by month?
select month_name, sum(total) from sales group by month_name order by sum(total) desc;

-- ----------(E) What month had the largest COGS(COST OF GOODS SOLD)?
select month_name, SUM(cogs) from sales group by month_name order by sum(cogs) desc;

-- ----------(F) What product line had the largest revenue?
select product_line, sum(total) from sales group by product_line order by sum(total) desc;

-- ----------(G) What is the city with branch with the largest revenue?
select city,branch, sum(total) from sales group by city,branch order by sum(total) desc;

-- ----------(H) What product line had the largest VAT(VALUE ADDED TAX)?
select product_line, avg(vat) from sales group by product_line order by avg(vat) desc;

-- ----------(I) Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
select product_line, case 
when count(distinct product_line)> avg(quantity) then "good"
 else "bad" 
end as review from  sales group by product_line;

-- ----------(J)Which branch sold more products than average product sold?
select branch,sum(quantity) from sales group by branch having sum(quantity)>(select avg(quantity) from sales);

-- ----------(K)What is the most common product line by gender?
select gender, product_line, count(product_line) from sales group by gender, product_line order by count(product_line) desc;

-- ----------(L)What is the average rating of each product line?
select product_line, round(avg(rating),2) from sales group by product_line order by round(avg(rating),2) desc;


-- -------------------------------------------------------------------------------------------------------------------
-- ------------------------- (3) SALES RELATED QUESTIONS -------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------------

-- ---------- (A) Number of sales made in each time of the day per weekday
select time_of_day,day_name, sum(quantity) as number_of_sales from sales group by time_of_day,day_name order by number_of_sales desc;

-- ---------- (B) Which of the customer types brings the most revenue?
select customer_type, sum(total) as revenue from sales group by customer_type order by revenue desc;

-- ---------- (C) Which city has the largest tax percent/ VAT (Value Added Tax)?
select city, avg(vat) as vat from sales group by city order by vat desc;

-- ---------- (D) Which customer type pays the most in VAT?
select customer_type, avg(vat) as vat from sales group by customer_type order by vat desc;


-- -------------------------------------------------------------------------------------------------------------------
-- ------------------------- (4) CUSTOMER RELATED QUESTIONS -------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------------


-- ---------- (A) How many unique customer types does the data have?
select distinct customer_type from sales;

-- ---------- (B) How many unique payment methods does the data have?
select distinct payment_method from sales;

-- ---------- (C) What is the most common customer type?
select customer_type,count(customer_type) as count from sales group by customer_type order by count desc;

-- ---------- (D) Which customer type buys the most?
select customer_type, count(quantity) as most_buyer from sales group by customer_type order by most_buyer desc;

-- ---------- (E) What is the gender of most of the customers?
select gender, count(customer_type) as customer from sales group by gender order by customer desc;

-- ---------- (F) What is the gender distribution per branch?
select distinct branch,(select count(gender) from sales where gender="Male") as Male, (select count(gender) from sales where gender="Female") as Female from sales;

-- ---------- (G) Which time of the day do customers give most ratings?
select time_of_day,avg(rating) as rating from sales group by time_of_day order by rating desc;

-- ---------- (H) write a query of rating for each time of the day for each branch?
select distinct time_of_day,branch, avg(rating) as rating from sales group by branch,time_of_day order by rating desc;

-- ---------- (I) Which day of the week has the best avg ratings?
select day_name,avg(rating) as rating from sales group by day_name order by rating desc;

-- ---------- (J) Write a query for each day rating of the week for each branch?
select distinct day_name, branch,avg(rating) as rating from sales group by branch,day_name order by rating desc;