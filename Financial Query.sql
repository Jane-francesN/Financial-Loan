USE [FINANCIAL DB]

--- To view the entire Data Set
SELECT *
FROM dbo.financial_loan

--- To find the total loan amount issued by the company 

SELECT SUM (loan_amount) AS Total_loan
FROM dbo.financial_loan

--- To find the Month to Date Total loaned Amount

SELECT SUM(loan_amount) AS MTD_loan_amount
FROM dbo.financial_loan
WHERE MONTH(issue_date) = 12


--- To find the Previous Month to Date Total loaned Amount

SELECT SUM(loan_amount) AS PMTD_loan_amount
FROM dbo.financial_loan
WHERE MONTH(issue_date) = 11


--- To find the total loan application issued by the company 

SELECT COUNT(id) AS Total_loan_application
FROM dbo.financial_loan

--- To find the Month to Date Total loaned Application

SELECT COUNT(id) AS MTD_loan_applicatiobn
FROM dbo.financial_loan
WHERE MONTH(issue_date) = 12


--- To find the Previous Month to Date Total loaned Application

SELECT COUNT(id) AS PMTD_loan_application
FROM dbo.financial_loan
WHERE MONTH(issue_date) = 11

--- To find the total amount paid back 

SELECT SUM (total_payment) AS total_amount_paid
FROM dbo.financial_loan


--- To find the Month to Date Total Payed Amount

SELECT SUM(total_payment) AS MTD_paid_amount
FROM dbo.financial_loan
WHERE MONTH(issue_date) = 12


--- To find the Previous Month to Date Total loaned Amount

SELECT SUM(total_payment) AS PMTD_total_payment
FROM dbo.financial_loan
WHERE MONTH(issue_date) = 11


--- To find the total Net Profit made by the company

SELECT SUM (total_payment) - SUM(loan_amount) AS Total_Net_profit
FROM dbo.financial_loan


--- To find the Month to Date Net Profit

SELECT SUM (total_payment) - SUM(loan_amount) AS MTD_Net_profit
FROM dbo.financial_loan
WHERE MONTH(issue_date) = 12


--- To find the Previous Month to Date Net Profit

SELECT SUM (total_payment) - SUM(loan_amount) AS PMTD_Net_profit
FROM dbo.financial_loan
WHERE MONTH(issue_date) = 11

--- To find the average interest rate

SELECT CAST(AVG(int_rate) * 100 AS DECIMAL (10, 2)) AS Avg_int_rate
FROM dbo.financial_loan


SELECT loan_status,
	   CAST(AVG(int_rate) * 100 AS DECIMAL (10, 2)) AS Avg_int_rate
FROM dbo.financial_loan
GROUP BY loan_status


--- To find the Month to Date average interest rate

SELECT CAST(AVG(int_rate) * 100 AS DECIMAL (10, 2)) AS MTD_Avg_int_rate
FROM dbo.financial_loan
WHERE MONTH(issue_date) = 12



--- To find the Previous Month to Date average interest rate

SELECT CAST(AVG(int_rate) * 100 AS DECIMAL (10, 2)) AS PMTD_Avg_int_rate
FROM dbo.financial_loan
WHERE MONTH(issue_date) = 11


--- To find the average DTI 

SELECT CAST(AVG(dti) * 100 AS DECIMAL(10, 2)) AS Avg_dti
FROM dbo.financial_loan


--- To find the Month to Date Average DTI

SELECT CAST(AVG(dti) * 100 AS DECIMAL(10, 2)) AS MTD_Avg_dti
FROM dbo.financial_loan
WHERE MONTH(issue_date) = 12



--- To find the Previous Month to Date Average DTI

SELECT CAST(AVG(dti) * 100 AS DECIMAL(10, 2)) AS PMTD_Avg_dti
FROM dbo.financial_loan
WHERE MONTH(issue_date) = 11

--- To find the (total loan issued, total loaned amount and total payment) in Good Standing

SELECT COUNT(id) AS Good_Total_loan_issued, 
	   SUM(loan_amount) AS Good_Total_loan_amount,
	   SUM(total_payment) AS Good_Total_payment
FROM dbo.financial_loan
WHERE loan_status = 'Fully Paid' OR loan_status =  'Current'


--- To find the (total loan issued, total loaned amount and total payment) NOT in Good Standing

SELECT COUNT(id) AS Bad_Total_loan_issued, 
	   SUM(loan_amount) AS Bad_Total_loan_amount,
	   SUM(total_payment) AS Bad_Total_payment
FROM dbo.financial_loan
WHERE loan_status = 'Charged off'



--- To find the Top 10 States with the highest number of Loan application, Loaned Amount and Total payment
--- LOAN APPLICATION
WITH TopStates AS (
    SELECT TOP 10 
           address_state, 
           COUNT(id) AS loan_count
    FROM dbo.financial_loan
    GROUP BY address_state
    ORDER BY loan_count DESC
)

