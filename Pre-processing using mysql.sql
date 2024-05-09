
/* Creating the database. */
create database healthcare1;

/* Using the database */
use healthcare1;

/* Displaying the table */
select * from medical_Dataset;

/*  Checking the schema of the datase */
desc medical_Dataset;

/* Fixing the inconsistent data formats in the dateofbill column */
create table clean_medical_data as
select Typeofsales,Patient_ID, Specialisation,Dept,
str_to_date(Replace(Dateofbill,'/','-'),'%m-%d-%Y') as Dateofbill, Quantity, ReturnQuantity, 
Final_Cost,Final_Sales,RtnMRP,Formulation,DrugName,SubCat, SubCat1
from medical_dataset;

select * from clean_medical_data;

 /*  Counting the missing and non-missing values for each column and the total number of rows in 
the 'clean_medical_data' table.  */
SELECT 
COUNT(CASE WHEN TRIM(Typeofsales) = '' OR Typeofsales IS NULL THEN 1 END) AS 
typeofsales_missing, 
COUNT(CASE WHEN TRIM(Typeofsales) <> '' AND Typeofsales IS NOT NULL THEN 1 END) AS 
typeofsales_non_missing, 
COUNT(CASE WHEN Patient_ID IS NULL THEN 1 END) AS patient_id_missing, 
COUNT(CASE WHEN Patient_ID IS NOT NULL THEN 1 END) AS patient_id_non_missing, 
COUNT(CASE WHEN TRIM(Specialisation) = '' OR Specialisation IS NULL THEN 1 END) AS 
specialisation_missing, 
COUNT(CASE WHEN TRIM(Specialisation) <> '' AND Specialisation IS NOT NULL THEN 1 END) AS 
specialisation_non_missing, 
COUNT(CASE WHEN TRIM(Dept) = '' OR Dept IS NULL THEN 1 END) AS dept_missing, 
COUNT(CASE WHEN TRIM(Dept) <> '' AND Dept IS NOT NULL THEN 1 END) AS dept_non_missing, 
COUNT(CASE WHEN TRIM(Dateofbill) = '' OR Dateofbill IS NULL THEN 1 END) AS dateofbill_missing, 
COUNT(CASE WHEN TRIM(Dateofbill) <> '' AND Dateofbill IS NOT NULL THEN 1 END) AS 
dateofbill_non_missing, 
COUNT(CASE WHEN Quantity IS NULL THEN 1 END) AS quantity_missing, 
COUNT(CASE WHEN Quantity IS NOT NULL THEN 1 END) AS quantity_non_missing, 
COUNT(CASE WHEN ReturnQuantity IS NULL THEN 1 END) AS returnquantity_missing, 
COUNT(CASE WHEN ReturnQuantity IS NOT NULL THEN 1 END) AS returnquantity_non_missing, 
COUNT(CASE WHEN Final_Cost IS NULL THEN 1 END) AS final_cost_missing, 
COUNT(CASE WHEN Final_Cost IS NOT NULL THEN 1 END) AS final_cost_non_missing, 
COUNT(CASE WHEN Final_Sales IS NULL THEN 1 END) AS final_sales_missing, 
COUNT(CASE WHEN Final_Sales IS NOT NULL THEN 1 END) AS final_sales_non_missing, 
COUNT(CASE WHEN RtnMRP IS NULL THEN 1 END) AS rtnmrp_missing, 
COUNT(CASE WHEN RtnMRP IS NOT NULL THEN 1 END) AS rtnmrp_non_missing, 
COUNT(CASE WHEN TRIM(Formulation) = '' OR Formulation IS NULL THEN 1 END) AS 
formulation_missing, 
COUNT(CASE WHEN TRIM(Formulation) <> '' AND Formulation IS NOT NULL THEN 1 END) AS 
formulation_non_missing, 
COUNT(CASE WHEN TRIM(DrugName) = '' OR DrugName IS NULL THEN 1 END) AS 
drugname_missing, 
COUNT(CASE WHEN TRIM(DrugName) <> '' AND DrugName IS NOT NULL THEN 1 END) AS 
drugname_non_missing, 
COUNT(CASE WHEN TRIM(SubCat) = '' OR SubCat IS NULL THEN 1 END) AS subcat_missing, 
COUNT(CASE WHEN TRIM(SubCat) <> '' AND SubCat IS NOT NULL THEN 1 END) AS 
subcat_non_missing, 
COUNT(CASE WHEN TRIM(SubCat1) = '' OR SubCat1 IS NULL THEN 1 END) AS subcat1_missing, 
COUNT(CASE WHEN TRIM(SubCat1) <> '' AND SubCat1 IS NOT NULL THEN 1 END) AS 
subcat1_non_missing, 
COUNT(*) AS total_rows 
FROM clean_medical_data;

/* Replacing the missing values with ‘Unknown’ in the columns Formulation, DrugName, SubCat 
and SubCat1. */
update clean_medical_data 
set 
Formulation='Unknown'
where Formulation='';

update clean_medical_data 
set 
DrugName='Unknown'
where DrugName='';

update clean_medical_data 
set 
SubCat='Unknown'
where SubCat='';

update clean_medical_data 
set 
SubCat1='Unknown'
where SubCat1='';

/* Creating a new table called `missing_values` by selecting rows from `clean_medical_data` 
where any of the columns (`Formulation`, `DrugName`, `SubCat`, or `SubCat1`) has the value 
'Unknown'. */
CREATE TABLE missing_values AS 
SELECT * 
FROM clean_medical_data
WHERE Formulation = 'Unknown' 
OR DrugName = 'Unknown' 
OR SubCat = 'Unknown' 
OR SubCat1 = 'Unknown';

/*Showing missing_values table and count of records with at least one or more missing values */
select * from missing_values;
select count(*) as missing_records from missing_values;

/* . Identifying duplicate rows based on Patient_ID, Dateofbill, and DrugName excluding rows 
where the DrugName is 'Unknown'. */
select Patient_ID, Dateofbill, DrugName, count(*)
from clean_medical_data
where DrugName <> 'Unknown'
group by Patient_ID, Dateofbill, DrugName
having count(*)>1;


 /* Removing the duplicate rows from clean_medical_data table and counting the remaining 
rows.*/
DELETE FROM clean_medical_data
WHERE (Patient_ID, Dateofbill, DrugName) IN ( 
SELECT t.Patient_ID, t.Dateofbill, t.DrugName 
FROM ( 
SELECT Patient_ID, Dateofbill, DrugName 
FROM clean_medical_data
GROUP BY Patient_ID, Dateofbill, DrugName 
HAVING COUNT(*) > 1 
) AS t 
); 

select count(*) as total_rows from clean_medical_data;