declare
  cnt number;
  num number;
begin
  cnt := 0;
  for cnt in 1..5 loop
    num := cnt*4;
    dbms_output.put_line('result for '||num||'^2='||num*num);
  end loop;
end;
