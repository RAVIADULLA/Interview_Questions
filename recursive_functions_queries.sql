-----------Recursive SQL concepts

--syntax

with [recursive] CTE_name as 
     (
     select query (non recursive query or the base query)
     union [all]
     select query (recursive query using CTE_name [with a termination condition])
     )
select * from CTE_name;

--q1 : Display number from 1 to 10 without using any in built functions
--q2 : find the hierarchy of employees under a given number
--q3 : Find the hierarchy of managers for given employee

with recursive numbers as 
    (select 1 as n 
    union all
    select n + 1 from numbers where n < 10)
select * from numbers;

-- select seq4() + 1 as n from table (generator(rowcount => 10))

with recursive emp_hierarchy as 
       (select empno,ename,mgr,job, 1 AS LVL
       from emp_before_update where ename = 'KING'
       union all
       select E.empno,E.ename,E.mgr,E.job,H.LVL+1 AS LVL
       from emp_hierarchy H join emp_before_update E on H.EMPNO=E.MGR
       )
SELECT h2.empno as empno, h2.ename as emp_name, e2.ename as manager_name, h2.lvl as level
FROM emp_hierarchy h2 join emp_before_update e2 on e2.empno = h2.mgr;
