CREATE or replace TABLE emp (
  empno decimal(4,0) NOT NULL,
  ename varchar(10) default NULL,
  job varchar(9) default NULL,
  mgr decimal(4,0) default NULL,
  hiredate date default NULL,
  sal decimal(7,2) default NULL,
  comm decimal(7,2) default NULL,
  deptno decimal(2,0) default NULL
);

INSERT INTO emp VALUES ('7369','SMITH','CLERK','7902','1980-12-17','800.00',NULL,'20');
INSERT INTO emp VALUES ('7499','ALLEN','SALESMAN','7698','1981-02-20','1600.00','300.00','30');
INSERT INTO emp VALUES ('7521','WARD','SALESMAN','7698','1981-02-22','1250.00','500.00','30');
INSERT INTO emp VALUES ('7566','JONES','MANAGER','7839','1981-04-02','2975.00',NULL,'20');
INSERT INTO emp VALUES ('7654','MARTIN','SALESMAN','7698','1981-09-28','1250.00','1400.00','30');
INSERT INTO emp VALUES ('7698','BLAKE','MANAGER','7839','1981-05-01','2850.00',NULL,'30');
INSERT INTO emp VALUES ('7782','CLARK','MANAGER','7839','1981-06-09','2450.00',NULL,'10');
INSERT INTO emp VALUES ('7788','SCOTT','ANALYST','7566','1982-12-09','3000.00',NULL,'20');
INSERT INTO emp VALUES ('7839','KING','PRESIDENT',NULL,'1981-11-17','5000.00',NULL,'10');
INSERT INTO emp VALUES ('7844','TURNER','SALESMAN','7698','1981-09-08','1500.00','0.00','30');
INSERT INTO emp VALUES ('7876','ADAMS','CLERK','7788','1983-01-12','1100.00',NULL,'20');
INSERT INTO emp VALUES ('7900','JAMES','CLERK','7698','1981-12-03','950.00',NULL,'30');
INSERT INTO emp VALUES ('7902','FORD','ANALYST','7566','1981-12-03','3000.00',NULL,'20');
INSERT INTO emp VALUES ('7934','MILLER','CLERK','7782','1982-01-23','1300.00',NULL,'10');

create or replace table dept(   
  deptno     number(2,0),   
  dname      varchar2(14),   
  loc        varchar2(13),   
  constraint pk_dept primary key (deptno)   
);

insert into dept
values(10, 'ACCOUNTING', 'NEW YORK');
insert into dept
values(20, 'RESEARCH', 'DALLAS');
insert into dept
values(30, 'SALES', 'CHICAGO');
insert into dept
values(40, 'OPERATIONS', 'BOSTON');

select * from dept;

create table table2(id number);

create table table1(id number);
insert into table1 (id) values (null);

select * from table1

select * from table2

select a.id
from table1 a  join table2 b on a.id=b.id

select a.id
from table1 a left outer join table2 b on a.id=b.id

select a.id
from table1 a right outer join table2 b on a.id=b.id

select a.id
from table1 a full outer join table2 b on a.id=b.id

select
  CURRENT_USER ();

  select * from emp;

  select max(sal),b.deptno from emp b group by b.deptno;

  select a.* from emp a
  where sal in (select distinct(max(sal)) from emp b
            where b.deptno=a.deptno group by b.deptno);


select max(sal)
from emp a where sal < (select max(sal) from emp)

with cte as (
select ename,empno,deptno,sal,rank() over (partition by deptno order by sal desc) r from emp
) 
select * from cte where r=1

select * from (
select ename,empno,deptno,sal,rank() over (partition by deptno order by sal desc) r from emp
) a
 where r=1

select * from (
select ename,empno,deptno,sal,row_number() over (partition by deptno order by sal desc) r from emp
) a
qualify r=1


select level as num
from dual
connect by level <=10;

CREATE TABLE development.training.dual(DUMMY VARCHAR2(1));

insert into dual (dummy) values ('X');

select * from development.training.dual;

SELECT
  LEVEL AS num
FROM
  DUAL CONNECT BY LEVEL <= 10;

  SELECT LEVEL AS num
FROM dual
CONNECT BY PRIOR LEVEL  <= 10;

select ename,prior.ename as manager_name
from emp where ename !='KING'
start with mgr is null
connect by prior empno=mgr;

SELECT 
    ename AS employee_name,
    CONNECT_BY_ROOT ename AS top_manager,
    CONNECT_BY_PATH(ename, ' -> ') AS path
FROM emp
START WITH mgr IS NULL
CONNECT BY PRIOR empno = mgr;

SELECT 
    child.ename AS employee_name,
    parent.ename AS manager_name,
    CONNECT_BY_PATH(child.ename, ' -> ') AS path
FROM emp child
LEFT JOIN emp parent 
    ON child.mgr = parent.empno
START WITH child.mgr IS NULL
CONNECT BY PRIOR child.empno = child.mgr;

SELECT 
    empno,
    ename,
    LEVEL
FROM emp
START WITH mgr IS NULL
CONNECT BY PRIOR empno = mgr;

