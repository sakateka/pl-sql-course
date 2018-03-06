declare
  cursor c_cust(p_city varchar2) is
    select cname from cust where city=p_city;
  v_city cust.cname%TYPE;
begin
  v_city := 'Rome';
  for v_cust in c_cust(v_city) loop
    dbms_output.put_line(v_cust.cname);
  end loop;
end;
