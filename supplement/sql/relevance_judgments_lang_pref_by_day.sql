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
),
___ as (
  select day, topic_id, tweet_lang, lv / N r_lv, ru / N r_ru, en / N r_en
  from __
  --where N > 0
),
_4 as (
  select
    "day", topic_id,
    count(*) tweets_total,
    count(nullif(tweet_lang in ('lv', 'ru', 'en'), false)) tweets_lv_ru_en,
    count(nullif(tweet_lang = 'lv', false)) tweets_lv,
    count(nullif(tweet_lang = 'ru', false)) tweets_ru,
    count(nullif(tweet_lang = 'en', false)) tweets_en,
    avg(r_lv)::decimal(3,2) users_lv,
    avg(r_ru)::decimal(3,2) users_ru,
    avg(r_en)::decimal(3,2) users_en
  from ___
  group by topic_id, "day" 
  order by topic_id, "day"
),
_5 as (
  select "day", topic_id, tweets_total, tweets_lv_ru_en,
  tweets_lv, tweets_ru, tweets_en, (tweets_lv + tweets_ru + tweets_en + 0.0001) t_N,
  users_lv, users_ru, users_en
  from _4
)
select
  "day", topic_id,
  tweets_total, tweets_lv_ru_en,
  (tweets_lv / t_N)::decimal(3,2) tweets_lv,
  (tweets_ru / t_N)::decimal(3,2) tweets_ru,
  (tweets_en / t_N)::decimal(3,2) tweets_en,
  users_lv, users_ru, users_en
into temporary table result
from _5
;
\copy (select * from result) to stdout with csv header
