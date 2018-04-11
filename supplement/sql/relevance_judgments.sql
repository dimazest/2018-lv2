drop materialized view if exists lv2_relevance_judgments;

create materialized view lv2_relevance_judgments as
select j.eval_topic_rts_id topic_id, j.tweet_id, judgment, missing
from lv2_rehydrated_tweets
join eval_relevance_judgment j using(collection, tweet_id)
where collection = 'lv2'
order by eval_topic_rts_id, missing, judgment desc, tweet_id
;

\copy (select * from lv2_relevance_judgments) to stdout with csv header
