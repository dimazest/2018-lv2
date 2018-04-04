\copy (select tweet_id from tweet where collection = 'lv2' order by tweet_id) to stdout
