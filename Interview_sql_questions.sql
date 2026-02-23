--to generate the numbers from 1 to 10 in oracle

SELECT LEVEL AS n
FROM   dual
CONNECT BY LEVEL <= 10;

--Employee and manager name with connect by prior in oracle

SELECT  e.empno,
e.ename
--,PRIOR e.ename AS manager_name
FROM    emp e
START WITH e.mgr IS NULL               -- roots (CEOs)
CONNECT BY PRIOR e.empno = e.mgr;     -- parent emp_id = child manager_id

--Each row shows an employee; PRIOR e.ename is the parent (manager) name.
--Add WHERE LEVEL > 1 if you want to exclude the top-level (which has no manager).

--B) Only the immediate manager for a specific employee
SELECT  PRIOR e.ename AS manager_name
FROM    emp e
START WITH e.empno = :empno                   -- your employee
CONNECT BY PRIOR e.empno = e.mgr              -- walk *up* to parent
AND      LEVEL = 2;                           -- the first step up is the manager

--C) Full chain of managers (top → employee)
SELECT  LEVEL           AS lvl,
e.emp_id,
e.ename,
SYS_CONNECT_BY_PATH(e.ename, ' / ') AS chain
FROM    emp e
START WITH e.manager_id IS NULL
CONNECT BY PRIOR e.emp_id = e.manager_id;


-- start at emp_id and flip the CONNECT BY to walk upward:

SELECT  e.empno,
e.ename,
LEVEL AS lvl_up,
SYS_CONNECT_BY_PATH(e.ename, ' -> ') AS up_chain
FROM    emp e
START WITH e.empno = :empno
CONNECT BY PRIOR e.mgr = e.empno;
--------------------------------------------------------------------------------------------
-- waq to get salaries more than average salary -- approach 1
select *
from emp e
where e.sal > (select cast(avg(sal) as int) as avgsal from emp );

-- waq to get salaries more than average salary approach 2
with avg_sal (avgsal) as 
(select cast(avg(sal) as int) as avgsal from emp )
select *
from emp e, avg_sal avg
where e.sal > avg.avgsal;
------------------------------------------------------------------------------------
--- waq to get average of total salary department wise
select cast(avg(sumsal) as int) avg
from 
(select e.deptno, cast(sum(sal) as int) sumsal from emp e group by deptno) as total_avg
-------------------------------------------------------------------------------------
--- waq to get the sum of salary is more than average salary, approach-1 
select * from 
(select e.deptno, cast(sum(sal) as int) sumsal_dept
from emp e
group by deptno) sum_sal_dept
join
(select cast(avg(sumsal) as int) avgsumsal
from 
(select e.deptno, cast(sum(sal) as int) sumsal
from emp e group by deptno) as total_avg) as totalavg
on sum_sal_dept.sumsal_dept > totalavg.avgsumsal

--- waq to get the sum of salary is more than average salary - approach-2

  

-------------------------------------------------------------------------------------------------------
--- WAQ to previous salary, previous second salary with default value null or 0
select e.*,
lag(sal) over (partition by deptno order by deptno desc) as previous_sal, -- default value is null
lag(sal,2,0) over (partition by deptno order by deptno desc) as previous_2_sal, -- default values 0
lead(sal) over (partition by deptno order by deptno desc) as previous_sal, -- default value is null
lead(sal,2,0) over (partition by deptno order by deptno desc) as previous_2_sal, -- default values 0
from emp e;
-------------------------------------------------------------------------------------------------------------------------
--Find customers with successful multiple purchases in the last 1 month. Purchase is considered successful if they are not returned within 1 week of purchase. 
select * from purchases;
select * from customers;
select * from orders;

-- SOLUTION:
select customer_id
from purchases
where purchase_date > cast(purchase_date - interval '1 month' as date)
and (return_date is null or return_date > cast(purchase_date + interval '1 week' as date))
group by customer_id
having count(customer_id) > 1;


- Problem 2: Latest Order Summary per Customer

