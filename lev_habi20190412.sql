begin
dbms_output.put_line('Hello');
end;

begin
for i in 3..20
loop
dbms_output.put_line(i);
end loop;
end;

declare
  a number(5):=3;
begin
while a<20
 loop
   dbms_output.put_line(a);
   a:=a+4;
 end loop;
end;

declare
  a number(5):=3;
begin
 loop
 exit when a>=20;
   dbms_output.put_line(a);
   a:=a+4;
 end loop;
end;

declare
  a number(8,4):=3;
  b number(5):=2;
begin
 loop
   dbms_output.put_line(a||' '||b);
   a:=a/b;
   b:=b-1;
 end loop;
 
 exception when zero_divide
 then dbms_output.put_line('0-val osztottunk');
end;

begin
for x in (select foldresz, count(*) db
          from olimpia.o_orszagok
          group by foldresz)
  loop
   dbms_output.put_line(x.foldresz||' '||x.db);
  end loop;
end;

begin
for x in (select foldresz, count(*) db
          from olimpia.o_orszagok
          group by foldresz)
  loop
   dbms_output.put_line(x.foldresz||' '||x.db);
   if x.db mod 2=0
      then dbms_output.put_line('2-vel osztható');
      else dbms_output.put_line('2-vel nem osztható');
   end if;
  end loop;
end;


begin
for x in (select foldresz, count(*) db
          from olimpia.o_orszagok
          group by foldresz)
  loop
   dbms_output.put_line(x.foldresz||' '||x.db);
   if x.db mod 6=0
      then dbms_output.put_line('6-vel osztható');
      elsif x.db mod 3=0
      then dbms_output.put_line('3-mel osztható');
      elsif x.db mod 2=0
      then dbms_output.put_line('2-vel osztható');
      else dbms_output.put_line('2-vel és 3-mal nem osztható');
   end if;
  end loop;
end;


begin
for x in (select foldresz, count(*) db
          from olimpia.o_orszagok
          group by foldresz)
  loop
   dbms_output.put_line(x.foldresz||' '||x.db);
   case 
      when x.db mod 6=0
      then dbms_output.put_line('6-vel osztható');
      when x.db mod 3=0
      then dbms_output.put_line('3-mel osztható');
      when x.db mod 2=0
      then dbms_output.put_line('2-vel osztható');
      else dbms_output.put_line('2-vel és 3-mal nem osztható');
   end case;
  end loop;
end;


declare 
  v olimpia.o_orszagok%rowtype;
begin
 select *
 into v
 from olimpia.o_orszagok
 where terulet=1;--(select min(terulet) from olimpia.o_orszagok);
 dbms_output.put_line(v.orszag);
exception 
 when no_data_found
 then dbms_output.put_line('Nincs ilyen sor');
 when too_many_rows
 then  dbms_output.put_line('Sok sort adott vissza');
end;

begin
execute immediate 'create table szamok
                   (sz number(5))';
end;

begin
for i in 2..10 
loop
insert into szamok(sz) values (i);
end loop;
commit;
end;

begin
delete szamok where sz>8;
commit;
end;

declare
  c number(5);
  function fosszead(pa number, pb number) return number is
    begin
      return pa+pb;
    end;
begin
c:=fosszead(2,3);
dbms_output.put_line(c);
end;

declare
  c number(5);
  procedure posszead(pa number, pb number, pc out number) is
    begin
      pc:=pa+pb;
    end;
begin
posszead(2,3, c);
dbms_output.put_line(c);
end;

declare
  c number(5);
  b number(5);
  procedure posszead(pa number, pb in out number, pc out number) is
    begin
      dbms_output.put_line(pb);
      pc:=pa+pb;
      pb:=pa;
    end;
begin
b:=10;
posszead(2,b, c);
dbms_output.put_line(c||' '||b);
end;

declare
  d number(5);
  procedure proc(pd out number, pa number:=20, pb in number:=30, pc number:=40) is
    begin
      dbms_output.put_line(pa||' '||pb||' '||pc);
      pd:=pa+pb+pc;
    end;
begin
proc(d);
proc(d, 50);
proc(d, 50, pc=>100, pb=>300);
proc( pc=>100, pb=>300, pd=>d);
dbms_output.put_line(d);
end;

create or replace procedure dopl(s varchar2) is
begin
dbms_output.put_line(s);
end;

begin
dopl('Almafa');
end;

Írjunk tárolt függvényt, amely paraméterként kapott országnévhez visszaadja az ország fõvárosát.
Ha az ország nem létezik, akkor null értéket adjon vissza.;

create or replace function f_fovaros(p_orszag olimpia.o_orszagok.orszag%type) 
    return olimpia.o_orszagok.fovaros%type is
    v olimpia.o_orszagok.fovaros%type;
begin
select fovaros
into v
from olimpia.o_orszagok
where orszag=p_orszag;
return v;

exception
  when no_data_found 
  then return null;
end;

alter table szamok
modify sz number(5) not null;

Írjunk tárolt eljárást, amely a számok táblába beszúr egy sort.
Null érték esetén kezeljük a hibát.
create or replace procedure p_beszur_szamok(p szamok.sz%type) is
  kiv exception;
  pragma exception_init(kiv, -1400);
  begin
   insert into szamok(sz) values (p);
  exception 
    when kiv
    then dopl(sqlcode||' '||sqlerrm);
  end;
  
begin
 p_beszur_szamok(100);
end;

begin
 p_beszur_szamok(null);
