drop materialized view if exists lv2_rehydrated_tweets;

create materialized view lv2_rehydrated_tweets  as
select *
from tweet
where
    collection = 'lv2'
and hydrated_at = (select max(hydrated_at) from tweet where collection = 'lv2')
and not (features#>>'{filter,source}' = '<a href="http://foursquare.com" rel="nofollow">Foursquare</a>' and text like 'I''m at %')
and features#>>'{filter,source}' <> '<a href="http://www.endomondo.com" rel="nofollow">Endomondo</a>'
--and features#>>'{filter,source}' <> '<a href="http://twitter.com/WorldCities/cities" rel="nofollow">World Cities</a>'
--and features#>>'{filter,source}' <> '<a href="http://linkis.com" rel="nofollow">Linkis: turn sharing into growth</a>'
and features#>>'{languages,0}' in ('lv', 'ru', 'en');

\copy (select tweet_id from lv2_rehydrated_tweets) to stdout
