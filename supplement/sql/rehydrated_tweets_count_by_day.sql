select date_trunc('day', created_at) "day", count(*)
into temporary table result
from lv2_rehydrated_tweets
group by "day"
order by "day"
;

\copy (select * from result) to stdin with csv header