-- Problem Statement: Write an SQL query to fetch the customer name, their latest order date and total value of the order. 
If a customer made multiple orders on the latest order date then fetch total value for all the orders in that day. If a customer has not done an order yet, 
display the “9999-01-01” as latest order date and 0 as the total order value.

-- SOLUTION:
select customer
, COALESCE(order_date, '9999-01-01') as last_order_date
, COALESCE(SUM(total_cost), 0) as total_value
from (SELECT o.*,c.name as customer, rank() over(partition by o.customer_id order by order_date desc) as rnk 
FROM orders2 o
right join customers c on c.customer_id = o.customer_id) x
where x.rnk = 1
group by customer_id, customer, order_date;

------------------------------------------------------------------------------------------------------------------------
-- Problem Statement: Find customers who have not placed any orders yet in 2025 but had placed orders in every month of 2024 and had placed orders 
at least 6 in the months in 2023. Display the customer name.
-- Solution 1:
with customers_2025 as
(select * 
from orders
where extract(year from order_date) = 2025),
customers_2024 as 
(select customer_id
, count(extract(month from order_date)) as unique_monthly_orders
from orders
where extract(year from order_date) = 2024
group by customer_id
having count(distinct extract(month from order_date)) >= 12),
customers_2023 as
(select customer_id
, count(extract(month from order_date)) as unique_monthly_orders
from orders
where extract(year from order_date) = 2023
group by customer_id
having count(distinct extract(month from order_date)) >= 6)

select c.name as customer
from customers c
join customers_2024 c24 on c24.customer_id = c.id
join customers_2023 c23 on c23.customer_id = c.id
where c.id not in (select customer_id from customers_2025);


-- Solution 2:
with cte as 
(select o.customer_id, c.name as customer
, extract(year from order_date) as order_year
, count(distinct extract(month from order_date)) as unique_monthly_orders
from orders o
join customers c on c.customer_id = o.customer_id
group by o.customer_id, c.name, order_year)
select c23.customer
from cte c23
join cte c24 on c23.customer_id = c24.customer_id
where c23.order_year = 2023 and c23.unique_monthly_orders >= 6
and c24.order_year = 2024 and c24.unique_monthly_orders >= 12
and c23.customer_id not in (select customer_id from cte where order_year = 2025);
---------------------------------------------------------------------------------------------------------------------
-- Uline interview question

this is the input data  
enrollid	carriermemid	planid	effdate	termdate
1	101	A	01-01-2023	30-06-2023
2	101	A	01-07-2023	31-12-2023
3	101	B	15-01-2024	30-06-2024
4	102	C	01-03-2023	31-08-2023
5	102	C	01-09-2023	28-02-2024
6	102	D	02-03-2024	31-08-2024

i want output like below data in oracle 

carriermemid	coverage_group	start_date	end_date
101	1	01-01-2023	31-12-2023
101	2	15-01-2024	30-06-2024
102	1	01-03-2023	28-02-2024
102	2	02-03-2024	31-08-2024

You can collapse contiguous rows (same plan, next effdate = prev termdate + 1) into “coverage groups” with analytics.
Assuming a table enrollments(enrollid, carriermemid, planid, effdate, termdate) where dates are strings DD-MM-YYYY (convert as needed):
What it does?
is_break = 1 when the plan is changed or the next row doesn’t start the day after the previous termdate.

The running SUM(is_break) gives coverage_group 1, 2, 3, …
Final MIN(effdate)/MAX(termdate) roll up each group.
This yields your desired output:

