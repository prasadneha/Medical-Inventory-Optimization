
use Healthcare1;

select * from cleaned_data;
desc cleaned_data;

/* stastical inferences */
/* first moment business desicion- mean,median,mode */
/* mean */
select 
round(avg(Quantity),2) as mean_quantity,
round(avg(ReturnQuantity),2) as mean_return_quantity,
round(avg(Final_cost),2) as mean_final_cost,
round(avg(Final_Sales),2) as mean_final_sales,
round(avg(RtnMRP),2) as mean_rtnmrp
from cleaned_data;

/* median */
SELECT
    ROUND(AVG(Final_Cost), 2) AS median_final_cost,
    ROUND(AVG(Final_Sales), 2) AS median_final_sales,
    ROUND(AVG(Quantity), 2) AS median_quantity,
    ROUND(AVG(ReturnQuantity), 2) AS median_return_quantity,
    ROUND(AVG(RtnMRP), 2) AS median_rtnmrp
FROM (
    SELECT
        Final_Cost, Final_Sales, Quantity, ReturnQuantity, RtnMRP,
        ROW_NUMBER() OVER (ORDER BY Final_Cost) AS row_num,
        COUNT(*) OVER () AS total_rows
    FROM cleaned_data
) AS subquery
WHERE row_num IN (FLOOR((total_rows + 1)/2), CEILING((total_rows + 1)/2));

/*mode */
SELECT 
mode_quantity.mode_value AS mode_quantity, 
mode_return_quantity.mode_value AS mode_return_quantity, 
mode_final_cost.mode_value AS mode_final_cost, 
mode_final_sales.mode_value AS mode_final_sales, 
mode_rtnmrp.mode_value AS mode_rtnmrp 
FROM ( 
SELECT Quantity AS mode_value, COUNT(*) AS mode_count 
FROM cleaned_data
GROUP BY Quantity 
ORDER BY COUNT(*) DESC 
LIMIT 1 
) AS mode_quantity, 
( 
SELECT ReturnQuantity AS mode_value, COUNT(*) AS mode_count 
FROM cleaned_data 
GROUP BY ReturnQuantity 
ORDER BY COUNT(*) DESC 
LIMIT 1 
) AS mode_return_quantity, 
( 
SELECT Final_Cost AS mode_value, COUNT(*) AS mode_count 
FROM cleaned_data 
GROUP BY Final_Cost 
ORDER BY COUNT(*) DESC 
LIMIT 1 
) AS mode_final_cost, 
( 
SELECT Final_Sales AS mode_value, COUNT(*) AS mode_count 
FROM cleaned_data
GROUP BY Final_Sales 
ORDER BY COUNT(*) DESC 
LIMIT 1 
) AS mode_final_sales, 
( 
SELECT RtnMRP AS mode_value, COUNT(*) AS mode_count 
FROM cleaned_data
GROUP BY RtnMRP 
ORDER BY COUNT(*) DESC 
LIMIT 1 
) AS mode_rtnmrp;

/*  second moment (measures of dispersion such as variance, standard deviation, 
range) for the dataset */

/* VARIANCE */
select 
round(variance(Quantity),2) as variance_quantity,
ROUND(VARIANCE(ReturnQuantity), 2) AS variance_return_quantity, 
ROUND(VARIANCE(Final_Cost), 2) AS variance_final_cost, 
ROUND(VARIANCE(Final_Sales), 2) AS variance_final_sales, 
ROUND(VARIANCE(RtnMRP), 2) AS variance_rtnmrp
from cleaned_data;

/* Standard Deviation */
select
round(stddev(Quantity),2) as std_quantity,
ROUND(STDDEV(ReturnQuantity), 2) AS stddev_return_quantity, 
ROUND(STDDEV(Final_Cost), 2) AS stddev_final_cost, 
ROUND(STDDEV(Final_Sales), 2) AS stddev_final_sales, 
ROUND(STDDEV(RtnMRP), 2) AS stddev_rtnmrp 
FROM cleaned_data;

