select
  date_trunc('day', created_at) "day",
  features#>>'{languages,0}' lang,
  count(*)
into temporary table result
from lv2_rehydrated_tweets
group by "day", lang
order by "day", count(*), lang
;

\copy (select * from result) to stdin with csv header
