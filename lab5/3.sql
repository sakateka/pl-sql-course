create sequence sq_log;

create table cust_log(
  logid number(4) not null,
  cname varchar2(10) not null,
  old_city varchar2(10) not null,
  new_city varchar2(10) not null,
  constraint cust_log_id primary key (logid)
);


create or replace trigger log_cust_city_update
before update of city on cust
for each row
begin
  insert into cust_log (logid, cname, old_city, new_city)
  values(sq_log.nextval, :old.cname, :old.city, :new.city);
end log_cust_city_update;
/

update cust set city='Peking' where cnum = 2001;
select * from cust_log;
