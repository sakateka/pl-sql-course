create or replace package my_package as
  function str_len_sum(left in varchar2, right in varchar2)
    return number;

  procedure orders_by_last_n_city(num in number); 
end;
/

create or replace package body my_package as
  function str_len_sum(left in varchar2, right in varchar2)
    return number as
  begin
    return length(left) + length(right);
  end str_len_sum;
  
  procedure orders_by_last_n_city(num in number) as
    cnt number;
  begin
    select count(city) into cnt from (select city from cust group by city);
    for v_city in (select city from cust group by city order by city) loop
      if (cnt <= num) then
        for v_cust in (select * from cust where cust.city = v_city.city) loop
          dbms_output.put_line(
            'Покупатель '||v_cust.cname||' из '||v_cust.city||' rating='||v_cust.rating||' заказывал:');
          for v_ord in (select * from ord where v_cust.cnum = ord.cnum) loop
            dbms_output.put_line('    '||v_ord.onum||' '||v_ord.odate||' стоимость '||v_ord.amt);
          end loop;
        end loop; 
      end if;
      cnt := cnt - 1;
    end loop;
  end orders_by_last_n_city;
end;
/

begin
  my_package.orders_by_last_n_city(3);
end;
