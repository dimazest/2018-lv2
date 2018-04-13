with _ as (
  select
    date_trunc('day', created_at) "day",
    topic_id,
    (t.features#>>'{user_info,screen_name_id}')::bigint screen_name_id,
    t.features#>>'{languages,0}' tweet_lang
  from lv2_relevance_judgments j
  join lv2_rehydrated_tweets t on j.tweet_id = t.tweet_id 
  where not missing and judgment > 0 and t.collection = 'lv2'
),
__ as (
  select day, topic_id, tweet_lang, u.lv, u.ru, u.en, (u.lv + u.ru + u.en)::float N
  from _
  join lv2_lang_usage u using (screen_name_id)
)
select 
  day, topic_id, tweet_lang, 
  (lv / N)::decimal(3,2) r_lv,
  (ru / N)::decimal(3,2) r_ru, 
  (en / N)::decimal(3,2) r_en
into temporary table result
from __
;
\copy (select * from result) to stdout with csv header
