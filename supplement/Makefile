PSQL = psql -d twitter -eXq

default: queries counts.txt

%.csv: sql/%.sql
	${PSQL} -f $< -o $@

sql/rehydrated_tweets.sql: sql/collected_tweets.sql
sql/rehydrated_tweets_%.sql: sql/rehydrated_tweets.sql

queries: $(patsubst sql/%.sql,%.csv,$(wildcard sql/*.sql))

counts.txt: collected_tweets.csv rehydrated_tweets.csv
	wc -l $^ > $@

.PHONY: queries


