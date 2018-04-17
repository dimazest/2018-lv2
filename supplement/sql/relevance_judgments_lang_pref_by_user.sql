with _ as(
  select
    topic_id,
    (features#>>'{user_info,screen_name_id}')::bigint screen_name_id,
    t.features#>>'{languages,0}' tweet_lang
  from lv2_relevance_judgments j
  join lv2_rehydrated_tweets t using (tweet_id)
  where
      j.judgment > 0
  and t.features#>>'{languages,0}' in ('lv', 'ru', 'en')
),
__ as (
  select
   distinct on (rnum, topic_id, lv, ru, en, total)
   topic_id, rnum,
   lv u_lv, ru u_ru, en u_en, total u_total,
   count(nullif(tweet_lang='lv', false)) over topic_sn t_lv,
   count(nullif(tweet_lang='ru', false)) over topic_sn t_ru,
   count(nullif(tweet_lang='en', false)) over topic_sn t_en,
   count(*) over topic_sn t_total
  from _
  join lv2_lang_usage u using (screen_name_id)
  window topic_sn as (partition by topic_id, screen_name_id order by topic_id, screen_name_id)
 order by topic_id, rnum
)
select *
into temporary table result
from __
;
\copy (select * from result) to stdout with csv header
