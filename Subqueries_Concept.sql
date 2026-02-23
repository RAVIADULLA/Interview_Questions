select * from emp  --main query/ outer query
where sal > (select avg(sal) from emp)  -- sub query / inner query;

-- scalar sub query
-- it always returns 1 row and 1 column

select * 
from emp e1 join (select avg(sal)  avg_sal from emp)  e2
on sal > avg_sal 

--multiple row subquery 
    --1. return multiple row and multiple column
    --2. return only 1 column and multiple rows

select * 
from emp a
where (deptno,sal) in (select deptno,max(sal) salary 
                        from emp b 
                        group by deptno)

select *
from dept
where deptno not in (select distinct(deptno) from emp )

-- correlated sub query

select * 
from emp e1
where sal > (select avg(sal) 
              from emp e2
              where e2.deptno = e1.deptno
              )

select *
from dept d
where not exists (select 1 
                        from emp e 
                        where e.deptno = d.deptno)
--- nesteed sub query
select *
from (
select sum(cost) price, store_name
from sales
group by store_name) total_sales
join
(select avg(price) avg_sales
from(
select sum(cost) price, store_name
from sales
group by store_name ) x )  avg_total_sales
where total_sales.price > avg_total_sales.avg_sales

--- with class using

with cte_total_sales as 
    (
    select sum(cost) price, store_name
    from sales
    group by store_name ),
    cte_avg_sales as 
    (
    select avg(price) avg_sales
    from(
    select sum(cost) price, store_name
    from sales
    group by store_name )
    )
select *
from 
cte_total_sales  join cte_avg_sales on price > avg_sales


--- different classes in used in subquery 
-- SELECT
-- FROM
-- WHERE
-- HAVING

--- Using subclass in SELECT class

select *
,(case when sal > (select avg(sal) from emp)
        then 'higher salary'
        else null end ) as remarks
from emp;

--by using cross join

select *
,(case when sal > e2.salary then 'higher salary' else null end ) as remarks
from emp e1 join (select avg(sal) as salary from emp) e2;

----in havig

select store_name,sum(quantity)
from sales
group by store_name
having sum(quantity) > (select avg(quantity) from sales)

--- sql commands which allow subquery
-- insert
-- update
-- delete

--emp history table

select * from emp_history;

insert into emp_history
select e.empno,e.ename,e.job,e.mgr,e.hiredate,e.sal,e.comm,e.deptno
from
emp e join dept d on e.deptno = d.deptno
where not exists (select 1 from emp_history eh where eh.empno= e.empno)

-- update
update emp e set
sal = (select max(sal) + ( max(sal) * 0.1) from emp_history eh where eh.deptno = e.deptno )
where e.deptno in (select deptno from dept where loc = 'Los Angeles')
and e.empno in (select empno from emp_history)

select * from dept

---Delete

delete from dept
where dname in
            (
            select dname
            from dept d
            where not exists (select 1 
                                    from emp e 
                                    where e.deptno = d.deptno)
            )
