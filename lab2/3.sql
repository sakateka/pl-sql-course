select cust.*, ord.* from cust, ord where cust.cname in (select cname from  (select cname from cust order by cname desc) where rownum < 3) and cust.cnum = ord.cnum
