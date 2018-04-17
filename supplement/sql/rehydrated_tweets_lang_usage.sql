begin;

drop materialized view if exists lv2_lang_usage;

create materialized view lv2_lang_usage as
with _ as (
  select
    (features#>>'{user_info,screen_name_id}')::bigint screen_name_id,
    features#>>'{languages,0}' lang
  from lv2_rehydrated_tweets
  --where features#>>'{filter,source}' not like '%Foursquare%'
),
__ as (
  select
    distinct (screen_name_id)
    screen_name_id,
    count(nullif(lang='lv', false)) over sn as lv,
    count(nullif(lang='ru', false)) over sn as ru,
    count(nullif(lang='en', false)) over sn as en,
    count(*) over sn as total
  from _
  window sn as (partition by screen_name_id order by screen_name_id)
  order by total desc
)
select row_number() over () rnum, *
from __
where total >= 100
;

create index on lv2_lang_usage (screen_name_id);

commit;

\copy (select rnum, lv, ru, en, total from lv2_lang_usage) to stdin with csv header