end;

begin
raise_application_error(-20001,'Kivétel történt');
end;


Írjunk tárolt függvényt, amely paraméterként egy keresztnevet kap
és visszaadja a keresztnévhez tartozó konyvtar.tag táblabeli rekordot.
Ha több ilyen rekord van, akkor dobjunk felhasználói kivételt, 
ha nincs ilyen rekord, adjunk vissza null értéket.

create or replace function f_tag(p_knev konyvtar.tag.keresztnev%type) 
    return konyvtar.tag%rowtype is
      v konyvtar.tag%rowtype;
begin
select *
into v
from konyvtar.tag
where keresztnev=p_knev;
return v;
exception 
  when no_data_found then return null;
  when too_many_rows then raise_application_error(-20002, 'Sok ilyen knev van:'||p_knev);
end;

declare 
v konyvtar.tag%rowtype;
begin
v:=f_tag('Ella');
if v.olvasojegyszam is not null then dopl(v.vezeteknev);
  else dopl('null');
end if; 
exception
when others then dopl(sqlerrm);
end;

declare 
v konyvtar.tag%rowtype;
kiv exception;
pragma exception_init(kiv, -20002);
begin
v:=f_tag('Ella');
if v.olvasojegyszam is not null then dopl(v.vezeteknev);
  else dopl('null');
end if; 
exception
when kiv then dopl(sqlerrm);
end;

create table naplo
(datum date, 
tabla varchar2(30),
muvelet varchar2(30),
regi_ertek varchar2(30),
uj_ertek varchar2(30));

Akadályozzuk meg, hogy a napló táblából töröljenek, vagy módosítsák azt.

create or replace trigger tr_naplo
before update or delete on naplo
begin
raise_application_error(-20003, 'A napló nem módosítható');
end;

update naplo set datum=sysdate;

Naplózzuk, hogy számok táblán milyen mûveleteket végeznek.

create or replace trigger tr_szamok
after insert or delete or update on szamok
for each row
declare 
m varchar2(30);
begin
m:=case when inserting then 'insert'
        when deleting then 'delete'
        when updating then 'update' end||'muvelet';

insert into naplo(datum,tabla,muvelet,regi_ertek,uj_ertek)
values (sysdate, 'szamok',m, :old.sz, :new.sz);
end;

insert into szamok (sz) values (5);
update szamok set sz=sz*2 where sz>5;
delete szamok where sz>10;
commit;

delete szamok where sz>20;

create or replace trigger tr_szamok2
before insert or update on szamok
for each row
begin
:new.sz:=:new.sz*10000;
end;

insert into szamok(sz) values (2);
update szamok set sz=sz*2 where sz<3;

create or replace package pack1 is
procedure beszur_sor(p szamok.sz%type);
function db return number;
function torol_sor(p szamok.sz%type) return number;--hány sort torol
end;

create or replace package body pack1 is
procedure beszur_sor(p szamok.sz%type) is
  begin
    insert into szamok (sz) values (p);
  end;
function db return number  is
  v number(5);
  begin
    select count(*) into v from szamok;
    return v;
  end;
  
function torol_sor(p szamok.sz%type) return number--hány sort torol
--v number(5);
 is
  begin
  --  select count(*) into v from szamok where sz=p;
    delete szamok where sz=p;
    return sql%rowcount;
  end;
end;


begin
pack1.beszur_sor(1000);
dopl(pack1.db);
dopl(pack1.torol_sor(10));
end;



create or replace package pack2 is
function leker return varchar2;
procedure beallit(pnev varchar2);
procedure init;
end;

create or replace package body pack2 is
v varchar2(50);
function leker return varchar2 is
  begin
  return v;
  end;
procedure beallit(pnev varchar2) is
  begin
  v:=pnev;
  end;
procedure init is
  begin
  v:='almafa';
  end;
begin
v:='körtefa';
end;

begin
dopl(pack2.leker);
end;

begin
pack2.beallit('diófa');
end;


declare
cursor c is select *
            from olimpia.o_orszagok;
begin
for i in c
loop
dopl(i.orszag);
end loop;
end;

declare
cursor c is select *
            from olimpia.o_orszagok;
v c%rowtype;
begin
open c;
loop
 fetch c into v;
 exit when c%notfound;
 dopl(v.orszag);
end loop;
close c;
end;

create or replace package pack_cur is
procedure sor_olvas(pfoldresz olimpia.o_orszagok.foldresz%type, psor out olimpia.o_orszagok%rowtype);
procedure lezar;
kiv exception;
end;

create or replace package body pack_cur is
vfoldresz olimpia.o_orszagok.foldresz%type;
cursor cur(pfoldresz olimpia.o_orszagok.foldresz%type) is 
  select * from olimpia.o_orszagok where foldresz=pfoldresz;

procedure sor_olvas(pfoldresz olimpia.o_orszagok.foldresz%type, psor out olimpia.o_orszagok%rowtype) is
begin
if not(cur%isopen) then open cur(pfoldresz); vfoldresz:=pfoldresz; end if;
if vfoldresz=pfoldresz then fetch cur into psor; else raise kiv; end if;
end;

procedure lezar is
  begin
  close cur;
  end;
end;

declare
 v olimpia.o_orszagok%rowtype;
begin
pack_cur.sor_olvas('Afrika', v);
dopl(v.orszag);
exception 
  when pack_cur.kiv then dopl('Hiba');
end;

begin
pack_cur.lezar;
end;







