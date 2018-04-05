begin;

drop materialized view if exists lv2_rehydrated_tweets
;

create materialized view lv2_rehydrated_tweets  as
select *
from tweet
where
    collection = 'lv2'
and hydrated_at = (select max(hydrated_at) from tweet where collection = 'lv2')
and not features->'country_codes' ? 'SE'
;

commit;

\copy (select tweet_id from lv2_rehydrated_tweets) to stdout
