declare
  cnt number;
  cost number;
  amt number;
  mod10 number;
  text varchar2(12);
begin
  cnt := 0;
  cost := 11;
  text := '';
  for cnt in 1..7 loop
    amt := cost * cnt;
    mod10 := amt mod 10;
    if ((amt mod 100) < 21 and amt > 5) then
      -- специальный случай, обрабатывается отдельно
      text := 'рублей';
    elsif (mod10 = 1) then
      text := 'рубль';
    elsif (mod10 > 0 and mod10 < 5) then
      text := 'рубля';
    else
      text := 'рублей';
    end if;
    
    dbms_output.put_line('Сумма оплаты за семестр '||cnt||': '||amt||' '|| text);
  end loop;
end;
