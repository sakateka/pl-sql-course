create or replace package my_package as
  function str_len_sum(left in varchar2, right in varchar2)
    return number;
end;
/

create or replace package body my_package as
  function str_len_sum(left in varchar2, right in varchar2)
    return number as
  begin
    return length(left) + length(right);
  end str_len_sum;
end;
/

begin
  dbms_output.put_line(my_package.str_len_sum('aaa', 'bbb'));
end;
