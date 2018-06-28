select
  j.tweet_id,
  j.topic_id topic1,
  j2.topic_id topic2,
  topic.title title1,
  topic2.title title2
into temporary table result
from lv2_relevance_judgments j
join lv2_rehydrated_tweets t on j.tweet_id = t.tweet_id 
join lv2_relevance_judgments j2 on j.tweet_id = j2.tweet_id
join eval_topic topic on j.topic_id = topic.rts_id
join eval_topic topic2 on j2.topic_id = topic2.rts_id
where
  not j.missing and j.judgment > 0
  and not j2.missing and j2.judgment > 0
  and topic.rts_id <= topic2.rts_id
  and t.collection = 'lv2'
;
\copy (select * from result) to stdout with csv header
