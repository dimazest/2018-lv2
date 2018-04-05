select
  features#>>'{filter,source}' source,
  count(*) tweet_count,
  to_char(100.0 * count(*) / (select count(*) from lv2_rehydrated_tweets where collection = 'lv2'), '990D0%') as share 
into temporary table top_sources
from lv2_rehydrated_tweets
where collection = 'lv2'
group by source
order by count(*) desc
limit 10
;

select
  s.*,
  t.features#>>'{languages,0}' lang,
  jsonb_array_length(features->'screen_names') > 1 is_tracked
into temporary table _
from lv2_rehydrated_tweets t
right join top_sources s on t.features#>>'{filter,source}' = s.source
where t.collection = 'lv2'
;

select distinct on (tweet_count, source, lang)
  source, tweet_count total_count, share total_share, lang,
  count(*) over source_lang source_lang_count,
  count(*) over source source_count,
  count(nullif(is_tracked, false)) over source_lang tracked_source_lang_count,
  count(nullif(is_tracked, false)) over source tracked_source_count
into temporary table __
from _
where lang in ('lv', 'ru', 'en')
window
  source as (partition by source order by source),
  source_lang as (partition by source, lang order by source, lang)
;

select
  *,
  to_char(100.0 * source_lang_count / total_count, '990D0%') source_lang_share,
  total_count - source_count other_lang_count,
  to_char(100 - 100.0 * source_count / total_count, '990D0%') other_lang_share,
  to_char(100.0 * tracked_source_count / total_count, '990D0%') tracked_source_share,
  to_char(100.0 * tracked_source_lang_count / source_lang_count, '990D0%') tracked_source_lang_share
into temporary table result
from __
order by total_count desc, source, lang
;

\copy (select * from result) to stdout with csv header
