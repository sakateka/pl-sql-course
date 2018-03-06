create or replace view cust_rate_above_100_or_london as select * from cust where city = 'London' or rating > 100;
select * from cust_rate_above_100_or_london where rating = 100;
