\set RTS_ID LV005
\set SCREEN_NAME @@HOCKEY

create temporary table default_judgments as table eval_relevance_judgment with no data
;

insert into default_judgments
select
  :'RTS_ID' eval_topic_rts_id, 'lv2' collection,  tweet_id,
   1 judgment,
  null "position", false missing, null crowd_relevant, null crowd_not_relevant,
  true from_dev
from tweet
where collection = 'lv2' and (features->'screen_names' ? :'SCREEN_NAME' or features->'user_mentions' ? :'SCREEN_NAME')
order by collection, eval_topic_rts_id, tweet_id
;

insert into eval_relevance_judgment
select * from default_judgments
on conflict do nothing
;

\copy (select eval_topic_rts_id, collection, tweet_id, judgment from default_judgments) to stdout with csv header
