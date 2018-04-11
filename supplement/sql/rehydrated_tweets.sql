begin;

drop materialized view if exists lv2_relevance_judgments;
drop materialized view if exists lv2_lang_usage;
drop materialized view if exists lv2_rehydrated_tweets;

create materialized view lv2_rehydrated_tweets  as
select *
from tweet
where
    collection = 'lv2'
and hydrated_at = (select max(hydrated_at) from tweet where collection = 'lv2')
and created_at >= '2017-04-15'
and not features->'country_codes' ? 'SE'
;

create index on lv2_rehydrated_tweets (tweet_id) where collection = 'lv2';

commit;

\copy (select tweet_id from lv2_rehydrated_tweets) to stdout
