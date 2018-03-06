update resort set rname = 'Oasis Travel' where rid = (select max(rid) from resort);
update resort set rtours = rtours*2 where rid = (select min(rid) from resort);
commit;
