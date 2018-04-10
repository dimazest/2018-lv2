PSQL = psql -d twitter -eXq

default: queries counts.txt

rehydrated_tweets.csv: collected_tweets.csv
rehydrated_tweets_%.csv: rehydrated_tweets.csv
insert_%.csv: collected_tweets.csv

%.csv: sql/%.sql
	${PSQL} -f $< -o $@


queries: $(patsubst sql/%.sql,%.csv,$(wildcard sql/*.sql))

counts.txt: collected_tweets.csv rehydrated_tweets.csv
	wc -l $^ > $@

.PHONY: queries default


