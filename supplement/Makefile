PSQL = psql -d twitter -Xq -v ON_ERROR_STOP=1

default: queries jsonl_queries counts.txt account_counts.txt topics.json

sql/rehydrated_tweets.sql: sql/collected_tweets.sql
sql/rehydrated_tweets_*.sql: sql/rehydrated_tweets.sql
sql/insert_*.sql: sql/collected_tweets.sql
sql/relevance_judgments.sql: sql/rehydrated_tweets.sql
sql/relevance_judgments_*.sql: sql/rehydrated_tweets.sql
sql/relevance_judgments_lang_pref_by_day.sql: sql/rehydrated_tweets_lang_usage.sql

rehydrated_tweets.csv: collected_tweets.csv
rehydrated_tweets_*.csv: rehydrated_tweets.csv
insert_*.csv: collected_tweets.csv
relevance_judgments_*.csv: relevance_judgments.csv
relevance_judgments_lang_pref_by_day.csv: rehydrated_tweets_lang_usage.csv

%.csv: sql/%.sql
	${PSQL} -f $< -o $@

%.jsonl: sql/%.sql.jsonl
	${PSQL} -f $< | sed -e 's/\\\\/\\/g' > $@

queries: $(patsubst sql/%.sql,%.csv,$(wildcard sql/*.sql))
jsonl_queries: $(patsubst sql/%.sql.jsonl,%.jsonl,$(wildcard sql/*.sql.jsonl))

counts.txt: collected_tweets.csv rehydrated_tweets.csv
	wc -l $^ > $@
account_counts.txt: lv.cfg
	grep -e '^@' $< | wc -l > $@

topics.json.txt:
	curl http://www.fowler.lv/c/lv2/eval/topics.json | jq . > $@


.PHONY: queries default jsonl_queries


