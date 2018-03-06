create or replace procedure drop_all is
  type array_t is table of varchar2(30);
  movie_drop_ops array_t := array_t(
    'drop trigger movie_add',
    'drop sequence sq_id_log',
    'drop table movie_add_log',
    'drop table movie',
    'drop table movie_studio'
  );
begin
  for i in 1..movie_drop_ops.count loop
    begin
      dbms_output.put(movie_drop_ops(i));
      execute immediate movie_drop_ops(i);
      dbms_output.put_line(': OK!');
    exception when others then
      dbms_output.put_line(': drop error '||sqlcode||': '||sqlerrm);
    end;
  end loop;
end drop_all;
/

---- Очиста всех сущевтующих таблиц
--begin drop_all; exception when others then NULL; end;
--/

---- Таблицы
-- Киностудия
create table movie_studio (
    s_id number(7),
    s_name varchar2(50) NOT NULL,
    s_country varchar2(50) NOT NULL,
    -- В одной стране все киностудии имеют уникальные имена
    CONSTRAINT movie_studio_uniq_s_name UNIQUE (s_name, s_country),
    CONSTRAINT movie_studio_pk_s_id PRIMARY KEY (s_id)
);

--  Фильмы
create table movie (
    m_id number(7),
    s_id number(7),
    m_name  varchar2(50) NOT NULL,
    m_budget number(14),
    m_date date NOT NULL,
    -- фильмы должны иметь или разные имена, или должны быть сняты в разное время
    CONSTRAINT movie_uniq_m_name UNIQUE (m_name, m_date),
    CONSTRAINT movie_pk_m_id PRIMARY KEY (m_id),
    CONSTRAINT movie_fk_s_id FOREIGN KEY (s_id) REFERENCES movie_studio(s_id)
);


----Триггер логирования добавления записей в таблицу фильмов
create table movie_add_log(
  l_id number(7),
  m_id number(7) not null,
  user_name varchar2(50) not null,
  add_time date not null,
  constraint movie_add_log_id primary key (l_id)
);

create sequence sq_id_log;
create or replace trigger movie_add before insert on movie for each row
begin
  -- в объекте date получаемом через sysdate есть дата и время.
  -- Здесь намеренно нет обработки исключений, таблица moview_add_log и её последовательность
  -- sq_id_log не должны использоваться извне, поэтому лучше сломаться здесь,
  -- чем пытаться исправить ошибку от намеренного вмешательства.
  insert into movie_add_log values(sq_id_log.nextval, :new.m_id, user, sysdate);
end movie_add;
/
 
    
-- Представление выводит имена киностудий и фильмы с бюджетом.
create or replace view movie_view as
    select s.s_name, s.s_country, m.m_name, m.m_date, m.m_budget from movie_studio s, movie m
    where m.m_budget is not null
    and m.s_id = s.s_id;

---- Пакет утилит для заполнения и очистки таблиц
create or replace package movie_utils as
  procedure fill_tables;
  procedure clean_tables;
  procedure add_studio_with_film(
      s_name in varchar2,
      s_country in varchar2,
      m_name in varchar2,
      m_date in varchar2
  );
  procedure min_max_budget_by_studio;
end;
/

create or replace package body movie_utils as
  procedure fill_tables is
    a_m_id number;
    a_s_id number;
  begin
    select max(m_id) into a_m_id from movie;
    select max(s_id) into a_s_id from movie_studio;
    if (a_m_id is null) then a_m_id := 0; end if;
    if (a_s_id is null) then a_s_id := 0; end if;

    insert into movie_studio values(a_s_id + 1, 'Columbia Pictures', 'United States');
    insert into movie_studio values(a_s_id + 2, 'Paramount Pictures', 'United States');
    insert into movie_studio values(a_s_id + 3, 'Warner Bros. Pictures', 'United States');
    insert into movie_studio values(a_s_id + 4, '20th Century Fox', 'United States');
    insert into movie_studio values(a_s_id + 5, 'Gaumont Film', 'France');

    insert into movie values(a_m_id + 1, a_s_id + 1, 'The Shawshank Redemption', 25000000, to_date('10-09-1994', 'DD-MM-YYYY'));
    insert into movie values(a_m_id + 2, a_s_id + 3, 'The Matrix', 63000000, to_date('31-03-1999', 'DD-MM-YYYY'));
    insert into movie values(a_m_id + 3, a_s_id + 3, 'The Green Mile', 60000000, to_date('06-12-1999', 'DD-MM-YYYY'));
    insert into movie values(a_m_id + 4, a_s_id + 3, 'Inception', 160000000, to_date('08-07-2010', 'DD-MM-YYYY'));
    insert into movie values(a_m_id + 5, a_s_id + 2, 'Forrest Gump', 55000000, to_date('23-06-1994', 'DD-MM-YYYY'));
    insert into movie values(a_m_id + 6, a_s_id + 4, 'Fight Club', 63000000, to_date('10-09-1999', 'DD-MM-YYYY'));
    insert into movie values(a_m_id + 7, a_s_id + 5, 'Léon', 16000000, to_date('14-09-1994', 'DD-MM-YYYY'));
    commit;
  exception
      when others then
        dbms_output.put_line('fill_tables failed - '||SQLCODE||': '||SQLERRM);
        rollback;
  end fill_tables;

  procedure clean_tables is
  begin
      delete from movie;
      delete from movie_studio;
  end clean_tables;

  procedure add_studio_with_film(
      s_name in varchar2,
      s_country in varchar2,
      m_name  in varchar2,
      m_date in varchar2
  ) is
      new_m_id number;
      new_s_id number;
  begin
      select max(m_id) into new_m_id from movie;
      select max(s_id) into new_s_id from movie_studio;
      if (new_m_id is null) then new_m_id := 0; end if;
      if (new_s_id is null) then new_s_id := 0; end if;

      insert into movie_studio values(new_s_id + 1, s_name, s_country);
      insert into movie values(new_m_id + 1, new_s_id + 1, m_name, NULL, to_date(m_date, 'DD-MM-YYYY'));
      commit;
  exception
      when others then
        dbms_output.put_line(SQLCODE||': '||SQLERRM);
        rollback;
  end add_studio_with_film;


  procedure min_max_budget_by_studio is
    cursor c_movie_view is select * from movie_view order by s_name, m_budget;
    cur movie_view%ROWTYPE;
    prev movie_view%ROWTYPE;
    print boolean;
  begin
    open c_movie_view;
    fetch c_movie_view into cur;
    print := c_movie_view%FOUND;

    loop
      if (print) then
         dbms_output.put_line(cur.s_name||', '||cur.s_country||', '||cur.m_name||', '||cur.m_budget||', '||cur.m_date);
      end if;
      exit when c_movie_view%NOTFOUND;
      prev := cur;
      fetch c_movie_view into cur;
      if (not print and c_movie_view%NOTFOUND) then
         cur := prev;
         print := true;
      else
        if (prev.s_name != cur.s_name or prev.s_country != cur.s_country) then
          if (not print) then
            dbms_output.put_line(prev.s_name||', '||prev.s_country||', '||prev.m_name||', '||prev.m_budget||', '||prev.m_date);
          end if;
          print := true;
        else
          print := false;
        end if;
      end if;
    end loop;
    if (c_movie_view%ISOPEN) then close c_movie_view; end if;
  end min_max_budget_by_studio;
  
end movie_utils;
/
