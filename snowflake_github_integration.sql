use role sysadmin;

create database raw;

create schema git;

create warehouse if not exists developer
warehouse_size = xsmall
initially_suspended = true;

use database raw;
use schema git;
use warehouse developer;

use role accountadmin;

create or replace secret github_secret
type = password
username = 'RAVIADULLA'
password = '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';

create or replace api integration git_api_integration
api_provider = git_https_api
api_allowed_prefixes = ('https://github.com/RAVIADULLA')
allowed_authentication_secrets = (github_secret)
enabled = true;

create or replace git repository tutorial
api_integration = git_api_integration
git_credentials = github_secret
origin = 'https://github.com/RAVIADULLA/Snowflake_files';

--show repos added to snowflake
show git repositories;

--show branches in the repo
show git branches in git repository tutorial;

--list files
ls @tutorial/branches/main;

--show code in the file
select $1 from @tutorial/branches/main/jason_parque_queries.sql;