WITH r AS (
SELECT
e.*,
CASE
WHEN LAG(planid) OVER (PARTITION BY carriermemid ORDER BY effdate) = planid AND LAG(termdate) OVER (PARTITION BY carriermemid ORDER BY effdate) + 1 = effdate
THEN 0 ELSE 1
END AS is_break
FROM enrollments e
),
g AS (
SELECT r.*,
SUM(is_break) OVER (PARTITION BY carriermemid ORDER BY effdate ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS coverage_group
FROM r
)
SELECT carriermemid,
coverage_group,
MIN(effdate)  AS start_date,
MAX(termdate) AS end_date
FROM g
GROUP BY carriermemid, coverage_group
ORDER BY carriermemid, coverage_group;


This yields exactly the output you showed for your sample data.
-----------------------------------------------------------------------------------------------------------------
----Below query transpose columns into rows. 
Name No Add1 Add2 
abc 100 Hyd bang 
xyz 200 Mysore pune 

SELECT NAME, NO, add1 FROM a 
UNION 
SELECT NAME, NO, add2 FROM a; 

----4. Below query transpose rows into columns. 
SQL> SELECT   emp_id, MAX (DECODE (row_id, 0, address)) AS address1, 
MAX (DECODE (row_id, 1, address)) AS address2, 
MAX (DECODE (row_id, 2, address)) AS address3 
FROM 
(SELECT   emp_id, address, MOD (ROWNUM, 3) row_id FROM temp ORDER BY emp_id) A
GROUP BY emp_id; 

Other query: 
SQL> SELECT   emp_id, MAX (DECODE (rank_id, 1, address)) AS add1, 
MAX (DECODE (rank_id, 2, address)) AS add2, 
MAX (DECODE (rank_id, 3, address)) AS add3 
FROM (SELECT emp_id, address, RANK () OVER (PARTITION BY emp_id ORDER BY emp_id, address) rank_id FROM temp) A
GROUP BY emp_id;
-------------------------------------------------------------------------------------------------------------
-- How to display alternative rows in a table? 
SQL> SELECT * FROM emp 
WHERE (ROWID, 0) IN  
(SELECT ROWID, MOD (ROWNUM, 2) FROM emp); 

-------------------------------------------------------------------------------------------------------------
-- Hierarchical queries 
--Starting at the root, walk from the top down, and eliminate employee Higgins in the 
--result, but process the child rows. 
SQL> SELECT department_id, employee_id, last_name, job_id, salary 
FROM employees 
WHERE last_name  = 'Higgins' 
START WITH manager_id IS NULL 
CONNECT BY PRIOR employee_id = manager_id; 
----------------------------------------------------------------------------------------------------------------
-- WAQ to add employee names in one column all values for each department seperately.

listagg

  SELECT Deptno, LISTAGG(Ename, ‘,’)  
     WITHIN GROUP (ORDER BY Ename) as Emp_Name 
     FROM Employees 
     GROUP BY Deptno; 


---------------------------------------------------------------------------------------------------------------------
--- WAQ to find the origin and destination for a customer with multiple lay overs 

--CREATE TABLE Flights (cust_id INT, flight_id VARCHAR(10), origin VARCHAR(50), destination VARCHAR(50));

--INSERT INTO Flights (cust_id, flight_id, origin, destination)
--VALUES (1, 'SG1234', 'Delhi', 'Hyderabad'), (1, 'SG3476', 'Kochi', 'Mangalore'), (1, '69876', 'Hyderabad', 'Kochi'), (2, '68749', 'Mumbai', 'Varanasi'), 
--        (2, 'SG5723', 'Varanasi', 'Delhi');
with origins as (
select f1.cust_id,f1.origin from Flights f1 left join Flights f2 on f1.cust_id=f2.cust_id and f1.origin=f2.destination
where f2.origin is null order by cust_id),
destinations as (
select f1.cust_id,f1.destination from Flights f1 left join Flights f2 on f1.cust_id=f2.cust_id and f1.destination= f2.origin
where f2.destination is null order by cust_id)

select * from origins  o inner join destinations d on o.cust_id=d.cust_id
------------------------------------------------------------------------------------------------------------------       
---- waq to use cases with grouping set, rollup, and cube aggregate functions.
--grouping set

select null as deptno,null as mgr,sum(sal) 
from emp
union
select deptno,null as mgr,sum(sal) 
from emp
group by deptno
union
select deptno,mgr,sum(sal) 
from emp
group by deptno,mgr
;

--equivalent query as above is, can be written as below

select deptno,mgr,sum(sal) as total_sal
from emp
group by grouping sets(deptno,mgr,())

select deptno,mgr,sum(sal) as total_sal
from emp
group by grouping sets((deptno,mgr))


----rollup
select deptno,mgr,sum(sal) as total_sal
from emp
group by rollup(deptno,mgr)

--equivalent
group by deptno,mgr
union
group by deptno
union
group by ()

--- Cube -- multi dimentional report
-- all the possible combinations columns on group by

select deptno,mgr,sum(sal) as total_sal
from emp
group by cube(deptno,mgr)

--equivalent
group by deptno,mgr
union
group by deptno
union
group by mgr
union
group by mgr,deptno
union
group by ()
-------------------------------------------------------------------------------------------------------------
Virtusa interview question
How do you detect and remove duplicate records in SQL using a CTE?

WITH duplicate_cte AS (
SELECT employee_id,
ROW_NUMBER() OVER (PARTITION BY first_name, last_name, department ORDER BY employee_id) AS row_num
FROM employees) 

DELETE FROM employees WHERE employee_id IN ( SELECT employee_id FROM duplicate_cte WHERE row_num > 1);
------------------------------------------------------------------------------------------------------------------
Write a query to find the employee who generated the maximum revenue last year

SELECT e.employee_id,
e.employee_name,
SUM(s.sale_amount) AS total_revenue
FROM employees e
JOIN sales s
ON e.employee_id = s.employee_id
WHERE EXTRACT(YEAR FROM s.sale_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1
GROUP BY e.employee_id, e.employee_name
ORDER BY total_revenue DESC
FETCH FIRST 1 ROW ONLY;

select deptno,sum(sal) as max_revenue
from emp
group by deptno
order by max_revenue desc
fetch first 1 row only;

select top 1 deptno,sum(sal) as max_revenue
from emp
group by deptno
order by max_revenue desc

select deptno,sum(sal) as max_revenue
from emp
group by deptno
order by max_revenue desc limit 1

select * from 
(select deptno,sum(sal) deptno_sal
from emp
group by deptno) a
qualify row_number() over (order by deptno_sal desc) =1
-----------------------------------------------------------------------------------------------------------------
Find Consecutive Login Days

SELECT emp_id, login_date
FROM (
SELECT emp_id, login_date,
LAG(login_date,1) OVER (PARTITION BY emp_id ORDER BY login_date) AS prev1,
LAG(login_date,2) OVER (PARTITION BY emp_id ORDER BY login_date) AS prev2
FROM logins
)
WHERE login_date - prev1 = 1 AND prev1 - prev2 = 1;
------------------------------------------------------------------------------------------------------------------
Excellent — this is a “find users with ≥3 consecutive login days” problem.

🔹Input Table
user_id	login_date
U1	2024-06-01
U1	2024-06-02
U1	2024-06-03
U1	2024-06-05
U2	2024-06-01
U2	2024-06-03

Query: 
WITH t AS (
SELECT 
user_id,
login_date,
login_date - ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY login_date) AS grp  --  output date will be same, so we can use group by dates as shown below
FROM logins
)
SELECT user_id
FROM t
GROUP BY user_id, grp
HAVING COUNT(*) >= 3;

Example for U1:

login_date	row_number	login_date - rn	group
2024-06-01	1	2024-05-31	G1
2024-06-02	2	2024-05-31	G1
2024-06-03	3	2024-05-31	G1
2024-06-05	4	2024-06-01	G2

---------------------------------------------------------------------------------------------------------------
Find employees whose salary decreased at any time.
SELECT emp_id
FROM (
SELECT emp_id, salary,
LAG(salary) OVER (PARTITION BY emp_id ORDER BY effective_date) AS prev_salary
FROM salary_history
)
WHERE salary < prev_salary;
-----------------------------------------------------------------------------------------------------------------
Pivoting / Transposing Data  -- Convert them into columns: (Math, Science, English).
SELECT student,
MAX(CASE WHEN subject='Math' THEN marks END) AS Math,
MAX(CASE WHEN subject='Science' THEN marks END) AS Science,
MAX(CASE WHEN subject='English' THEN marks END) AS English
FROM scores
GROUP BY student;
--------------------------------------------------------------------------------------------------------------------
Running Average & Rolling Window
For a stock table: stocks(symbol, trade_date, price),
Find 7-day rolling average price per symbol.

SELECT symbol, trade_date,
AVG(price) OVER (PARTITION BY symbol ORDER BY trade_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS avg_7day
FROM stocks;
-------------------------------------------------------------------------------------------------------------------
Identify Overlapping Date Ranges
Scenario:
A customer can have multiple policies: policy_id, cust_id, start_date, end_date.
Find customers who have overlapping policy periods.

SELECT
p1.cust_id,
p1.policy_id AS policy_1,
p2.policy_id AS policy_2,
p1.start_date AS start_1,
p1.end_date AS end_1,
p2.start_date AS start_2,
p2.end_date AS end_2
FROM
customer_policies p1 JOIN customer_policies p2 ON p1.cust_id = p2.cust_id
AND p1.policy_id < p2.policy_id
and p2.start_date between p1.start_date and p1.end_date
--AND p1.end_date >= p2.start_date
-- AND p1.start_date <= p2.end_date
ORDER BY
p1.cust_id, p1.policy_id;
--------------------------------------------------------------------------------------------------------------
From a trading table: trade_id, account_id, trade_value, trade_date
Find top 3 trades by value per account in each month.

select * from (
select trade_date,trade_id,trade_value,account_id,
--date_trunc('month', trade_date) as month_trade1,
--extract('month',trade_date) as month_trade
row_number() over (partition by account_id, extract('month',trade_date) order by trade_value desc) as rn
from trading
order by account_id
) where rn <=3
------------------------------------------------------------------------------------------------------------
For each customer, find their first and last transaction date and amount difference.
SELECT 
customer_id,
FIRST_VALUE(amount) OVER (PARTITION BY customer_id ORDER BY txn_date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS first_txn,
LAST_VALUE(amount) OVER (PARTITION BY customer_id ORDER BY txn_date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_txn,
LAST_VALUE(amount) OVER (PARTITION BY customer_id ORDER BY txn_date ASCROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) - FIRST_VALUE(amount)
OVER (PARTITION BY customer_id ORDER BY txn_date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
) AS diff
FROM transactions;

----------------------------------------------------------------------------------------------------------
Find top products that contribute to 80% of total sales.

WITH prod_sales AS (
SELECT product, SUM(cost) AS total_rev
FROM sales
GROUP BY product
)
,ranked AS (
SELECT product, total_rev,
SUM(total_rev) OVER (ORDER BY total_rev DESC) AS running_total,
SUM(total_rev) OVER () AS grand_total
FROM prod_sales
--order by total_rev desc;
)
SELECT product, total_rev,0.8 * grand_total
FROM ranked
WHERE running_total <= 0.8 * grand_total
order by total_rev;
----------------------------------------------------------------------------------------------------
Classify customers as:

“New” if first transaction < 30 days old
“Active” if transacted in last 90 days
“Dormant” otherwise.

SELECT cust_id,
CASE
WHEN MAX(txn_date) >= CURRENT_DATE - 30 THEN 'New'
WHEN MAX(txn_date) BETWEEN CURRENT_DATE - 90 AND CURRENT_DATE - 31 THEN 'Active'
ELSE 'Dormant'
END AS status
FROM transactions
GROUP BY cust_id;

---------------------------------------------------------------------------------------------------
You have a time series: date, product_id, price (some prices are NULL).
Fill each NULL price with the most recent non-null value.

SELECT product_id, date,
LAST_VALUE(price IGNORE NULLS) OVER (PARTITION BY product_id ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS filled_price
FROM time_series
order by date;
--------------------------------------------------------------------------------------------------
Employee:
EMP_ID ENAME SAL   DEPT_ID
1      X     1000   100
2      Y     2000   100
3      Z     3000   100
2      Y     1500   101

Department:
DEPT_ID, DEPT_NAME
100      Home 
101      Retail

I want OUTPUT as below:
EMP_ID ENAME SAL DEPT_ID, DEPT_NAME LOAD_TS LST_UPDT_TS

LOAD_TS → populated only once when the employee–department record is inserted the first time.
LST_UPDT_TS → should be NULL initially, and updated only when salary changes for the same employee in the same department.

MERGE INTO employee_audit tgt
USING (
SELECT e.emp_id, e.ename, e.sal, e.dept_id, d.dept_name
FROM employee e
JOIN department d ON e.dept_id = d.dept_id
) src
ON (tgt.emp_id = src.emp_id AND tgt.dept_id = src.dept_id)
WHEN MATCHED THEN
UPDATE SET 
tgt.sal = src.sal,
tgt.lst_updt_ts = CASE 
WHEN tgt.sal <> src.sal THEN SYSDATE 
ELSE tgt.lst_updt_ts 
END
WHEN NOT MATCHED THEN
INSERT (emp_id, ename, sal, dept_id, dept_name, load_ts, lst_updt_ts)
VALUES (src.emp_id, src.ename, src.sal, src.dept_id, src.dept_name, SYSDATE, NULL);
----------------------------------------------------------------------------------------------------------------------------
Pyramid interview question:

You are given the following two tables:
1. Transactions
Column	Type
transaction_id	INT
account_id	INT
amount	DECIMAL
transaction_time	DATETIME

2. Accounts
Column	Type
account_id	INT
account_open_date	DATE
branch	VARCHAR

Challenge

Write a single SQL query to return 
The latest transaction per account
The transaction amount
The number of transactions the account has ever made
The branch name from the Accounts table

Sol 1:
SELECT
transaction_id,
account_id,
amount,
count(*) over (PARTITION by transaction_id order by transaction_time desc) number_of_records,
rank () over (PARTITION by transaction_id order by transaction_time desc) rn
branch
from Transactions t join Accounts A on t.account_id=a.account_id

Sol 2:
SELECT
t.account_id,
t.transaction_id,
t.amount AS latest_transaction_amount,
COUNT(*) OVER (PARTITION BY t.account_id) AS total_transactions,
a.branch
FROM Transactions t
JOIN Accounts a
ON t.account_id = a.account_id
QUALIFY ROW_NUMBER() OVER (PARTITION BY t.account_id ORDER BY t.transaction_time DESC) = 1;

Sol 3:

SELECT
account_id,
transaction_id,
amount AS latest_transaction_amount,
total_transactions,
branch
FROM (
SELECT
t.account_id,
t.transaction_id,
t.amount,
a.branch,
COUNT(*) OVER (PARTITION BY t.account_id) AS total_transactions,
ROW_NUMBER() OVER (PARTITION BY t.account_id ORDER BY t.transaction_time DESC
) AS rn
FROM Transactions t JOIN Accounts a ON t.account_id = a.account_id
)
WHERE rn = 1;

----------------------------------------------------------------------------------------------------------
1. substr and instr combination

sql
SELECT
SUBSTR(full_name, 1, INSTR(full_name, ' ') - 1) AS first_name,
SUBSTR(full_name, INSTR(full_name, ' ') + 1)   AS last_name
FROM (
SELECT 'ravi adulla' AS full_name FROM dual
);

----------------------------------------------------------------------------------------------------------  
2. explain plan like sql query performance
**“When I analyze an explain plan, I focus on five things:

Access paths — whether the query is using indexes or doing full table scans.
Join methods — nested loops, hash, or merge, and whether they match the table sizes.
Cardinality estimates — to check if the optimizer is estimating rows correctly.
Expensive operations — sorts, aggregations, or large scans that increase cost.
Predicate and partition usage — making sure filters, statistics, and partition pruning are effective.
This helps me identify the exact steps causing slowness and tune the SQL or indexes accordingly.”**

✅ Real Project Example (Strong Senior-Level Answer)

**“In one of my recent projects, a report query was running in 20+ minutes.
From the explain plan, I noticed:
A full table scan on a 30M row table instead of an index range scan.
A hash join spilling to temp due to bad cardinality estimates.
Partition pruning wasn’t happening.
I fixed statistics, added a composite index for the filter columns, and rewrote part of the WHERE clause to be sargable. After tuning, the query ran in 40 seconds.
So I always use the plan to find wrong access paths, incorrect row estimates, and heavy operations.”**

------------------------------------------------------------------------------------------
CAST(100 AS VARCHAR(10))
CAST('2025-12-09' AS DATE)
CAST(hire_date AS VARCHAR(20))

SELECT COALESCE(NULL, NULL, 'Hello', 'World'); -- first not null value
SELECT COALESCE(salary, 0) AS salary_fixed FROM employees;
---------------------------------------------------------------------------------------
PIVOT queries

A PIVOT query converts rows into columns (a cross-tab format).

SELECT *
FROM (
SELECT column_to_group, column_to_pivot, value_column
FROM your_table
)
PIVOT (
AGG_FUNCTION(value_column)
FOR column_to_pivot IN (value1, value2, value3 ...)
);

| EMP | MONTH | AMOUNT |
| --- | ----- | ------ |
| A   | JAN   | 100    |
| A   | FEB   | 200    |
| B   | JAN   | 300    |

SELECT *
FROM (
SELECT emp, month, amount
FROM sales
)
PIVOT (
SUM(amount)
FOR month IN ('JAN' AS JAN, 'FEB' AS FEB)
);

SELECT emp, [JAN], [FEB]
FROM sales
PIVOT (
SUM(amount)
FOR month IN ([JAN], [FEB])
) AS p;

SELECT 
group_col,
SUM(CASE WHEN pivot_col = 'value1' THEN value ELSE 0 END) AS value1,
SUM(CASE WHEN pivot_col = 'value2' THEN value ELSE 0 END) AS value2
FROM table
GROUP BY group_col;

SELECT
emp,
SUM(CASE WHEN month = 'JAN' THEN amount END) AS JAN,
SUM(CASE WHEN month = 'FEB' THEN amount END) AS FEB,
SUM(CASE WHEN month = 'MAR' THEN amount END) AS MAR
FROM sales
GROUP BY emp;
-----------------------------------------------------------------------------------
Input:  Write a solution to find the employees who are high earners in each of the departments.
this is interveiw hack question by giving Id and departmentId same values like 1, 2.
Here rank or dense_rank analytical functions are not required.

Explanation: 
In the IT department:
- Max earns the highest unique salary
- Both Randy and Joe earn the second-highest unique salary
- Will earns the third-highest unique salary

In the Sales department:
- Henry earns the highest salary
- Sam earns the second-highest salary
- There is no third-highest salary as there are only two employees

Employee table:
+----+-------+--------+--------------+
| id | name  | salary | departmentId |
+----+-------+--------+--------------+
| 1  | Joe   | 85000  | 1            |
| 2  | Henry | 80000  | 2            |
| 3  | Sam   | 60000  | 2            |
| 4  | Max   | 90000  | 1            |
| 5  | Janet | 69000  | 1            |
| 6  | Randy | 85000  | 1            |
| 7  | Will  | 70000  | 1            |
+----+-------+--------+--------------+
Department table:
+----+-------+
| id | name  |
+----+-------+
| 1  | IT    |
| 2  | Sales |
+----+-------+
Output: 
+------------+----------+--------+
| Department | Employee | Salary |
+------------+----------+--------+
| IT         | Max      | 90000  |
| IT         | Joe      | 85000  |
| IT         | Randy    | 85000  |
| IT         | Will     | 70000  |
| Sales      | Henry    | 80000  |
| Sales      | Sam      | 60000  |
+------------+----------+--------+

Query 1: with partial output
SELECT d.name AS Department,
e.name AS Employee,
e.salary
FROM Employee e
JOIN Department d
ON e.departmentId = d.id;

Query 2: with expected output
Select Department.Name as Department, e.Name as Employee, e.Salary
from Employee e Inner Join Department
on e.DepartmentId = Department.Id
where (Select count(Distinct m.Salary) from Employee m where m.DepartmentId = e.DepartmentId and m.Salary > e.Salary) < 3;
----------------------------------------------------------------------------------------
Example 1: Write a solution to display the records with three or more rows with consecutive id's, and the number of people is greater than or equal to 100 for each.

Explanation: 
The four rows with ids 5, 6, 7, and 8 have consecutive ids and each of them has >= 100 people attended. Note that row 8 was included even though the visit_date was not the next day after row 7.
The rows with ids 2 and 3 are not included because we need at least three consecutive ids.

Input: 
Stadium table:
+------+------------+-----------+
| id   | visit_date | people    |
+------+------------+-----------+
| 1    | 2017-01-01 | 10        |
| 2    | 2017-01-02 | 109       |
| 3    | 2017-01-03 | 150       |
| 4    | 2017-01-04 | 99        |
| 5    | 2017-01-05 | 145       |
| 6    | 2017-01-06 | 1455      |
| 7    | 2017-01-07 | 199       |
| 8    | 2017-01-09 | 188       |
+------+------------+-----------+
Output: 
+------+------------+-----------+
| id   | visit_date | people    |
+------+------------+-----------+
| 5    | 2017-01-05 | 145       |
| 6    | 2017-01-06 | 1455      |
| 7    | 2017-01-07 | 199       |
| 8    | 2017-01-09 | 188       |
+------+------------+-----------+

Query :
with A as (
select id,people,visit_date
,id - row_number() over (order by id) as consecutive
from Stadium
where people >= 100
)

select 
id
,to_char (visit_date,'yyyy-mm-dd') as visit_date
,people
from A
--group by consecutive
where consecutive in (select consecutive from A group by consecutive having count(id)>=3)
--having count(id)>=3
order by visit_Date 

----------------------------------------------------------------------------------------------------------
Example 1: Write a solution to report the customer ids from the Customer table that bought all the products in the Product table.

Input: 
Customer table:
+-------------+-------------+
| customer_id | product_key |
+-------------+-------------+
| 1           | 5           |
| 2           | 6           |
| 3           | 5           |
| 3           | 6           |
| 1           | 6           |
+-------------+-------------+
Product table:
+-------------+
| product_key |
+-------------+
| 5           |
| 6           |
+-------------+
Output: 
+-------------+
| customer_id |
+-------------+
| 1           |
| 3           |
+-------------+

select 
customer_id
from Customer group by customer_id
having count(distinct product_key) = (select count(product_key) from  Product);
-------------------------------------------------------------------------------------------------
This is a classic SQL problem. The main challenge isn't just finding the 2nd highest salary, but handling the case where there is no 2nd highest salary
(e.g., the table is empty or has only one distinct salary). In that case, we must return NULL.

select 
SALARY as SecondHighestSalary 
from (
select id,salary
,dense_rank() over (order by salary desc) as rnk
from Employee
) a where rnk=2

SELECT MAX(salary) AS SecondHighestSalary
FROM Employee
WHERE salary < (SELECT MAX(salary) FROM Employee);

SELECT (
SELECT DISTINCT salary
FROM Employee
ORDER BY salary DESC
LIMIT 1 OFFSET 1
) AS SecondHighestSalary;
------------------------------------------------------------------------------------------------

I have table with the quantity of the product, can you help me the query to ungroup them

name, quantity 
apples, 4 
water bottles, 2

WITH cte (name, quantity, lvl) AS (
    SELECT name, quantity, 1
    FROM products
    UNION ALL
    SELECT name, quantity, lvl + 1
    FROM cte
    WHERE lvl < quantity
)
SELECT name
FROM cte;

SELECT name
FROM products
CONNECT BY LEVEL <= quantity
AND PRIOR name = name
AND PRIOR SYS_GUID() IS NOT NULL;
----------------------------------------------------------------------------------------------
what are the ways to delete duplicate records in sequel?
  
DELETE FROM employees
WHERE ROWID NOT IN (
    SELECT MIN(ROWID)
    FROM employees
    GROUP BY name, dept
);

DELETE FROM employees
WHERE ROWID IN (
    SELECT rid
    FROM (
        SELECT ROWID AS rid,
               ROW_NUMBER() OVER (
                   PARTITION BY name, dept
                   ORDER BY ROWID
               ) rn
        FROM employees
    )
    WHERE rn > 1
);
-----------------------------------------------------------------------------------------------





