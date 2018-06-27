select 
(features#>>'{user_info,screen_name_id}')::bigint screen_name_id,
count(*)
into temporary table result
from lv2_rehydrated_tweets
group by screen_name_id
order by count desc
;

\copy (select count from result) to stdin with csv header
