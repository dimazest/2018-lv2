PSQL = psql -d twitter -eXq

default: queries counts.txt

sql/rehydrated_tweets.sql: sql/collected_tweets.sql
sql/rehydrated_tweets_*.sql: sql/rehydrated_tweets.sql
sql/insert_*.sql: sql/collected_tweets.sql
sql/relevance_judgments.sql: sql/rehydrated_tweets.sql
relevance_judgments_*.sql: sql/rehydrated_tweets.sql

rehydrated_tweets.csv: collected_tweets.csv
rehydrated_tweets_*.csv: rehydrated_tweets.csv
insert_*.csv: collected_tweets.csv
relevance_judgments_*.csv: relevance_judgments.csv 


%.csv: sql/%.sql
	${PSQL} -f $< -o $@


queries: $(patsubst sql/%.sql,%.csv,$(wildcard sql/*.sql))

counts.txt: collected_tweets.csv rehydrated_tweets.csv
	wc -l $^ > $@

.PHONY: queries default


