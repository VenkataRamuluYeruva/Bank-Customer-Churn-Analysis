-- database creation
create database BankChurnerAnalysis

-- use database
use BankChurnerAnalysis

-- list all the table present in this database
select table_name from INFORMATION_SCHEMA.TABLES where TABLE_TYPE='Base table'

-- 1. What is the distribution of account balances across different regions?
select 
	g.GeographyLocation as region,
	sum(bc.balance) as total_balance,
	avg(bc.balance) as average_balance,
	max(bc.balance) as maximum_balance,
	min(bc.balance) as minimum_balance
from
	Bank_Churn as bc join CustomerInfo as ci
	on bc.CustomerId=ci.CustomerId
	join Geography as g
	on g.GeographyID=ci.GeographyID
	group by g.GeographyLocation

-- 2. Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. (SQL)
select top 5
	CustomerId,EstimatedSalary
from 
	CustomerInfo where DATEPART(QUARTER,Bank_DOJ)=4 and DATEPART(year,bank_Doj)=2019
	order by EstimatedSalary desc

-- 3. Calculate the average number of products used by customers who have a credit card.
select AVG(NumOfProducts)as average_no_products from Bank_Churn where HasCrCard=1

-- 4. Determine the churn rate by gender for the most recent year in the dataset.
with ChurnCnt as
(
select 
	g.GenderCategory,
	SUM(case
		when bc.Exited=1 Then 1
		else 0
		end) as Churn_Customer,
	count(*) as Total_customers
from 
	Bank_Churn as bc join CustomerInfo as ci
	on bc.CustomerId=ci.CustomerId
	join Gender as g
	on g.GenderID=ci.GenderID
	where DATEPART(Year,ci.bank_doj)=(select max(DATEPART(Year,bank_doj)) from CustomerInfo)
	group by g.GenderCategory
)
select *,ROUND((churn_customer*100/Total_customers),2)as Gende_Churn_rate from ChurnCnt

-- 5. Compare the average credit score of customers who have exited and those who remain. 
select
	ec.ExitCategory,
	avg(bc.creditscore) as avg_creditScore
from 
	Bank_Churn as bc join ExitCustomer as ec
	on bc.Exited=ec.ExitID
	group by ec.ExitCategory
	order by avg_creditScore

-- 6. Which gender has a higher average estimated salary, and how does it relate to the number of active accounts?
select 
	g.GenderCategory,
	AVG(ci.EstimatedSalary) as avg_Estimated_Salary,
	sum(bc.isActiveMember) as No_of_Active_member
from 
	CustomerInfo as ci join Gender as g
	on ci.GenderID=g.GenderID
	join Bank_Churn as bc
	on bc.CustomerId=ci.CustomerId
	group by g.GenderCategory
	order by No_of_Active_member desc

-- 7. Segment the customers based on their credit score and identify the segment with the highest exit rate.
with CustSegment as
(select
	case
		when CreditScore between 800 and 850 Then 'Very Poor'
		when CreditScore between 740 and 799 Then 'Poor'
		when CreditScore between 670 and 739 Then 'Fair'
		when CreditScore between 590 and 669 Then 'Good'
		else 'Excellent'
	end as CreditSegment,
	Exited
from 
	Bank_Churn
)
select top 1 
	CreditSegment,
	Count(*) as Total_Customers,
	sum(Exited) as Exited_Customers,
	round((sum(Exited)*1.0/count(*)),4)  as exit_rate
from 
	CustSegment 
	group by CreditSegment
	order by exit_rate desc

-- 8. Find out which geographic region has the highest number of active customers with a tenure greater than 5 years.
select top 1
	g.GeographyLocation,
	sum(bc.IsActiveMember) as Active_member
from
	CustomerInfo as ci join Geography as g
	on ci.GeographyID=g.GeographyID
	join Bank_Churn as bc
	on bc.CustomerId=ci.CustomerId
	where bc.Tenure>5
	group by g.GeographyLocation
	order by Active_member desc

-- 9. What is the impact of having a credit card on customer churn, based on the available data?
select 
	HasCrCard,SUM(Exited)*100/count(*) as Churn_Credit
from
	Bank_Churn group by HasCrCard

-- 10. For customers who have exited, what is the most common number of products they have used?
select top 1
	NumofProducts as Common_Num_of_products,
	count(*) as products_cnt
from
	Bank_Churn
	where exited=1
	group by NumOfProducts
	order by products_cnt desc;

