/* Write an SQL query to display the correct message (meaningful message) from the input
comments_and_translation table. */

select * from comments_and_translations;

select comment,
case when translation is null 
          then comment
    else translation 
end as output
from comments_and_translations;

select coalesce(translation,comment)
from comments_and_translations;

-------------------------------------------------------------------------------------------------------------
select * from source;
select * from target;

select 
coalesce(s.id,t.id) as id,
case when s.id is null then 'New in Target'
     when t.id is null then 'New in Source'
     when s.name <> t.name then 'Mismatch'
     end  as Comment
from
source s  
full outer join target t on s.id = t.ID 
where s.id is null
or t.id  is null
or s.name <> t.name
order by s.id
------------------------------------------------------------------------------------------------------------------
select coalesce(s.id, t.id) as id, 
case when t.id is null then 'New in source'
when s.id is null then 'New in target'
when s.name <> t.name then 'Mismatch' end as comment
from source s full join target t on s.id = t.id 
where (s.id is null or t.id is null) or s.name <> t.name;
---------------------------------------------------------------------------------------------------------
select s.id, 'Mismatch' as comment
from source s join target t on s.id = t.id and s.name<>t.NAME
union
select s.id, 'New in Source' as comment
from source s 
left outer join target t on s.id = t.id where t.id is null
union
select t.id, 'New in Target' as comment
from source s 
right outer join target t on s.id = t.id where s.id is null;
----------------------------------------------------------------------------------------------------------
select
Coalesce(s.id,t.id) as ID,
case when s.id is null then 'New in Target'
when t.id is null then 'New in Source'
when S.Name <>t.Name then 'Mismatch'
else 'Matched'
end as Comments
from source s
FULL JOIN target t on s.id=t.id
where case when s.id is null then 'New in Target'
when t.id is null then 'New in Source'
when S.Name <>t.Name then 'Mismatch'
else 'Matched'
end <>'Matched';
------------------------------------------------------------------------------------------------------
--2nd query
SELECT
nvl(s.id, t.id) id,
CASE
WHEN s.name IS NULL THEN
'NEW IN TARGET'
WHEN s.name != t.name THEN
'MISMATCH'
WHEN t.id IS NULL
AND t.name IS NULL THEN
'NEW ENTRANT'
END as comments

--,S.NAME , T.ID, T.NAME
FROM
source s
FULL JOIN target t ON s.id = nvl(t.id, s.id)
WHERE
nvl(s.name, 'x') <> nvl(t.name, 'y');
---------------------------------------------------------------------------------------------------------------------

select * from teams;

with matches as 
        (select row_number() over (order by team_name) as id,
            team_code, team_name
        from teams)
select team.team_name,opponent.team_name
from matches team
join matches  opponent on team.id < opponent.id
order by team.team_name

with matches as 
        (select row_number() over (order by team_name) as id,
            team_code, team_name
        from teams)
select team.team_name,opponent.team_name
from matches team
join matches  opponent on team.id <> opponent.id
order by team.team_name;
--------------------------------------------------------------------------------------------------------------------------------

select * from OLYMPICS_HISTORY;
select * from OLYMPICS_HISTORY_NOC_REGIONS;

with t1 as 
    (select count(distinct games) as total_summer_games
    from OLYMPICS_HISTORY where season='Summer'),
t2 as
    (select distinct sport,games
    from OLYMPICS_HISTORY where season='Summer' order by games),
t3 as 
    (select sport,count(games) as no_of_games
    from t2 group by sport)
select * 
from t3
join t1 on t1.total_summer_games = t3.no_of_games

---------------------------------------------------------------------------------------------------------------------------------
with t1 as 
(select name, count(1) as total_medals
from OLYMPICS_HISTORY where medal='Gold'
group by name
order by count(1)  desc),
t2 as 
(select *,
dense_rank () over (order by total_medals desc) rnk
from t1 )
select * from t2 
where rnk <= 5
----------------------------------------------------------------------------------------------------------------

select * from OLYMPICS_HISTORY_NOC_REGIONS;

select nr.region as country,medal, count(1) as total_medals
from OLYMPICS_HISTORY oh join OLYMPICS_HISTORY_NOC_REGIONS nr on oh.noc = nr.noc
where medal <> 'NA'
group by nr.region,medal
order by nr.region, medal ;

----------------------------------------------------------------------------------------------------------------------

--Mention the total no of nations who participated in each olympics game?
            with all_countries as
        (select games, nr.region
        from olympics_history oh
        join olympics_history_noc_regions nr ON nr.noc = oh.noc
        group by games, nr.region)
    select games, count(1) as total_countries
    from all_countries
    group by games
    order by games;
