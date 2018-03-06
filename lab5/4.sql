create sequence sq_log;
create table ord_log(
  logid number(4) not null,
  op_type varchar2(20) not null,
  op_time date not null,
  constraint ord_log_id primary key (logid)
);

create or replace trigger log_ord_modifications
before insert or update or delete on ord
declare
  op char(6);
  cnt number;
begin
  if (deleting) then
    op := 'DELETE';
    select count(*) into cnt from ord;
    if (cnt <= 10) then
      raise_application_error(
        -20001,
        'Удаление запрещено, меньше 10 заказов в таблице'
      );
    end if;
  elsif (inserting) then
    op := 'INSERT';
  else
    op := 'UPDATE';
  end if;

  insert into ord_log (logid, op_type, op_time)
  values(sq_log.nextval, op, sysdate);
end log_ord_modifications;
/

delete from ord where onum = 3002;
