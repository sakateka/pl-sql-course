select cust.*, ord.* from cust, ord where cust.cname >= (select max(cname) from (select cname from cust where cname < (select max(cname) from cust))) and cust.cnum = ord.cnum
