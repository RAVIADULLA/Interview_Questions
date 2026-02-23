create or replace stage emp_dep_files_snowflake;

--internal Named stage
put file://C:/SourceFiles/* @emp_dep_files_snowflake AUTO_COMPRESS=FALSE;

COPY INTO dep_stage
FROM @emp_dep_files_snowflake/dep.csv
FILE_FORMAT=(TYPE=CSV SKIP_HEADER=1 FIELD_OPTIONALLY_ENCLOSED_BY='"')
FORCE = TRUE;

-- user stage
PUT file://C:/SourceFiles/* @~ AUTO_COMPRESS=FALSE;

COPY INTO dep_stage 
FROM @~/dep.csv FILE_FORMAT=(TYPE=CSV SKIP_HEADER=1)
FORCE = TRUE;

LIST @~;

list @~emp_dep_files_snowflake;

describe table dep_stage;

select * from dep_stage;

truncate table dep_stage;

create or replace file format my_csv_fmt
TYPE = CSV
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
NULL_IF = ('','NULL');

COPY INTO dep_stage
FROM @~/dep.csv
FILE_FORMAT=(FORMAT_NAME=my_csv_fmt)
FORCE=TRUE;     -- reprocess same file name


SELECT *
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(TABLE_NAME=>'DEP_STAGE', START_TIME=>DATEADD(hour,-24,CURRENT_TIMESTAMP)));










