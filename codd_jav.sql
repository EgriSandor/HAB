--3. feladat, SZ_AUTO_TULAJDONOSA másolat tábla
delete from sz_auto_tulajdonosa where auto_azon in
(select atu.auto_azon from SZERELO.sz_auto_tulajdonosa atu
join SZERELO.sz_tulajdonos tul on tul.azon = atu.tulaj_azon
join SZERELO.sz_auto a on a.azon = atu.auto_azon
join SZERELO.sz_autotipus tip on tip.azon = a.tipus_azon
where tul.cim like 'Debrecen%' and tip.leiras like '%tetõcsomagtartó%');



--1. feladat
create or replace trigger tr_atu_datum_check
before insert or update on sz_auto_tulajdonosa
for EACH ROW
declare evi SZERELO.sz_auto.elso_vasarlas_idopontja%type;
begin
select elso_vasarlas_idopontja into evi  from SZERELO.sz_auto where azon = :new.auto_azon;
if :new.vasarlas_ideje < evi
then
raise_application_error(-20001,'az autótipus tábla nem módosítható');
end if;
end;


--2. feladat
create or replace procedure p_listaz_szereles(rsz szerelo.sz_auto.rendszam%type) is
begin
for i in ( select * from szerelo.sz_szereles sz
join szerelo.sz_auto a on a.azon = sz.auto_azon
where a.rendszam = rsz)
loop
dbms_output.put_line(rsz ||' ' || i.muhely_azon ||' '|| i.szereles_kezdete ||' '||i.szereles_vege ||' '||i.munkavegzes_ara );
end loop;
end;


--3. feladat
declare 
 kiv exception;
 pragma exception_init(kiv, -20001);
begin
   insert into sz_auto_tulajdonosa(auto_azon, vasarlas_ideje, tulaj_azon)
   values (107, to_date('1970.01.01','yyyy.mm.dd'),105);
exception when kiv then dbms_output.put_line(1Huba'sqlerrm);
end;
