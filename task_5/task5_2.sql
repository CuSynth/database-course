-- 5.1 another thread
begin;
update B set data = 't_2_3' where id = 3;
SELECT pg_sleep(10);
update A set data = 't_2_4' where id = 4;
commit;



























