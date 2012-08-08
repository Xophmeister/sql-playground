create table sudoku(
  x integer check (x in (1,2,3,4,5,6,7,8,9)),
  y integer check (y in (1,2,3,4,5,6,7,8,9)),
  b integer check (b in (1,2,3,4,5,6,7,8,9)),
  v integer check (v in (null,1,2,3,4,5,6,7,8,9)),
  t varchar2(9) default '123456789',
  primary key (x,y)
);
/

-- Populate indices and blocks
begin
  for i in 1..9 loop
    for j in 1..9 loop
      insert into sudoku (x,y,b) values (i,j,floor((i+2)/3)+3*floor((j-1)/3));
    end loop;
  end loop;
end;
/

-- Set game
declare
  board char(81) := '008050123309000080010000065020006800835040619007900050790000040080000206146090700';
  cell char(1);
begin
  for i in 1..9 loop
    for j in 1..9 loop
      cell := substr(board,i+((j-1)*9),1);
      if cell != '0' then
        update sudoku set v=to_number(cell),t=null where x=i and y=j;
      end if;
    end loop;
  end loop;
end;
/

-- The eliminator
create or replace procedure checkcell(i in number, j in number)
as
  cursor csec is
    select distinct v from sudoku where v is not null and (x=i or y=j or b=floor((i+2)/3)+3*floor((j-1)/3));
begin
  for found in csec loop
    update sudoku set t=replace(t,to_char(found.v),'') where x=i and y=j;
  end loop;
end;
/

-- Solve game
set serveroutput on;

declare
  finished number;
  lastfinished number;
  checknull number;
begin
  select count(v) into lastfinished from sudoku;
  finished := lastfinished;

  loop
    lastfinished := finished;

    for i in 1..9 loop
      for j in 1..9 loop
        select v into checknull from sudoku where x=i and y=j;
        if checknull is null then
          checkcell(i,j);
        end if;
      end loop;
    end loop;

    update sudoku set v=to_number(t) where length(t)=1 and v is null;
    update sudoku set t=null where length(t)=1;

    select count(v) into finished from sudoku;
    exit when finished=81 or finished=lastfinished;
  end loop;

  if finished=lastfinished then
    dbms_output.put_line('*** Couldn''t solve game. ***');
  else
    dbms_output.put_line('*** Solved! ***');
  end if;
end;
/

-- Output
select   y,
         max(decode(x,1,v,null)) x1,
         max(decode(x,2,v,null)) x2,
         max(decode(x,3,v,null)) x3,
         max(decode(x,4,v,null)) x4,
         max(decode(x,5,v,null)) x5,
         max(decode(x,6,v,null)) x6,
         max(decode(x,7,v,null)) x7,
         max(decode(x,8,v,null)) x8,
         max(decode(x,9,v,null)) x9
from     (select x,y,v from sudoku)
group by y
order by y;