------------------------------------------------------------------------------------------------------------------------
--Which year saw the highest and lowest no of countries participating in olympics
     with all_countries as
              (select games, nr.region
              from olympics_history oh
              join olympics_history_noc_regions nr ON nr.noc=oh.noc
              group by games, nr.region),
          tot_countries as
              (select games, count(1) as total_countries
              from all_countries
              group by games)
      select distinct
      concat(first_value(games) over(order by total_countries)
      , ' - '
      , first_value(total_countries) over(order by total_countries)) as Lowest_Countries,
      concat(first_value(games) over(order by total_countries desc)
      , ' - '
      , first_value(total_countries) over(order by total_countries desc)) as Highest_Countries
      from tot_countries
      order by 1;
--------------------------------------------------------------------------------------------------------------------------
--Which nation has participated in all of the olympic games
with tot_games as
      (select count(distinct games) as total_games
      from olympics_history),
  countries as
      (select games, nr.region as country
      from olympics_history oh
      join olympics_history_noc_regions nr ON nr.noc=oh.noc
      group by games, nr.region),
  countries_participated as
      (select country, count(1) as total_participated_games
      from countries
      group by country)
select cp.*
from countries_participated cp
join tot_games tg on tg.total_games = cp.total_participated_games
order by 1;
---------------------------------------------------------------------------------------------------------------------
--Identify the sport which was played in all summer olympics.
with t1 as
    (select count(distinct games) as total_games
    from olympics_history where season = 'Summer'),
  t2 as
    (select distinct games, sport
    from olympics_history where season = 'Summer'),
  t3 as
    (select sport, count(1) as no_of_games
    from t2
    group by sport)
select *
from t3
join t1 on t1.total_games = t3.no_of_games;
------------------------------------------------------------------------------------------------------------------------
--Which Sports were just played only once in the olympics.
with t1 as
    (select distinct games, sport
    from olympics_history),
  t2 as
    (select sport, count(1) as no_of_games
    from t1
    group by sport)
select t2.*, t1.games
from t2
join t1 on t1.sport = t2.sport
where t2.no_of_games = 1
order by t1.sport;
-----------------------------------------------------------------------------------------------------
--Fetch the total no of sports played in each olympic games.
      with t1 as
      	(select distinct games, sport
      	from olympics_history),
        t2 as
      	(select games, count(1) as no_of_sports
      	from t1
      	group by games)
      select * from t2
      order by no_of_sports desc;
-------------------------------------------------------------------------------------------------------
--9. Fetch oldest athletes to win a gold medal
with temp as
    (select name,sex,cast(case when age = 'NA' then '0' else age end as int) as age
      ,team,games,city,sport, event, medal
    from olympics_history),
ranking as
    (select *, rank() over(order by age desc) as rnk
    from temp
    where medal='Gold')
select *
from ranking
where rnk = 1;
----------------------------------------------------------------------------------------------------------
--Top 5 athletes who have won the most gold medals.
    with t1 as
            (select name, team, count(1) as total_gold_medals
            from olympics_history
            where medal = 'Gold'
            group by name, team
            order by total_gold_medals desc),
        t2 as
            (select *, dense_rank() over (order by total_gold_medals desc) as rnk
            from t1)
    select name, team, total_gold_medals
    from t2
    where rnk <= 5;
-----------------------------------------------------------------------------------------------------------
--Top 5 athletes who have won the most medals (gold/silver/bronze).
    with t1 as
            (select name, team, count(1) as total_medals
            from olympics_history
            where medal in ('Gold', 'Silver', 'Bronze')
            group by name, team
            order by total_medals desc),
        t2 as
            (select *, dense_rank() over (order by total_medals desc) as rnk
            from t1)
    select name, team, total_medals
    from t2
    where rnk <= 5;
----------------------------------------------------------------------------------------------------------------
--Top 5 most successful countries in olympics. Success is defined by no of medals won.
with t1 as
        (select nr.region, count(1) as total_medals
        from olympics_history oh
        join olympics_history_noc_regions nr on nr.noc = oh.noc
        where medal <> 'NA'
        group by nr.region
        order by total_medals desc),
    t2 as
    (select *, dense_rank() over(order by total_medals desc) as rnk
        from t1)
select *
from t2
where rnk <= 5;
----------------------------------------------------------------------------------------------------------
--In which Sport/event, India has won highest medals.
    with t1 as
        	(select sport, count(1) as total_medals
        	from olympics_history
        	where medal <> 'NA'
        	and team = 'India'
        	group by sport
        	order by total_medals desc),
        t2 as
        	(select *, rank() over(order by total_medals desc) as rnk
        	from t1)
    select sport, total_medals
    from t2
    where rnk = 1;
-----------------------------------------------------------------------------------------------------------------------------------
--Break down all olympic games where india won medal for Hockey and how many medals in each olympic games
    select team, sport, games, count(1) as total_medals
    from olympics_history
    where medal <> 'NA'
    and team = 'India' and sport = 'Hockey'
    group by team, sport, games
    order by total_medals desc;






