select onum, amt, cust.cname from ord, cust where ord.cnum = cust.cnum and cust.city in ('San Jose', 'Barcelona')