-- 11. Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly). 
-- Prepare the data through SQL and then visualize it.
select
	DATEName(year,Bank_DOJ) as join_year,
	DATEName(month,Bank_DOJ) as join_month,
	count(*) as cnt_customers
from
	CustomerInfo
	group by DATENAME(year,bank_doj),DATENAME(month,bank_doj)
	order by join_year,cnt_customers

-- 12. Analyze the relationship between the number of products and the account balance for customers who have exited.
SELECT
	NumofProducts,
	round(AVG(balance),2) as avg_balance
from
	Bank_Churn
	where Exited=1
	group by NumOfProducts
	order by NumOfProducts

-- 13. Identify any potential outliers in terms of balance among customers who have remained with the bank.
select 
	CustomerId,Balance
from
	Bank_Churn
	where Exited=1 and IsActiveMember=1
	order by Balance desc;

-- 15. Using SQL, write a query to find out the gender-wise average income of males and females in each geography id. Also, rank the gender according to the average value. (SQL)
SELECT 
	g.GenderCategory,
	geo.GeographyLocation,
	round(AVG(ci.EstimatedSalary),2) as avg_income,
	RANK() over(partition by g.genderCategory order by avg(ci.EstimatedSalary) desc)as rank_no
from
	CustomerInfo as ci join Gender as g
	on ci.GenderID=g.GenderID
	join Geography as geo
	on ci.GeographyID=geo.GeographyID
	group by g.GenderCategory,geo.GeographyLocation
	order by g.GenderCategory,rank_no

-- 16. Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).
with TenureCnt as
(select
	case
		when ci.Age between 18 and 30 Then '18-30'
		when ci.Age between 31 and 50 Then '31-50'
		else '50+'
	end as AgeBracket,
	bc.Tenure as tenure
from
	CustomerInfo as ci join Bank_Churn as bc
	on bc.CustomerId=ci.CustomerId
	where bc.Exited=1
)
select AgeBracket,avg(Tenure)as avg_tenure from TenureCnt
group by AgeBracket
order by AgeBracket
	
		----------Correlation Problems--------------

-- 17. Is there any direct correlation between salary and the balance of the customers? And is it different for people who have exited or not?
-- Correlation between salary and balance for all customers
SELECT 
    (COUNT(*) * SUM(bc.Balance * ci.EstimatedSalary) - SUM(bc.Balance) * SUM(ci.EstimatedSalary)) /
    (SQRT((COUNT(*) * SUM(bc.Balance * bc.Balance) - SUM(bc.Balance) * SUM(bc.Balance)) *
          (COUNT(*) * SUM(ci.EstimatedSalary * ci.EstimatedSalary) - SUM(ci.EstimatedSalary) * SUM(ci.EstimatedSalary))))
    AS correlation_all
FROM bank_churn bc
JOIN customerinfo ci ON bc.CustomerId = ci.CustomerId;

-- Correlation between salary and balance for customers who have not exited
select
	(count(*)*sum(bc.Balance*ci.EstimatedSalary) - sum(bc.balance)*sum(ci.EstimatedSalary))/
	(SQRT((count(*)*sum(bc.balance*bc.balance)-sum(bc.balance)*sum(bc.balance))*
		(count(*)*sum(ci.EstimatedSalary*ci.EstimatedSalary)-sum(ci.EstimatedSalary)*sum(ci.EstimatedSalary))))
	as correlation_val
from
	CustomerInfo as ci join Bank_Churn as bc
	on ci.CustomerId=bc.CustomerId
	where bc.Exited=0

-- Correlation between salary and balance for customers who have exited
select
	(count(*)*sum(bc.balance*ci.estimatedsalary) - sum(bc.balance)*sum(ci.estimatedsalary))/
	(SQRT((count(*)*sum(bc.balance*bc.balance) - sum(bc.balance)*sum(bc.balance))*
		(count(*)*sum(ci.estimatedsalary*ci.estimatedsalary)-sum(ci.estimatedsalary)*sum(ci.estimatedsalary))))
	as correlation_Exited
from
	CustomerInfo as ci join Bank_Churn as bc
	on ci.CustomerId=bc.CustomerId
	where bc.Exited=1;

-- 18. Is there any correlation between the salary and the Credit score of customers?
select
	(count(*)*sum(ci.estimatedsalary*bc.creditscore)-sum(ci.estimatedsalary)*sum(bc.creditscore))/
	(SQRT((count(*)*sum(ci.estimatedsalary*ci.estimatedsalary)-sum(ci.estimatedsalary)*sum(ci.estimatedsalary))*
		(count(*)*sum(bc.creditscore*bc.creditscore) - sum(bc.creditscore)*sum(bc.creditscore))))
	as Correlation
