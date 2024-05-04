
/*The major aim of this project is to gain insight into the sales data of Amazon 
to understand the different factors that affect sales of the different branches.
*/


-- 1 Data Wrangling

-- 1.1 Buliding the database
-- create database amazon_sales;

-- 1.2 Importing excel via Table import wizard option and once imported checking the data table
select * from amazon;


-- 1.3 to check the null values in the dataset
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'amazon' AND TABLE_SCHEMA = 'amazon_sales' AND IS_NULLABLE = 'no';

-- 2 Feature Engineering : This will help us generate some new columns from existing ones..

-- 2.1 Add a new column named timeofday to give insight of sales in the Morning,
-- Afternoon and Evening. This will help answer the question on which part of the day most sales are made.

-- Step1-Adding a new column -Time of day
alter table amazon
add column timeofday varchar(255);

-- Step 2: Update the 'timeofday' column based on the time component of the 'Time' column
SET SQL_SAFE_UPDATES = 0;


UPDATE amazon
SET timeofday = CASE
    WHEN TIME(Time) >= '00:00:00' AND TIME(Time) < '12:00:00' THEN 'Morning'
    WHEN TIME(Time) >= '12:00:00' AND TIME(Time) < '17:00:00' THEN 'Afternoon'
    ELSE 'Evening'
END;

-- 2.2  Add a new column named dayname that contains the extracted days of the 
-- week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri). This will help answer 
-- the question on which week of the day each branch is busiest.
alter table amazon 
add column dayname varchar(255);

update amazon
set dayname= DAYNAME(STR_TO_DATE(Date, '%d-%m-%Y'));

-- 2.3 Add a new column named monthname that contains the extracted months of the year on 
-- which the given transaction took place (Jan, Feb, Mar). 
-- Help determine which month of the year has the most sales and profit.
alter table amazon
add column monthname varchar(255);

update  amazon
set monthname = monthname(STR_TO_DATE(Date, '%d-%m-%Y'));


select * from amazon;


-- 3)Exploratory Data Analysis (EDA): Exploratory data analysis is done to answer the listed questions and aims of this project.



-- Business Questions To Answer:
-- 1) What is the count of distinct cities in the dataset?

select count(distinct city) as count_of_city from amazon;

-- 2)For each branch, what is the corresponding city?
select branch, city from amazon 
group by branch, city
order by branch;

-- 3)What is the count of distinct product lines in the dataset?
SELECT COUNT(DISTINCT `Product line`) AS distinct_product_lines_count
FROM amazon;


-- 4)Which payment method occurs most frequently?
select payment , count(*) as frequency from amazon
group by Payment
order by frequency desc
limit 1;


-- 5)Which product line has the highest sales?
select `Product Line` , round(sum(total),2) as highest_sales from amazon
group by `Product Line`
order by highest_sales desc
limit 1;


-- 6)How much revenue is generated each month?
Select monthname as Month,sum(total) as Total_Revenue from amazon
group by monthname
order by Total_Revenue Desc ;

-- 7)In which month did the cost of goods sold reach its peak?
select monthname , sum(cogs) as Total_cogs from amazon 
group by monthname
order by Total_cogs desc;
-- limit 1;

-- 8)Which product line generated the highest revenue?
select `Product Line` , sum(total) as total_sales from amazon 
group by `Product Line` 
order by total_sales desc
limit 1;

-- 9)In which city was the highest revenue recorded?
select city ,  sum(total) as total_sales from amazon 
group by city
order by total_sales desc
limit 1;

-- 10)Which product line incurred the highest Value Added Tax?
select `Product Line` , sum(`Tax 5%`) as Total_Tax_5 from amazon
group by `Product Line`
order by Total_Tax_5 desc
limit 1;

-- 11)For each product line, add a column indicating "Good" if its
-- sales are above average, otherwise "Bad."
SELECT `Product line`,CASE
WHEN SUM(Total) > (SELECT AVG(Total) FROM (SELECT SUM(Total) as Total FROM amazon GROUP BY `Product line`) AS avg_sales) THEN 'Good'
ELSE 'Bad'
END AS Sales_Category
FROM amazon
GROUP BY `Product line`;
    
-- 12)Identify the branch that exceeded the average number of products sold.
select branch ,sum(quantity) as qty from amazon
group by branch
having sum(quantity) > (select  avg(quantity) from amazon);


-- 13)Which product line is most frequently associated with each gender?
select gender,`Product Line` , count(*) as frequency_of_product from amazon
group by gender,`Product Line` 
order by gender ,frequency_of_product desc;

-- 14)Calculate the average rating for each product line.
select `Product Line`,round(avg(rating),4) as Avg_rating from amazon
group by `Product Line`
order by Avg_rating desc;

-- 15)Count the sales occurrences for each time of day on every weekday.
select timeofday,count(*) as total_sales from amazon
where  dayname IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday')
group by timeofday
order by total_sales desc;


-- 16)Identify the customer type contributing the highest revenue.
select `customer type` , round(sum(total),2) as highest_sales from amazon
group by `customer type`
order by highest_sales desc;


-- 17)Determine the city with the highest VAT percentage.
select city , round(avg(`Tax 5%`),2) as vat from amazon
group by city 
order by vat desc;

-- 18)Identify the customer type with the highest VAT payments.
select `Customer type`, round(avg(`Tax 5%`),2) as vat from amazon
group by `Customer type`
order by vat desc;

-- 19)What is the count of distinct customer types in the dataset?
select distinct `Customer type` as Distinct_cust_type from amazon;

-- 20)What is the count of distinct payment methods in the dataset?
select distinct Payment, count(*) as frequency from amazon
group by Payment
order by frequency desc;

-- 21)Which customer type occurs most frequently?
select `Customer type`, count(*) as frequency from amazon 
group by `Customer type`
order by frequency desc;

-- 22)Identify the customer type with the highest purchase frequency.
select `Customer type`, count(*) as Purchasefrequency from amazon 
group by `Customer type`
order by Purchasefrequency desc;

-- 23)Determine the predominant gender among customers.
select gender, count(*) gender_count from amazon
group by gender
order by gender_count
desc;

-- 24)Examine the distribution of genders within each branch.
select branch, gender , count(*) as count from amazon
group by branch, gender
order by count desc;

-- 25)Identify the time of day when customers provide the most ratings.
select timeofday,round(avg(rating),2) as Avg_rating from amazon 
group by timeofday
order by Avg_rating desc;

-- 26)Determine the time of day with the highest customer ratings for each branch.
select timeofday,branch, round(avg(rating),2) as avg_rating from amazon
group by timeofday,branch
order by avg_rating desc;

-- 27)Identify the day of the week with the highest average ratings.
select timeofday , round(avg(rating),2) as avg_rating from amazon 
group by timeofday
order by avg_rating desc
limit 1;

-- 28)Determine the day of the week with the highest average ratings for each branch.
select timeofday , branch, round(avg(rating),2) as avg_rating from amazon 
group by timeofday , branch
order by avg_rating desc
limit 1;

-- Thank You --
-- Project By - Ricky Warich-S6993

