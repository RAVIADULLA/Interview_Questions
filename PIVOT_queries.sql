WITH src AS (
  SELECT nr.region AS country, oh.medal
  FROM OLYMPICS_HISTORY oh
  JOIN OLYMPICS_HISTORY_NOC_REGIONS nr ON nr.noc = oh.noc
  WHERE oh.medal IN ('Bronze','Gold','Silver')      -- exclude 'NA'
)
SELECT country,
       COALESCE(bronze, 0) AS bronze,
       COALESCE(gold,   0) AS gold,
       COALESCE(silver, 0) AS silver
FROM src
PIVOT (
  COUNT(medal)                     -- << not COUNT(*)
  FOR medal IN ('Bronze','Gold','Silver')
) AS p (country, bronze, gold, silver)              -- << alias columns here
ORDER BY country;

---------------------------------------------------------------------------------------------------------------------

select * from pivot('select nr.region as country,medal, count(1) as total_medals
                    from OLYMPICS_HISTORY oh join OLYMPICS_HISTORY_NOC_REGIONS nr on oh.noc = nr.noc
                    where medal <> 'NA'
                    group by nr.region,medal
                    order by nr.region, medal ')
              as result (country varchar, bronze bigint, gold bigint, silver bigint);

SELECT nr.region AS country,
       COUNT_IF(oh.medal = 'Bronze') AS bronze,
       COUNT_IF(oh.medal = 'Gold')   AS gold,
       COUNT_IF(oh.medal = 'Silver') AS silver
FROM OLYMPICS_HISTORY oh
JOIN OLYMPICS_HISTORY_NOC_REGIONS nr ON oh.noc = nr.noc
WHERE oh.medal IN ('Bronze','Gold','Silver')
GROUP BY nr.region
ORDER BY country desc;
---------------------------------------------------------------------------------

SELECT country,
       NVL(gold,   0) AS gold,
       NVL(silver, 0) AS silver,
       NVL(bronze, 0) AS bronze
FROM (
        SELECT nr.region AS country,
               oh.medal,
               COUNT(*) AS total_medals
        FROM olympics_history oh
        JOIN olympics_history_noc_regions nr
          ON nr.noc = oh.noc
        WHERE oh.medal <> 'NA'
        GROUP BY nr.region, oh.medal
     )
PIVOT (
        SUM(total_medals)
        FOR medal IN (
            'Gold'   AS gold,
            'Silver' AS silver,
            'Bronze' AS bronze
        )
     )
ORDER BY gold DESC, silver DESC, bronze DESC;

