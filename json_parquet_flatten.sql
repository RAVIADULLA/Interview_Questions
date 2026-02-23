--import file.json file and created below table

SELECT * FROM "DATABASE_RAVIADULLA"."SCHEMA_RAVIADULLA"."FIRST_JASON";

describe table FIRST_JASON;

select * from FIRST_JASON;

select c1:accountStatus from FIRST_JASON;

select 
c1:accountStatus:createdAt,
c1:accountStatus:createdAt as create_date,
c1:accountStatus:createdAt::date as create_date,
c1:accountStatus:isActive,
c1:accountStatus:isActive::string as isActive,
c1:accountStatus:lastLogin
from FIRST_JASON;

SELECT
C1:activityLogs,
a1.value:activity,
a1.value:activity::string as activity,
a1.value:timestamp::timestamp as timestamp_value
FROM
"DATABASE_RAVIADULLA"."SCHEMA_RAVIADULLA"."FIRST_JASON",
table (flatten (C1:activityLogs)) a1  -- if we have another object in the object we can use one more flatten (multiline)

--[] -- array
--{} -- object
-- within object key name and value pair are available


SELECT
C1:accountStatus:createdAt::date as createdate, 
C1:accountStatus:isActive::string as status,
C1:accountStatus:lastLogin::string as lastLogin,
--a1.value,
C1:email::string as email,
C1:preferences:language::string as language_file,
C1:preferences:notifications:sms::string as sms
FROM
"DATABASE_RAVIADULLA"."SCHEMA_RAVIADULLA"."FIRST_JASON", table (flatten (C1:activityLogs:activity)) a1


select * from DATABASE_RAVIADULLA.SCHEMA_RAVIADULLA.MTCARS  -- binary format

select 
VARIANT_COL:am::string as am,
VARIANT_COL:carb::string as carb,
VARIANT_COL:disp::string as disp,
VARIANT_COL:model::string as model
from DATABASE_RAVIADULLA.SCHEMA_RAVIADULLA.MTCARS

