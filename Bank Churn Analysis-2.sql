----------------- Subjective questions

-- 1. Customer Behavior Analysis: What patterns can be observed in the spending habits of long-term customers compared to new customers, and what might these patterns suggest about customer loyalty?

-- Churn Rate by Tenure Category
select 
	case
		when Tenure between 3 and 5 Then 'New Customer'
		else 'Old Customer'
	end as tenure_category,
	sum(exited)*100/count(*) AS churn_rate
from 
	Bank_Churn
	group by case
		when Tenure between 3 and 5 then 'New Customer'
		else 'Old Customer'
	end ;

-- Exit Count by Tenure Category
select
	case
		 when Tenure <=5 then 'New Customer'
		 else 'Old Customer'
	end as TenureCategory,
	exited,
	count(*) as tenure_cnt
from
	Bank_Churn
	group by case
		 when Tenure <=5 then 'New Customer'
		 else 'Old Customer'
	end,exited;

-- Active Membership by Tenure Category
SELECT
	CASE
		WHEN Tenure <= 5 THEN 'New Customer'
		ELSE 'Long Term Customer'
	END AS TenureCategory,
	IsActiveMember,
    COUNT(*) AS num_of_customers
FROM bank_churn
GROUP BY
	CASE
		WHEN Tenure <= 5 THEN 'New Customer'
		ELSE 'Long Term Customer'
	END,
    IsActiveMember
ORDER BY
	TenureCategory,
    IsActiveMember;

-- Credit Card Usage by Tenure Category
SELECT
	CASE
		WHEN Tenure <= 5 THEN 'New Customer'
		ELSE 'Long Term Customer'
	END AS TenureCategory,
    HasCrCard,
    COUNT(*) AS num_of_customers
FROM bank_churn
GROUP BY
	CASE
		WHEN Tenure <= 5 THEN 'New Customer'
		ELSE 'Long Term Customer'
	END,
    HasCrCard
ORDER BY
	TenureCategory,
	HasCrCard;

-- Product Ownership by Tenure Category
SELECT
	CASE
		WHEN Tenure <= 5 THEN 'New Customer'
		ELSE 'Long Term Customer'
	END AS TenureCategory,
    NumOfProducts,
    COUNT(*) AS num_of_customers
FROM bank_churn 
GROUP BY
	CASE
		WHEN Tenure <= 5 THEN 'New Customer'
		ELSE 'Long Term Customer'
	END,
    NumOfProducts
ORDER BY TenureCategory DESC;

-- Average Balance by Tenure Category
SELECT
	CASE
		WHEN Tenure <= 5 THEN 'New Customer'
		ELSE 'Long Term Customer'
	END AS TenureCategory,
    ROUND(AVG(Balance), 2) AS avg_balance
FROM bank_churn
GROUP BY CASE
		WHEN Tenure <= 5 THEN 'New Customer'
		ELSE 'Long Term Customer'
	END
ORDER BY avg_balance DESC;

-- 2. Product Affinity Study: Which bank products or services are most commonly used together, and how might this influence cross-selling strategies?
SELECT
    NumOfProducts,
    COUNT(*) AS num_customers
FROM bank_churn
WHERE
	IsActiveMember = 1 AND HasCrCard = 1
GROUP BY
    NumOfProducts;

-- 3. Geographic Market Trends: 
-- How do economic indicators in different geographic regions correlate with the number of active accounts and customer churn rates?

-- Average Balance by GeographyLocation and Exit Category for Active Customers
SELECT
	g.GeographyLocation,
    bc.Exited,
    AVG(bc.Balance) AS avg_balance
FROM bank_churn bc
JOIN customerinfo ci ON bc.CustomerId = ci.CustomerId
JOIN geography g ON ci.GeographyID = g.GeographyID
WHERE bc.IsActiveMember = 1
GROUP BY
	g.GeographyLocation,
    bc.Exited
ORDER BY 
	bc.Exited,
    g.GeographyLocation;

-- Active EXited Customers by GeographyLocation and Credir Score Category
SELECT
	g.GeographyLocation,
    CASE 
		WHEN bc.CreditScore BETWEEN 800 AND 850 THEN '800 - 850'
        WHEN bc.CreditScore BETWEEN 740 AND 799 THEN '740 - 799'
        WHEN bc.CreditScore BETWEEN 670 AND 739 THEN '670 - 739'
        WHEN bc.CreditScore BETWEEN 580 AND 669 THEN '580 - 699'
        WHEN bc.CreditScore BETWEEN 300 AND 579 THEN '300 - 579'
	END AS CreditScoreCategory,
    SUM(Exited) AS churned_customers
