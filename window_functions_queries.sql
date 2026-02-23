-----window functions

select * from product;

select * from emp;

-- Using Aggregate function as Window Function
-- Without window function, SQL will reduce the no of records.
select deptno, max(sal) from emp
group by deptno;

-- By using MAX as an window function, SQL will not reduce records but the result will be shown corresponding to each record.
select e.*,
max(sal) over(partition by deptno) as max_sal
from emp e;


-- row_number(), rank() and dense_rank()
select e.*,
row_number() over(partition by deptno order by sal desc) as rn
from emp e;


-- Fetch the first 2 emps from each department to join the company.
select * from (
	select e.*,
	row_number() over(partition by deptno order by sal desc) as rn
	from emp e) x
where x.rn < 3;


-- Fetch the top 3 emps in each department earning the max sal.
select * from (
	select e.*,
	rank() over(partition by deptno order by sal desc) as rnk
	from emp e) x
where x.rnk < 4;


-- Checking the different between rank, dense_rnk and row_number window functions:
select e.*,
rank() over(partition by deptno order by sal desc) as rnk,
dense_rank() over(partition by deptno order by sal desc) as dense_rnk,
row_number() over(partition by deptno order by sal desc) as rn
from emp e;



-- lead and lag

-- fetch a query to display if the sal of an emp is higher, lower or equal to the previous emp.
select e.*,
lag(sal) over(partition by deptno order by empno) as prev_empl_sal,
case when e.sal > lag(sal) over(partition by deptno order by empno) then 'Higher than previous emp'
     when e.sal < lag(sal) over(partition by deptno order by empno) then 'Lower than previous emp'
	 when e.sal = lag(sal) over(partition by deptno order by empno) then 'Same than previous emp' end as sal_range
from emp e;

-- Similarly using lead function to see how it is different from lag.
select e.*,
lag(sal) over(partition by deptno order by empno) as prev_empl_sal,
lead(sal) over(partition by deptno order by empno) as next_empl_sal
from emp e;


select *,
FIRST_VALUE(PRODUCT_NAME) OVER (PARTITION BY PRODUCT_CATEGORY  ORDER BY PRICE DESC) AS EXPENSIVE_PRODUCT,
LAST_VALUE(PRODUCT_NAME) OVER (PARTITION BY PRODUCT_CATEGORY  ORDER BY PRICE DESC) AS CHEAP_PRODUCT
from product;

select *,
FIRST_VALUE(PRODUCT_NAME) OVER (PARTITION BY PRODUCT_CATEGORY  ORDER BY PRICE DESC) AS EXPENSIVE_PRODUCT,
LAST_VALUE(PRODUCT_NAME) OVER (PARTITION BY PRODUCT_CATEGORY 
ORDER BY PRICE DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS CHEAP_PRODUCT
from product;

SELECT P.*,
       FIRST_VALUE(PRODUCT_NAME) OVER W  AS EXPENSIVE_PRODUCT,
       LAST_VALUE(PRODUCT_NAME) OVER W   AS CHEAP_PRODUCT
FROM product P
WINDOW W AS (
  PARTITION BY PRODUCT_CATEGORY
  ORDER BY PRICE DESC
  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
);


SELECT
  p.*,
  FIRST_VALUE(PRODUCT_NAME) OVER (
    PARTITION BY PRODUCT_CATEGORY
    ORDER BY PRICE DESC, PRODUCT_NAME
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS EXPENSIVE_PRODUCT,
  LAST_VALUE(PRODUCT_NAME) OVER (
    PARTITION BY PRODUCT_CATEGORY
    ORDER BY PRICE DESC, PRODUCT_NAME
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS CHEAP_PRODUCT
FROM product p;

SELECT
  p.*,
  MAX_BY(PRODUCT_NAME, PRICE) OVER (PARTITION BY PRODUCT_CATEGORY) AS EXPENSIVE_PRODUCT,
  MIN_BY(PRODUCT_NAME, PRICE) OVER (PARTITION BY PRODUCT_CATEGORY) AS CHEAP_PRODUCT
FROM product p;

SELECT
  p.*,
  NTH_VALUE(PRODUCT_NAME,2) OVER (
    PARTITION BY PRODUCT_CATEGORY
    ORDER BY PRICE DESC, PRODUCT_NAME
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS SECOND_HIGHEST_PRODUCT
FROM product p;

SELECT *,
ntile(3) over (order by price desc)  as buckets
FROM PRODUCT
WHERE PRODUCT_CATEGORY='Phone';


select product_name,
case when x.buckets =1 then 'expensive phones'
     when x.buckets =2 then 'med range phones'
     when x.buckets =3 then 'cheaper range phones' end as phone_category
from (
SELECT *,
ntile(3) over (order by price desc)  as buckets
FROM PRODUCT
WHERE PRODUCT_CATEGORY='Phone') x ;
