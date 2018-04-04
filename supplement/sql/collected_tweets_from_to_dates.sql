\copy (select min(created_at) "From", max(created_at) "To" from tweet where collection = 'lv2') to stdout with csv header
