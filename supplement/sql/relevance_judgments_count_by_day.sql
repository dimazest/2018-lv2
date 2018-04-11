select
  topic_id,
  date_trunc('day', created_at) "day",
  count(*)
into temporary table result
from lv2_relevance_judgments j
join lv2_rehydrated_tweets t on j.tweet_id = t.tweet_id 
where not missing and judgment > 0 and t.collection = 'lv2'
group by topic_id, "day" 
order by topic_id, "day"
;
\copy (select * from result) to stdout with csv header