FROM bank_churn bc
JOIN customerinfo ci ON bc.CustomerId = ci.CustomerId
JOIN geography g ON ci.GeographyID = g.GeographyID
WHERE bc.IsActiveMember = 1
GROUP BY
	g.GeographyLocation,
    CASE 
		WHEN bc.CreditScore BETWEEN 800 AND 850 THEN '800 - 850'
        WHEN bc.CreditScore BETWEEN 740 AND 799 THEN '740 - 799'
        WHEN bc.CreditScore BETWEEN 670 AND 739 THEN '670 - 739'
        WHEN bc.CreditScore BETWEEN 580 AND 669 THEN '580 - 699'
        WHEN bc.CreditScore BETWEEN 300 AND 579 THEN '300 - 579'
	END
ORDER BY
	g.GeographyLocation DESC,
    CreditScoreCategory;

-- Active EXited Customers having Credit Cards by GeographyLocation 
SELECT
	g.GeographyLocation,
    SUM(HasCrCard) AS credit_card_users,
    SUM(Exited) AS churned_customers
FROM bank_churn bc
JOIN customerinfo ci ON bc.CustomerId = ci.CustomerId
JOIN geography g ON ci.GeographyID = g.GeographyID
WHERE bc.IsActiveMember = 1
GROUP BY g.GeographyLocation
ORDER BY
	g.GeographyLocation DESC;

-- Active EXited Customers by GeographyLocation and Number of Customers
SELECT
	g.GeographyLocation,
    COUNT(*) AS number_of_customers,
    SUM(Exited) AS churned_customers
FROM bank_churn bc
JOIN customerinfo ci ON bc.CustomerId = ci.CustomerId
JOIN geography g ON ci.GeographyID = g.GeographyID
WHERE bc.IsActiveMember = 1
GROUP BY 
	g.GeographyLocation
ORDER BY
	g.GeographyLocation DESC;

-- Average Estimated Salary by GeographyLocation and Exit Category for Active Customers
SELECT
	g.GeographyLocation,
    bc.Exited,
    AVG(ci.EstimatedSalary) AS avg_estimated_salary
FROM bank_churn bc
JOIN customerinfo ci ON bc.CustomerId = ci.CustomerId
JOIN geography g ON ci.GeographyID = g.GeographyID
WHERE bc.IsActiveMember = 1
GROUP BY
	g.GeographyLocation,
    bc.Exited
ORDER BY 
	bc.Exited,
    g.GeographyLocation;

-- 4. Risk Management Assessment: Based on customer profiles, which demographic segments appear to pose the highest financial risk to the bank, and why?

-- Customers by Credit Score Category and Age Segment
SELECT
    CASE 
		WHEN bc.CreditScore BETWEEN 800 AND 850 THEN '800 - 850'
        WHEN bc.CreditScore BETWEEN 740 AND 799 THEN '740 - 799'
        WHEN bc.CreditScore BETWEEN 670 AND 739 THEN '670 - 739'
        WHEN bc.CreditScore BETWEEN 580 AND 669 THEN '580 - 699'
        WHEN bc.CreditScore BETWEEN 300 AND 579 THEN '300 - 579'
	END AS CreditScoreCategory,
    CASE
			WHEN Age BETWEEN 18 AND 30 THEN '18-30'
			WHEN Age BETWEEN 31 AND 50 THEN '31-50'
			ELSE '50+'
		END AS AgeSegment,
    COUNT(*) AS number_of_customers
FROM bank_churn bc
JOIN customerinfo ci ON bc.CustomerId = ci.CustomerId
GROUP BY
	
    CASE 
		WHEN bc.CreditScore BETWEEN 800 AND 850 THEN '800 - 850'
        WHEN bc.CreditScore BETWEEN 740 AND 799 THEN '740 - 799'
        WHEN bc.CreditScore BETWEEN 670 AND 739 THEN '670 - 739'
        WHEN bc.CreditScore BETWEEN 580 AND 669 THEN '580 - 699'
        WHEN bc.CreditScore BETWEEN 300 AND 579 THEN '300 - 579'
	END,
	CASE
			WHEN Age BETWEEN 18 AND 30 THEN '18-30'
			WHEN Age BETWEEN 31 AND 50 THEN '31-50'
			ELSE '50+'
		END
ORDER BY 
    CreditScoreCategory,
	AgeSegment;

-- Customers by Tenure Category and Age Segment
SELECT
    CASE
		WHEN Tenure <= 5 THEN 'New Customer'
		ELSE 'Long Term Customer'
	END AS TenureCategory,
    CASE
			WHEN Age BETWEEN 18 AND 30 THEN '18-30'
			WHEN Age BETWEEN 31 AND 50 THEN '31-50'
			ELSE '50+'
		END AS AgeSegment,
    COUNT(*) AS number_of_customers