/* RANGE */
SELECT 
MAX(Quantity) - MIN(Quantity) AS range_quantity, 
MAX(ReturnQuantity) - MIN(ReturnQuantity) AS range_return_quantity, 
MAX(Final_Cost) - MIN(Final_Cost) AS range_final_cost, 
MAX(Final_Sales) - MIN(Final_Sales) AS range_final_sales, 
MAX(RtnMRP) - MIN(RtnMRP) AS range_rtnmrp 
FROM cleaned_data;

/* Total Revenue */
select cast(sum(Final_cost) as decimal (10,2)) as revenue 
from medical_inventory_dataset;

/* Total quntity sold */
select sum(Quantity) as total_quantity_sold from medical_inventory_dataset;

/* Total quantity returned and returned mrp*/
select sum(ReturnQuantity) as total_quantity_returned from medical_inventory_dataset;

select sum(RtnMRP) as total_returns from medical_inventory_dataset;

/* Total Sales */
select sum(Final_Sales) as total_sales from medical_inventory_dataset;

/* Sales by Specialization -> top selling drugs */

select DrugName , sum(Final_Sales) as total_sales
from medical_inventory_dataset
group by DrugName
order by total_sales desc
limit 10;

/* bounce rate analysis-  */
select Typeofsales,
count(*) as total_records
from cleaned_data
group by Typeofsales;

select round((bounced_customers/total_customers)*100,2) as bounce_rate
from
(select count(distinct Patient_ID) as total_customers
from cleaned_data
where Typeofsales in ('Sale','Return')) as t1,
(select count(distinct Patient_ID) as bounced_customers
from cleaned_data
where Typeofsales='Return') as t2;

/*number of drugs in each subcategory that have been returned without making a sale 
(Final_Sales = 0) */
select SubCat,count(distinct DrugName) as no_of_returned_drugs
from cleaned_data
where Typeofsales='Return' and Final_Sales=0
group by SubCat
order by no_of_returned_drugs desc;

/* Finding the formulation with the highest return count within the "INJECTIONS" and "TABLETS & 
CAPSULES" subcategories */
SELECT SubCat, Formulation, return_count 
FROM ( 
SELECT SubCat, Formulation, COUNT(*) AS return_count, 
ROW_NUMBER() OVER (PARTITION BY SubCat ORDER BY COUNT(*) DESC) AS rn 
FROM cleaned_data 
WHERE Typeofsales = 'Return' AND Final_Sales = 0 AND SubCat IN ('INJECTIONS',
 'TABLETS & CAPSULES') 
GROUP BY SubCat, Formulation 
) AS subquery 
where rn=1;

/*  count of occurrences of Formulation "Form1" for each Department (Dept) where the 
SubCat is either "INJECTIONS" or "TABLETS & CAPSULES" */
SELECT Dept, COUNT(*) AS form1_count 
FROM cleaned_data 
WHERE Formulation = 'Form1' AND SubCat IN ('INJECTIONS', 'TABLETS & CAPSULES') 
GROUP BY Dept 
ORDER BY form1_count DESC;

/* count of occurrences of Typeofsales as 'Return' for each Department (Dept). */
SELECT Dept, COUNT(*) AS return_count 
FROM cleaned_data
WHERE Typeofsales = 'Return' 
GROUP BY Dept;

/*  count of occurrences of Typeofsales as 'Return' for each Specialisation within 
Department1 and Formulation as 'Form1' */
SELECT Specialisation, COUNT(*) AS return_count 
FROM cleaned_data 
WHERE Typeofsales = 'Return' AND Dept = 'Department1' AND Formulation = 'Form1' 
GROUP BY Specialisation 
ORDER BY return_count DESC;

/* Revenue Optimization - Analyze revenue by formulation */
 select Formulation, sum(Final_Sales) as total_sales
 from medical_inventory_dataset
 group by Formulation
 order by total_sales desc;
 
 /* Inventory Management - Determine inventory levels by department */
 select Dept,
 sum(Quantity- ReturnQuantity) as net_inventory
 from medical_inventory_dataset
 group by Dept;
 


