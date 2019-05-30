create table auto_tipus as
select *
from szerelo.sz_autotipus;

create or replace trigger tr_atipus 
before insert or delete or update OF leiras on auto_tipus
for each row 
--DECLARE
begin
case
 when inserting then dopl('Insert'||:new.azon||:new.megnevezes);
 when deleting then dopl('delete'||:old.azon||:old.megnevezes);
 when updating then dopl('update'||:new.azon||:old.leiras||:new.leiras);
end case;
end;

delete auto_tipus
where marka='Suzuki';

update auto_tipus
set leiras=leiras||'almafa'
where marka='Skoda';

create or replace trigger tr_autotipus2
before update or delete on auto_tipus
begin
raise_application_error(-20001,'az autótipus tábla nem módosítható');
end;

delete auto_tipus
where marka='Suzuki';

create table naplo3(
datum date, 
utasitas varchar2(30), 
tabla varchar2(30));

create or replace trigger tr_autotipus2
after insert or update or delete on auto_tipus
declare 
  ut varchar2(30);
begin
ut:=case 
     when inserting then 'insert'
     when deleting then 'delete'
     when updating then 'update'
     end;
     
insert into naplo3(datum, utasitas, tabla)
values (sysdate, ut,'autotipus');
end;

delete auto_tipus
where marka='Suzuki';

select *
from naplo3;

create or replace trigger tr_naplo3
before insert or update on naplo3
for each row
begin
:new.utasitas:='almafa';
end;

delete auto_tipus
where marka='Suzuki';

insert into naplo3(utasitas)
values ('dió');
select *
from naplo3;

create view v10 as
select azon, megnevezes
from auto_tipus
where marka='Skoda';

alter table auto_tipus
drop constraint SYS_C00147713;

insert into v10 (azon, megnevezes)
values (1000,'almafa');

select *
from v10;

select *
from auto_tipus;

create or replace view v10 as
select azon, megnevezes
from auto_tipus
where marka='Skoda'
with check option;

insert into v10 (azon, megnevezes)
values (1000,'almafa');


create or replace trigger tr_v10 
instead of insert on v10
begin
if inserting 
   then insert into auto_tipus (azon, megnevezes, marka)
        values (:new.azon, :new.megnevezes, 'Skoda');
end if;
end;

select *
from v10;

select *
from auto_tipus;

create table vmik
(szoveg varchar2(30),
felhasznalo varchar2(30));

create view v_vmik as
select szoveg
from vmik
where felhasznalo=user;

create or replace trigger tr_v_vmik
instead of insert on v_vmik
begin
insert into vmik(szoveg, felhasznalo)
values (:new.szoveg, user);
end;

grant insert on v_vmik to u_
grant select on v_vmik to ...

insert into ....v_vmik(szoveg)
values ('almafa');

commit;

create table sz_szerelo as select * from szerelo.sz_szerelo;

create or replace function f_szerelo(p_nev szerelo.sz_szerelo.nev%type,
                                p_adoszam szerelo.sz_szerelo.adoszam%type:=null) 
return szerelo.sz_szerelo%rowtype is
v szerelo.sz_szerelo%rowtype;
begin
if p_adoszam is null
    then select *
         into v
         from sz_szerelo
         where nev=p_nev;
    else select *
         into v
         from sz_szerelo
         where nev=p_nev
         and adoszam=p_adoszam;
end if;
return v;
exception when no_data_found then return null;
          when too_many_rows 
          then raise_application_error(-20010, 'Több ilyen név van:'||p_nev);
end;

declare 
 eredmeny szerelo.sz_szerelo%rowtype;
 kiv exception;
 pragma exception_init(kiv, -20010);
begin
eredmeny:=f_szerelo('Szabó Elek');
dopl(nvl(eredmeny.nev,'null')||eredmeny.azon);
exception when kiv then dopl(sqlerrm);
end;

declare 
 eredmeny szerelo.sz_szerelo%rowtype;
 kiv exception;
 pragma exception_init(kiv, -20010);
begin
for i in (select nev from sz_szerelo)
  loop
    begin
    dopl(i.nev);
    eredmeny:=f_szerelo(i.nev);
    dopl(eredmeny.azon);
    exception when kiv then dopl(sqlerrm);
    end;
    end loop;
end;

declare 
  v varchar2(1000);
begin
for i in (select distinct marka from auto_tipus
          where marka is not null and marka not in ('Citroën'))
        loop
        v:='create table '||i.marka||'(szoveg varchar2(30))';
        dopl(v);
        --execute immediate (v);
        end loop;
end;