FROM bank_churn bc
JOIN customerinfo ci ON bc.CustomerId = ci.CustomerId
GROUP BY
	CASE
			WHEN Age BETWEEN 18 AND 30 THEN '18-30'
			WHEN Age BETWEEN 31 AND 50 THEN '31-50'
			ELSE '50+'
		END ,
    CASE
		WHEN Tenure <= 5 THEN 'New Customer'
		ELSE 'Long Term Customer'
	END
ORDER BY 
	AgeSegment,
    TenureCategory;

-- Average of Balance and Customers with Balance less than Average Balance
SELECT
	(SELECT 
		ROUND(AVG(Balance), 2) AS average_balance 
	FROM 
		bank_churn) AS average_balance,
	COUNT(*) AS customers_with_balance_less_than_average_balance
FROM 
	bank_churn
	WHERE Balance < (SELECT ROUND(AVG(Balance), 2) AS average_balance FROM bank_churn);

-- Average of Estimated Salary and Customers with Estimated Salary less than Average Estimated Salary
SELECT
	(SELECT 
		ROUND(AVG(EstimatedSalary), 2) AS average_estimated_salary 
	FROM 
		customerinfo) AS average_estimated_salary,
	COUNT(*) AS customers_with_estimated_salary_less_than_average_estimated_salary
FROM 
	customerinfo
	WHERE EstimatedSalary < (SELECT ROUND(AVG(EstimatedSalary), 2) AS average_estimated_salary FROM customerinfo);

-- 9. Utilize SQL queries to segment customers based on demographics and account details.

-- Segmentation by Gender and Geography:
SELECT 
    c.CustomerId,
    c.Age,
    CASE 
        WHEN c.GenderID = 1 THEN 'Male'
        WHEN c.GenderID = 2 THEN 'Female'
        ELSE 'Other'
    END AS Gender,
    CASE 
        WHEN c.GeographyID = 1 THEN 'France'
        WHEN c.GeographyID = 2 THEN 'Spain'
        WHEN c.GeographyID = 3 THEN 'Germany'
        ELSE 'Unknown'
    END AS Geography,
    c.EstimatedSalary,
    c.Bank_DOJ,
    bc.CreditScore,
    bc.Tenure,
    bc.Balance,
    bc.NumOfProducts,
    bc.HasCrCard,
    bc.IsActiveMember,
    bc.Exited
FROM customerinfo c
JOIN bank_churn bc ON c.CustomerId = bc.CustomerId
order by gender,Geography;

-- Segmentation by Credit Score:
SELECT 
    *,
    CASE 
        WHEN CreditScore >= 800 THEN 'Excellent'
        WHEN CreditScore >= 740 AND CreditScore < 800 THEN 'Very Good'
        WHEN CreditScore >= 670 AND CreditScore < 740 THEN 'Good'
        WHEN CreditScore >= 580 AND CreditScore < 670 THEN 'Fair'
        WHEN CreditScore >= 300 AND CreditScore < 580 THEN 'Poor'
        ELSE 'Unknown'
    END AS CreditScoreCategory
FROM bank_churn 
order by CreditScoreCategory;

-- Segmentation by Age Group:
SELECT 
    *,
    CASE 
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 24 THEN '18-24'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN Age BETWEEN 45 AND 54 THEN '45-54'
        WHEN Age BETWEEN 55 AND 64 THEN '55-64'
        WHEN Age >= 65 THEN '65+'
        ELSE 'Unknown'
    END AS AgeGroup
FROM customerinfo;

-- Segmentation by Tenure Group:
SELECT 
    *,
    CASE 
        WHEN Tenure < 1 THEN '0-1 year'
        WHEN Tenure BETWEEN 1 AND 3 THEN '1-3 years'
        WHEN Tenure BETWEEN 4 AND 6 THEN '4-6 years'
        WHEN Tenure BETWEEN 7 AND 9 THEN '7-9 years'
        ELSE 'Unknown'
    END AS TenureGroup
FROM bank_churn;

-- 11. What is the current churn rate per year and overall as well in the bank? Can you suggest some insights to the bank 
-- about which kind of customers are more likely to churn and what different strategies can be used to decrease the churn rate?

select
	DATEPART(year,ci.Bank_DOJ) as year,
	sum(bc.Exited)*100/count(*) as churn_rate
from
	CustomerInfo ci join Bank_Churn bc
	on ci.CustomerId=bc.CustomerId
	group by DATEPART(year,ci.bank_doj)

select AVG(exited) from Bank_Churn;

