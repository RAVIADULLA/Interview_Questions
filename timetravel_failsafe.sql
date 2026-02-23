--- Time Travel

select  current_timestamp();  -- 2025-08-24 18:10:50.203 +0000RAW.GIT

select * from emp;

update emp set sal = 1000 where empno=7369

select  current_timestamp();  --2025-08-24 18:10:18.498 +0000 ,query id = 01be96c7-0002-9263-0002-62df0005b38a

select * from emp;

select * from emp before (timestamp => '2025-08-24 18:10:18.498'::timestamp );
select * from emp before (statement => '01be96c5-0002-9263-0002-62df0005b376' )
select * from emp before (offset => -60*10 )

select * from emp at (timestamp => '2025-08-24 18:10:18.498'::timestamp );
select * from emp at (statement => '01be96c5-0002-9263-0002-62df0005b376' )
select * from emp at (offset => -60*10 )


drop table emp;
undrop table emp;

drop schema SCHEMA_RAVIADULLA;
undrop schema SCHEMA_RAVIADULLA;


----Cloning

create table emp_bkp as select * from emp;

select * from emp;
select * from emp_bkp;

update emp set sal=800 where empno = 7369;

select * from emp;
select * from emp_bkp;

select * from DATABASE_RAVIADULLA.INFORMATION_SCHEMA.TABLE_STORAGE_METRICS
where table_catalog='DATABASE_RAVIADULLA' and table_schema='SCHEMA_RAVIADULLA' ;

create table emp_before_update clone emp before (statement => '01be96c5-0002-9263-0002-62df0005b376' );

select * from emp_before_update;

show parameters for account; --DATA_RETENTION_TIME_IN_DAYS

alter account set DATA_RETENTION_TIME_IN_DAYS = 90; -- enterprice edition

show parameters for database database_raviadulla;

alter database database_raviadulla set DATA_RETENTION_TIME_IN_DAYS = 10; 

alter table emp set DATA_RETENTION_TIME_IN_DAYS = '10';

show parameters for table emp;

create table table_1 (id number) DATA_RETENTION_TIME_IN_DAYS = 10;


drop table table_1;

undrop table table_1; -- we can undrop till 10 based retention time

show parameters for table table_1;

--Fail Safe
--  if you want to restore after retention time, we should contact for snowflake admin for fail save.

-- Type of tables

--permanent(standard) -- defualt time travel -1 and max time travel -1, min tt is 0 
--permanent (Enterprice and above) -- fail safe 7 days--defualt time travel -1 and max time travel -90 , 
--transient -- will not have fail safe --defualt time travel -1 and max time travel -1, min tt is 0
--temporary -- session specific --defualt time travel -1 and max time travel -1, min tt is 0 

create or replace table table_2 (id int) DATA_RETENTION_TIME_IN_DAYS = 0;

undrop table table_2; -- as retention is 0 days, we can not restore by time travel method, it we can get done by using fail safe as it is enterprice accout before next 7 days.

create transient table table_3 (id int) DATA_RETENTION_TIME_IN_DAYS = 2; -- min only 1 day is available in transient tables

create transient table table_3 (id int) DATA_RETENTION_TIME_IN_DAYS = 1;








