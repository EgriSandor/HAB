-- 1. feladat
select a.rendszam from  szerelo.sz_auto a
inner join (select  atu.auto_azon from szerelo.sz_auto_tulajdonosa atu
group by auto_azon
having count(atu.auto_azon) = (select max(count(auto_azon)) from szerelo.sz_auto_tulajdonosa GROUP BY auto_azon)) atu
on a.azon = atu.auto_azon;

--2. feladat
select szer.nev, muh.nev  from
(select dolg.szerelo_azon, dolg.muhely_azon from SZERELO.sz_dolgozik dolg
where dolg.munkaviszony_kezdete = (select max(munkaviszony_kezdete) from SZERELO.sz_dolgozik)) dolg
join SZERELO.sz_szerelo szer
on szer.azon = dolg.szerelo_azon
join SZERELO.sz_szerelomuhely muh
on muh.azon= dolg.muhely_azon
;

--3. feladat
--delete from SZERELO.sz_auto_tulajdonosa where auto_azon =

(select atu.auto_azon from SZERELO.sz_auto_tulajdonosa atu
join szerelo.sz_tulajdonos tul on tul.azon = atu.tulaj_azon
join SZERELO.sz_auto a on a.azon = atu.auto_azon
join SZERELO.sz_autotipus tip on tip.azon = a.tipus_azon
where tul.cim like '%Debrecen%' and tip.leiras like '%tetocsomagtartó%'
)
;

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
ma szerelo.sz_szereles.muhely_azon%type;
szk szerelo.sz_szereles.szereles_kezdete%type;
szv szerelo.sz_szereles.szereles_vege%type;
sza szerelo.sz_szereles.szereles_ara%type;
begin
select sz.muhely_azon, sz.szereles_kezdete, sz.szereles_vege, sz.munkavegzes_ara into ma, szk, szv, sza from szerelo.sz_szereles sz
join szerelo.sz_auto a on a.azon = sz.auto_azon;
dbms_output.put_line(rsz ||' ' || ma ||' '|| szk ||' '||szv ||' '||sza );
end;


--3. feladat
declare 
 kiv exception;
 pragma exception_init(kiv, -20001);
begin
insert into sz_auto_tulajdonosa(auto_azon, vasarlas_ideje, tulaj_azon)
values (107, sysdate,105);
exception when kiv then dbms_output.put_line(sqlerrm);
end;
