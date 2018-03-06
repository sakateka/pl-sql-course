declare
  total_amt number;
  pdate date;
begin
  total_amt := 0;
  pdate := to_date('03.01.2010', 'DD.MM.YYYY');
  select amt into total_amt from ord where odate > pdate;
  dbms_output.put_line(
    'SUM order value after '||
      to_char(pdate, 'DD.MM.YYYY')||
      ': '||total_amt
  );
exception
  when OTHERS then
      dbms_output.put_line(SQLCODE||': '||SQLERRM);
end;
