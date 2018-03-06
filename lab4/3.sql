declare
  cnt number;
  total_amt number(7, 2);
  pdate date;
begin
  cnt := 0;
  total_amt := 0;
  pdate := to_date('03.01.2010', 'DD.MM.YYYY');
  for v_amt in (select amt from ord where odate > pdate) loop
    cnt := cnt + 1;
    total_amt := total_amt + v_amt.amt; 
  end loop;
  if (cnt = 0 ) then cnt := 1; end if;
  dbms_output.put_line(
    'Аverage order value after '||
      to_char(pdate, 'DD.MM.YYYY')||
      ': '||total_amt/cnt
  );
end;
