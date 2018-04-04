select features#>>'{languages,0}' lang, count(*)
into temporary table result
from tweet where collection = 'lv2' and features#>>'{languages,0}' in ('en', 'lv', 'ru')
group by lang
order by lang
;

\copy (select * from result) to stdin with csv header
