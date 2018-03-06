rollback;
delete from resort where mod(rid, 2) = 0;
commit;