SELECT ts.address_state, 
       fl.loan_status, 
       COUNT(fl.id) AS loan_status_count,
       ts.loan_count AS total_loan_application,
       ROUND(CAST(COUNT(fl.id) AS FLOAT) / ts.loan_count * 100, 2) AS loan_status_percentage
FROM TopStates ts
JOIN dbo.financial_loan fl
ON ts.address_state = fl.address_state
GROUP BY ts.address_state, fl.loan_status, ts.loan_count
ORDER BY ts.address_state, loan_status_percentage DESC;

--- LOANED AMOUNT
SELECT Top 10 address_state, SUM(loan_amount) AS loan_amount
FROM dbo.financial_loan
GROUP BY address_state
ORDER BY loan_amount DESC

--- TOTAL PAYMENT
SELECT Top 10 address_state, SUM(total_payment) AS total_payment
FROM dbo.financial_loan
GROUP BY address_state
ORDER BY total_payment DESC


--- To find all the KPI'S with respect to Loan Status

SELECT loan_status,
	   COUNT (id) AS Total_loan_application,
	   SUM (loan_amount) AS Loaned_amount,
	   SUM (total_payment)AS Total_loan_paid,
	   CAST(AVG(int_rate * 100) AS DECIMAL(10,2))  AS avg_int_rate,
	   CAST(AVG (dti * 100) AS DECIMAL (10,2)) AS avg_dti
FROM dbo.financial_loan
GROUP BY loan_status



--- To find the average income and default rate of payment based on emp_length

SELECT emp_length,
	  COUNT(id) AS loan_application,
	  CAST(AVG(annual_income) AS DECIMAL(10,2)) AS Avg_income,
      CAST(COUNT(CASE WHEN loan_status = 'Charged off' THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL (10,2)) AS default_rate
FROM dbo.financial_loan
GROUP BY emp_length
ORDER BY default_rate DESC;


--- To find out the number of loan applications based on its purpose  

SELECT purpose, COUNT(id) AS loan_applications
FROM dbo.financial_loan
GROUP BY purpose
ORDER BY loan_applications DESC

SELECT f.purpose,f.loan_status, 
	   COUNT(f.id) AS loan_count
FROM dbo.financial_loan f
JOIN
	 (SELECT purpose, COUNT(id) AS total_count
	 FROM dbo.financial_loan
	 GROUP BY purpose) AS total_counts
ON f.purpose = total_counts.purpose
GROUP BY f.purpose, f.loan_status, total_counts.total_count
ORDER BY total_counts.total_count DESC, loan_count DESC


--- To find out the influence home ownership status have on borrowers

SELECT home_ownership,
	   COUNT(id) AS loan_application
FROM dbo.financial_loan
GROUP BY home_ownership
ORDER BY loan_application DESC


SELECT home_ownership,
	   SUM(total_payment) AS total_payment,
	   CAST(SUM(total_payment) * 100.0 / (SELECT SUM(total_payment) FROM dbo.financial_loan) AS DECIMAL (10,2)) AS percentage_of_total_payment
FROM dbo.financial_loan
GROUP BY home_ownership
ORDER BY total_payment DESC


SELECT home_ownership, loan_status,
		COUNT (id) AS loan_application,
	   CAST(COUNT(id) * 100.0 / (SELECT COUNT(id) FROM dbo.financial_loan) AS DECIMAL(10,2)) AS percentage_of_total_application
FROM dbo.financial_loan
GROUP BY home_ownership, loan_status
ORDER BY home_ownership



USE [FINANCIAL DB]
---- To find out how payment vary by loan_term

SELECT term, loan_status, COUNT(id) AS loan_application
FROM dbo.financial_loan
GROUP BY term, loan_status
ORDER BY term, loan_application DESC

SELECT term,
	   home_ownership,
	   ROUND(AVG(CAST(total_payment AS FLOAT) /CAST(loan_amount AS FLOAT)), 2) AS repayment_ratio
	   FROM dbo.financial_loan
	   GROUP BY term, home_ownership
	   ORDER BY repayment_ratio

FROM
--- To find the average income and default rate of payment based on emp_length

SELECT TOP 10 address_state,
	  COUNT(id) AS loan_application,
	  CAST(AVG(annual_income) AS DECIMAL(10,2)) AS Avg_income,
      CAST(COUNT(CASE WHEN loan_status = 'Charged off' THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL (10,2)) AS default_rate
FROM dbo.financial_loan
GROUP BY address_state
ORDER BY default_rate DESC;

SELECT *
FROM dbo.financial_loan
WHERE address_state = 'NE'


--- To find the number of loan issued monthly
SELECT *
FROM dbo.financial_loan


SELECT MONTH(issue_date) AS month_number,
	   DATENAME(MONTH, issue_date) AS issued_month, 
	   COUNT(id) AS total_loan_applications,
	   SUM(loan_amount) AS loaned_amount,
	   SUM(total_payment) AS total_payment
FROM dbo.financial_loan
GROUP BY MONTH(issue_date), DATENAME(MONTH, issue_date)
ORDER BY MONTH(issue_date)