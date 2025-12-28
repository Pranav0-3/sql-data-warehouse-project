/* Quality check and comparison for bronze and silver 
by checking duplicate, unwanted spaces, doing standaridzation, checking for null, validatating date format etc */


-- Check for nulls or duplicates in Primary key
-- Expectation: No Result

select 
	prd_id,
	count(*)
from silver.crm_prd_info
group by prd_id 
having count(*) > 1 OR prd_id is null;


------- check unwanted spaces
------- Expectation: No Results
select
GEN
from bronze.erp_CUST_AZ12
where GEN != TRIM(GEN)


------ Data Standardization & Consistency 
select distinct gen
from silver.erp_CUST_AZ12

------ Check for nulls or negative numbers
select
prd_cost
from silver.crm_prd_info
where prd_cost < 0 or prd_cost is null



--- Start date should not be greater then end date
select 
*
from bronze.crm_sales_details
where sls_due_dt > sls_ship_dt;


---- check for invalid date
select
BDATE
from silver.erp_CUST_AZ12
where BDATE  > getdate()
or len(BDATE) != 8
or BDATE  > 20500101 -- boundary date 
or BDATE  < 19000101 -- order should not be older then when the company started


---- checking quality of sales, qty and price
select distinct
	sls_sales,
	sls_quantity ,
	sls_price
from silver.crm_sales_details
where sls_sales != sls_quantity * sls_price
or sls_sales is null or sls_quantity is null or sls_price is null
or sls_sales <=0 or sls_quantity <=0 or sls_price <=0
order by sls_sales, sls_quantity, sls_price


---- country standardization 
select 
distinct cntry as old_cntry, --- standardization
case
	when trim(cntry) = 'DE' then 'Germany'
	when trim(cntry) IN ('US', 'USA') then 'United States'
	when trim(cntry) = '' or cntry is null then 'N/A'
	else cntry
end cntry
from bronze.erp_LOC_A101