from
	CustomerInfo as ci join Bank_Churn as bc
	on ci.CustomerId=bc.CustomerId

-- 19. Rank each bucket of credit score as per the number of customers who have churned the bank.
with creditbuc as
(select
	case
		when creditscore between 800 and 850 then '800-850'
		when creditscore between 700 and 799 then '700-799'
		when creditscore between 600 and 699 then '600-699'
		when creditscore between 490 and 599 then '490-599'
		else '350-489'
	end as creditbucket
from
	bank_churn)

select rank() over(order by count(*) desc) as rank_no,* from creditbuc group by creditbucket order by rank_no;


-- 20. According to the age buckets find the number of customers who have a credit card. 
-- Also retrieve those buckets that have lesser than average number of credit cards per bucket.
SELECT 
        CASE
            WHEN Age BETWEEN 18 AND 30 THEN '18-30'
            WHEN Age BETWEEN 31 AND 50 THEN '31-50'
            ELSE '50+'
        END AS AgeBucket,
        COUNT(*) AS num_of_customers,
        SUM(CASE WHEN HasCrCard = 1 THEN 1 ELSE 0 END) AS customers_with_crcd
FROM 
	customerinfo ci JOIN bank_churn bc ON ci.CustomerId = bc.CustomerId
    GROUP BY 
        CASE
            WHEN Age BETWEEN 18 AND 30 THEN '18-30'
            WHEN Age BETWEEN 31 AND 50 THEN '31-50'
            ELSE '50+'
        END;

WITH AgeBuckets AS (
    SELECT 
        CASE
            WHEN Age BETWEEN 18 AND 30 THEN '18-30'
            WHEN Age BETWEEN 31 AND 50 THEN '31-50'
            ELSE '50+'
        END AS AgeBucket,
        COUNT(*) AS num_of_customers,
        SUM(CASE WHEN HasCrCard = 1 THEN 1 ELSE 0 END) AS customers_with_crcd
    FROM customerinfo ci
    JOIN bank_churn bc ON ci.CustomerId = bc.CustomerId
    GROUP BY 
        CASE
            WHEN Age BETWEEN 18 AND 30 THEN '18-30'
            WHEN Age BETWEEN 31 AND 50 THEN '31-50'
            ELSE '50+'
        END
),
AvgCreditCards AS (
    SELECT AVG(customers_with_crcd) AS avg_crcds
    FROM AgeBuckets
)
SELECT
    ab.AgeBucket,
    ab.num_of_customers,
    ab.customers_with_crcd
FROM AgeBuckets ab
CROSS JOIN AvgCreditCards avg
WHERE ab.customers_with_crcd < avg.avg_crcds
ORDER BY ab.customers_with_crcd DESC;

-- 21. Rank the Locations as per the number of people who have churned the bank and average balance of the customers.
select
	rank() over(order by sum(bc.exited) desc,avg(bc.balance) desc) as location_rank,
	g.GeographyLocation,
	sum(bc.exited) as churned_custmers,
	avg(bc.balance) as avg_balance
from
	CustomerInfo ci join Bank_Churn bc
	on ci.CustomerId=bc.CustomerId
	join Geography g
	on g.GeographyID=ci.GeographyID
	group by g.GeographyLocation

-- 22. As we can see that the “CustomerInfo” table has the CustomerID and Surname, now if we have to join it with a table 
-- where the primary key is also a combination of CustomerID and Surname, come up with a column where the format is “CustomerID_Surname”.

sp_help customerinfo;
alter table customerinfo add CustomerId_Surname varchar(50);

update CustomerInfo set CustomerId_Surname=CONCAT(customerid,'_',surname);

select customerid_surname from CustomerInfo;

-- 23. Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL.
select 
	CustomerId,
	Exited,
	(select ExitCategory from ExitCustomer where ExitID=bc.Exited) as ExitCategory
from
	 Bank_Churn bc

-- 25. Write the query to get the customer IDs, their last name, and whether they are active or not for the customers whose surname ends with “on”.
select
	ci.CustomerId,
	ci.Surname,
	(case 
		when bc.IsActiveMember=1 then 'Yes'
		else 'No'
	end) as Memeber_Status
from
	CustomerInfo ci join Bank_Churn bc
	on ci.CustomerId=bc.CustomerId
	where ci.Surname like '%on';

