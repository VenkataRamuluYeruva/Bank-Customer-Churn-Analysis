# Bank Customer Churn Analysis - SQL Project

## Project Overview
The Bank Customer Churn Analysis project is focused on understanding customer behavior and identifying factors that influence customer churn in a bank. The goal is to find different insights to predict whether a customer is likely to leave the bank (churn) or not based on key attributes such as credit score, tenure, account balance, number of products held, and other relevant factors. Through this insights a business man can improve their business.

## Key Objectives:
* **Analyze Customer Data**: Perform SQL-based exploratory data analysis (EDA) to identify key trends and patterns in customer behavior.
* **Churn Prediction**: Perform different types of SQL queries to predict customer churn based on historical data.
* **Insights Generation**: Provide actionable insights to help the bank retain valuable customers and improve customer satisfaction.

## Dataset:
The dataset includes customer information such as:

1. CustomerId: Unique identifier for each customer.
2. CreditScore: Credit score of the customer.
3. Tenure: Duration of the relationship with the bank (in years).
4. Balance: The current balance in the customer's account.
5. NumOfProducts: Number of financial products the customer has with the bank.
6. HasCrCard: Whether the customer holds a credit card with the bank (1 for yes, 0 for no).
7. IsActiveMember: Whether the customer is an active member (1 for yes, 0 for no).
8. EstimatedSalary: The estimated salary of the customer.
9. Exited: Indicates if the customer has churned (1 for yes, 0 for no).

## Correlation:
Correlation is a statistical measure that describes the degree and direction of the relationship between two variables. It helps to understand whether and how strongly pairs of variables are related.
**Formula for Pearson Correlation Coefficient**:
'''
                            𝑛(∑𝑥𝑦)−(∑𝑥)(∑𝑦)
                    r=  ------------------------------
                        sqrt([𝑛∑𝑥2−(∑𝑥)2][𝑛∑𝑦2−(∑𝑦)2])
'''
This is most important to find the Correlation between two factors of your data in this project

