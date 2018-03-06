select min(ord.odate) as odate,sal.sname from ord, sal where sal.snum = ord.snum group by sal.sname order by sal.sname desc;
